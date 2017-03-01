#
# ARGUMENT PARSER
#
import argparse
import re

VERSION = "0.0.1"

class OnlineArgumentParser:

    clingo_help = """
Clingo Options:
  --<option>[=<value>]\t: Set clingo <option> [to <value>]

    """

    usage = "oclingo.py [options] [files]"

    epilog = """
Default command-line:
oclingo.py 

oclingo is part of plasp in Potassco: https://potassco.org/
Get help/report bugs via : https://potassco.org/support
    """

    def run(self):

        # version
        _version = "oclingo.py version " + VERSION

        # command parser
        _epilog = self.clingo_help + "\nusage: " + self.usage + self.epilog
        cmd_parser = argparse.ArgumentParser(description="An Online ASP Solver",
            usage=self.usage,epilog=_epilog,formatter_class=argparse.RawDescriptionHelpFormatter,
            add_help=False)

        # basic
        basic = cmd_parser.add_argument_group('Basic Options')
        basic.add_argument('-h','--help',action='help',help='Print help and exit')
        basic.add_argument('-',dest='read_stdin',action='store_true',help=argparse.SUPPRESS)
        basic.add_argument('-c','--const',dest='constants',action="append",help=argparse.SUPPRESS,default=[])
        basic.add_argument('--steps',dest='steps',help="Run only <n> steps",
                            metavar='n',default=0,type=int)
        #basic.add_argument('-v','--verbose',dest='verbose',action="store_true",help="Be a bit more verbose")
        #basic.add_argument('--stats',dest='stats',action="store_true",help="Print statistics")
      

        # Solving Options
        #solving = cmd_parser.add_argument_group('Solving Options')

        # parse
        options, unknown = cmd_parser.parse_known_args()
        options = vars(options)

        # separate files, and clingo options
        options['files'], clingo_options = [], []
        for i in unknown:
            if (re.match(r'^-',i)): clingo_options.append(i)
            else:                   options['files'].append(i)
        if options['files'] == []: options['read_stdin'] = True

        # always append statistics for using Stats()
        #clingo_options.append("--stats")

        # add constants to clingo_options
        for i in options['constants']:
            clingo_options.append("-c {}".format(i))

        print _version

        # return
        return options, clingo_options
