
# set pragma
use strict;

# load test module
use Test::More qw(no_plan);

# load the module
use Getopt::ArgvFile qw(argvFile);

# prepare environment
$ENV{G_AF_NAMED_VAR}='Getopt::ArgvFile-named';
$ENV{G_AF_SYM_VAR}='Getopt::ArgvFile-sym';

# do not expand
argvFile(default=>1);

# declare expected result
my @expected=(
              "-envoptn",
              '$G_AF_NAMED_VAR/file',
              "-envoptn",
              '$G_AF_NAMED_VAR/file',
              "-envoptn",
              '$G_AF_NAMED_VAR/file',

              "-envopts",
              '${G_AF_SYM_VAR}/file',
              "-envopts",
              '${G_AF_SYM_VAR}/file',
              "-envopts",
              '${G_AF_SYM_VAR}/file',

              "-envoptn",
              '$G_AF_NAMED_VAR/file',
              "-envopts",
              '${G_AF_SYM_VAR}/file',

              "-envoptn",
              '$G_AF_NAMED_VAR/file',
              "-envopts",
              '${G_AF_SYM_VAR}/file',
              "-envoptn",
              '$G_AF_NAMED_VAR/file',
              "-envopts",
              '${G_AF_SYM_VAR}/file',

              "-envoptn",
              '',
              '$G_AF_NAMED_VAR/file',

              "-envoptu",
              '$G_AF_UNKNOWN_VAR/file',

              "-envoptg",
              '\$G_AF_GUARDED_VAR/file',
             );

# perform first check
is(@ARGV, @expected);
is_deeply(\@ARGV, \@expected);



# now expand
@ARGV=();
argvFile(default=>1, resolveEnvVars=>1);

# declare expected result
@expected=(
           "-envoptn",
           "$ENV{G_AF_NAMED_VAR}/file",
           "-envoptn",
           "$ENV{G_AF_NAMED_VAR}/file",
           "-envoptn",
           '$G_AF_NAMED_VAR/file',

           "-envopts",
           "$ENV{G_AF_SYM_VAR}/file",
           "-envopts",
           "$ENV{G_AF_SYM_VAR}/file",
           "-envopts",
           '${G_AF_SYM_VAR}/file',

           "-envoptn",
           "$ENV{G_AF_NAMED_VAR}/file",
           "-envopts",
           "$ENV{G_AF_SYM_VAR}/file",

           "-envoptn",
           "$ENV{G_AF_NAMED_VAR}/file",
           "-envopts",
           "$ENV{G_AF_SYM_VAR}/file",
           "-envoptn",
           "$ENV{G_AF_NAMED_VAR}/file",
           "-envopts",
           "$ENV{G_AF_SYM_VAR}/file",

           "-envoptn",
           '',
           "$ENV{G_AF_NAMED_VAR}/file",

           "-envoptu",
           "/file",

           "-envoptg",
           '$G_AF_GUARDED_VAR/file',
          );

# perform first check
is(@ARGV, @expected);
is_deeply(\@ARGV, \@expected);

