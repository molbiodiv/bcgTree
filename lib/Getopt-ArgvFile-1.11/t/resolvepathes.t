
# set pragma
use strict;

# load test module
use Test::More qw(no_plan);

# load the module
use Getopt::ArgvFile qw(argvFile);

# load helper modules
use Cwd;
use File::Basename;

# do not resolve
argvFile(default=>1);

# declare expected result
my @expected=(
              '-file1',
              './file1',

              '-file2',
              '../file2',

              '-file2',
              './../file2',

              '-file1',
              "../././t/file1",
             );

# perform first check
is(@ARGV, @expected);
is_deeply(\@ARGV, \@expected);



# now resolve
@ARGV=();
argvFile(default=>1, resolveRelativePathes=>1);

# get current *run* path
my $currentPath=cwd();
my $parentPath=dirname($currentPath);

# declare expected result (for "make test" which is started one level up)
@expected=(
           '-file1',
           "$currentPath/t/file1",

           '-file2',
           "$currentPath/file2",

           '-file2',
           "$currentPath/file2",

           '-file1',
           "$currentPath/t/file1",

           '-nested',
           'file',
          );

# perform first check
is(@ARGV, @expected);
is_deeply(\@ARGV, \@expected);



