
# set pragmas
use strict;
our @org;

# load test module
use Test::More qw(no_plan);

# prepare @ARGV
BEGIN {@org=@ARGV=('~t/.prefix.t')}

# load the module, but suppress option hint processing
use Getopt::ArgvFile prefix=>'~', justload=>1;

# perform checks
is(@ARGV, 1);
is_deeply(\@ARGV, \@org);

