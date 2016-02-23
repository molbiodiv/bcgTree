

# This demo is part of the Getopt::ArgvFile distribution.
# It demonstrates how to use the module to automatically
# process default options files.
# Jochen Stenzel, 2007.


# pragmata
use strict;




# ===> load Getopt::Argv file to process option files,
#      .<script name> (.defaultOptionFiles.pl) in the scripts directory
#                     is processed automatically, if available,
#      .<script name> (.defaultOptionFiles.pl) in users home directory
#                     is processed automatically, if available,
#      @ARGV is adapted
use Getopt::ArgvFile default=>1,   # read .defaultOptionFiles.pl in script directory, if available;
                     home=>1;      # read .defaultOptionFiles.pl in users home directory, if available;


# load an options processing module of your choice
use Getopt::Long;

# process options
my %options;
GetOptions(
           \%options,

           'example',
           'demo',
          );
