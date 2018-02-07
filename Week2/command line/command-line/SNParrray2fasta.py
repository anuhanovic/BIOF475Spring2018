#!/usr/bin/python
#
"""
Modified to deal with tab-delimited rows of IDs and nucleotides. 
Did this to parse a SNP array into FASTA format.

Author: R. Burke Squires, BCBB
"""
# __version__: 0.1.1


def converter(args):
    """
    This method takes the command line arguments and converts the input SNP file
    into a FASTA for for further analysis.
    """

    import os

    if not args.output_file:
        input_filename, file_extension = os.path.splitext(args.input_file)
        file_extension = 'fasta'
        output_file = "%s.%s" % (input_filename, file_extension)
    else:
        output_file = '%s.fasta' % args.output_file

    output = open(output_file, 'w')

    with open(args.input_file, 'U') as f:
        for line in f:
            data = line.split('\t')
            identifier = data[0]
            sequence = ''.join(data[1:])
            output.write(">%s\n%s" % (identifier, sequence))
    output.close()


if __name__ == '__main__':
    """
    This is the main function of the program and what is run first. This sets up 
    the arguments and then feeds tehm into the converter method when run.
    """
    import argparse
    
    PARSER = argparse.ArgumentParser(prog='SNParray2fasta.py',
                                     usage='%(prog)s -in (SNP file)\n',
                                     description='Create FASTA file from tab delimited SNP data.',
                                     formatter_class=lambda prog:
                                     argparse.HelpFormatter(prog, max_help_position=15),
                                     add_help=False)
    REQUIRED = PARSER.add_argument_group('Required')
    REQUIRED.add_argument('-in', '--input_file', required=True, help='The input SNP file.')

    OPTIONAL = PARSER.add_argument_group('Options')
    OPTIONAL.add_argument('-out', '--output_file', help='The output FASTA file.')
    OPTIONAL.add_argument('-h', '--help', action='help', help='show this help message & exit')
    OPTIONAL.add_argument('-path', default='.', help=argparse.SUPPRESS)

    ARGS = PARSER.parse_args()

converter(ARGS)
