
# set pragma
use strict;

# load test module
use Test::More qw(no_plan);

# prepare @ARGV
BEGIN {@ARGV=('~t/.prefix.t')}

# load the module
use Getopt::ArgvFile prefix=>'~';

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

# perform checks
is(@ARGV, @expected);
is_deeply(\@ARGV, \@expected);

