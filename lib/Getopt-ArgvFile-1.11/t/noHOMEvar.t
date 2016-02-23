
#
# This is no real test - we cannot test if we do *not* load
# a file from the users home directory, because we cannot
# write to there. (We could fake $ENV{HOME}, but that's just
# the variable we want to run without.)
#
# So, this test is just a reminder.
#

# set pragma
use strict;

# load test module
use Test::More qw(no_plan);

# load the module
use Getopt::ArgvFile qw(argvFile);

# prepare environment
delete $ENV{HOME};

# action!
argvFile(home=>1);

# perform check - @ARGV should be empty now
is(@ARGV, 0);

