
# set pragma
use strict;

# load test module
use Test::More qw(no_plan);

# load the module
use Getopt::ArgvFile qw(argvFile);

# action!
argvFile(default=>1, prefix=>'~');

# declare expected result
my @expected=(
              '-A',
              'A',
              '-b',
              'bb',
              '-ccc',
              'ccc ccc ccc',
              '-ddd',
              '\'d1 d2" d3\' d4 d5 d6',
              '-eee',
              '"e1 e2\\\' e3" e4 e5 e6',
              'par1',
              'par2',
              'par3',
              '~casca',
              '-case',
              'lower',
             );

# perform first check
is(@ARGV, @expected);
is_deeply(\@ARGV, \@expected);

# declare an alternative array
my @options;

# action!
argvFile(default=>1, prefix=>'~', array=>\@options);

# perform second check
is(@options, @expected);
is_deeply(\@options, \@expected);

