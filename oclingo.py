#!/usr/bin/python

import clingo
import arguments
import sys

BASE = "base"
STEP = "step"
T = "t"
HISTORY = "history"
ASP_HISTORY = "asp_history"
PLAN_LENGTH = 1
EMPTY  =""
RESULT = "_result"
ANSWER = "_answer"
SAT = "sat"
UNSAT = "unsat"
STEPS = 5
EXTERNAL = "_external"
SENSE = "sense"

#
# Simple Solver
#
class Solver:

    def __init__(self,options,clingo_options):
        self.options = options
        self.clingo_options = clingo_options
        self.plan_length = PLAN_LENGTH
        self.model =[] 

    def on_model(self,m):
        self.model = m.symbols(shown=True)

    def do_solve(self,control,assump=[]):
        self.model = []
        result = control.solve(on_model=self.on_model,assumptions=assump)
        return result.satisfiable, self.model

    def solve(self,state):
        control = clingo.Control(clingo_options)
        # input files
        for i in options['files']:
            control.load(i)
        if options['read_stdin']:
            control.add(BASE, [], sys.stdin.read())
        control.add(HISTORY, [], state.get_history())
        parts = [(BASE, []), (HISTORY, [])]
        parts = parts + [(STEP, [t]) for t in range(1, self.plan_length+1)] #fixed plan length
        control.ground(parts)
        return self.do_solve(control)

#
# State
#
class State:
    def __init__(self):
        self.history     = [] # list of dictionaries of the form (string : list_of_strings)
    
    def get_history(self):
        step, out = 0, EMPTY
        for i in self.history:
            for key, value in i.items():
                out += " ".join([key+"("+j+","+str(step)+")." for j in value])
            step += 1
        return out


#
# Online Solver (without procedures)
#

class FinishOnlineSolver(Exception):
    pass

class Procedure:
    def __init__(self,result,atom,proc):
        self.result = result
        self.atom   = atom
        self.proc   = proc

class OnlineSolver:

    # initialize
    def __init__(self,options,clingo_options):
        self.options        = options
        self.clingo_options = clingo_options
        self.state          = State()
        self.solver         = Solver(options,clingo_options)
        self.procedures     = []

    # online solving
    def run(self):
        steps = 0
        while True:
            print "Solving..."
            sat, answer = self.solver.solve(self.state)
            self.state.history.append(dict([(RESULT,[SAT if sat else UNSAT]),
                                            (ANSWER,[str(i) for i in answer])]))
            try:
                for i in self.procedures:
                    if sat == i.result and (i.result == False or i.atom in answer):
                        i.proc(self.state)
            except FinishOnlineSolver:
                break
            steps += 1
            if steps == self.options['steps']: break

#
#  Online Solver with procedures
#
class OnlineSolverA(OnlineSolver):

    def __init__(self,options,clingo_options):
        OnlineSolver.__init__(self,options,clingo_options)
        self.procedures.append(Procedure(True,self.__run_atom("print"), self.print_answer))
        self.procedures.append(Procedure(True,self.__run_atom("printh"),self.print_answer_hide_aux))
        self.procedures.append(Procedure(True,self.__run_atom("execute"), self.execute))
        self.procedures.append(Procedure(True,self.__run_atom( "stop"), self.stop))
        self.procedures.append(Procedure(True,self.__run_atom("sense"), self.sense))
        self.procedures.append(Procedure(True,self.__run_atom("reset"), self.reset))
        self.procedures.append(Procedure(True,self.__run_atom("last"), self.keep_last))
        self.procedures.append(Procedure(True,self.__run_atom("asp_history"), self.asp_history))
        self.procedures.append(Procedure(False,                   None, self.unsat))
        #self.procedures.append(Procedure(False,                   None, self.reset))

    def __run_atom(self,string):
        return clingo.Function("_run",[clingo.Function(string, [])])

    #
    # procedures
    #

    def stop(self,state):
        print "\nSTOP"
        raise FinishOnlineSolver

    def do_print_answer(self,state,aux):
        last = state.history[-1]
        sat = last[RESULT]
        if sat is False:  print "\nUNSAT"
        elif sat is None: print "\nUNKNOWN"
        elif aux: print "\nAnswer:\n" + " ".join(last["_answer"])
        else: print "\nAnswer:\n" + " ".join([i for i in last[ANSWER] if i[0]!="_"])

    def print_answer(self,state):
        self.do_print_answer(state,True)

    def print_answer_hide_aux(self,state):
        self.do_print_answer(state,False)

    def sense(self,state):
        obs = [ SENSE ]
        while True:
            input = raw_input("Enter sensing result (s to stop): ")
            if input == "s": break
            obs.append(input)
            #clingo.parse_term(input))
        if obs is not []: state.history[-1][EXTERNAL] = obs
        
    def execute(self,state):
        last = state.history[-1][ANSWER]
        for i in last:
            if i.startswith("execute("):
                print "EXECUTE: {}".format(i[len("execute("):-1])
                return

    def unsat(self,state):
        print "UNSAT"
        #self.stop(state)

    def reset(self,state):
        print "RESET"
        state.history = []

    def keep_last(self,state):
        print "LAST"
        state.history = state.history[-1:]

    def asp_history(self,state):
        control = clingo.Control(self.clingo_options)
        # input files
        for i in self.options['files']:
            control.load(i)
        if self.options['read_stdin']:
            control.add(BASE, [], sys.stdin.read())
        control.add(HISTORY, [], state.get_history())
        parts = [(ASP_HISTORY, []), (HISTORY, [])]
        control.ground(parts)
        sat, model = Solver(options,clingo_options).do_solve(control)
        if not sat: 
            return
        state.history, max, l = [], 0, []
        for i in model:
            if i.name == "history" and len(i.arguments)==2:
                predicate = str(i.arguments[0].name)
                term      = i.arguments[0].arguments 
                term      = str(term) if len(term)==0 else str(term[0])
                step      = int(str(i.arguments[1]))
                max = step if step > max else max
                l.append([predicate,term,step])
        state.history = [ dict() for i in range(max+1)]
        for i in l:
            if i[0] in state.history[i[2]]:
                state.history[i[2]][i[0]].append(i[1])
            else:
                state.history[i[2]][i[0]] = [i[1]]
        #print state.history



if __name__ == '__main__':
    options, clingo_options = arguments.OnlineArgumentParser().run()
    solver = OnlineSolverA(options,clingo_options)
    solver.run()

