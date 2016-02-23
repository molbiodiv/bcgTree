

# This demo is part of the Getopt::ArgvFile distribution.
# It demonstrates the standard use of the module.
# Jochen Stenzel, 2007.


# pragmata
use strict;



# ===> load Getopt::Argv file to process option files,
#      no automatic processing of default option files,
#      @ARGV is adapted
use Getopt::ArgvFile;




# load an options processing module of your choice
use Getopt::Long;

# process options
my %options;
GetOptions(
           \%options,

           'example',
           'demo',
          );
