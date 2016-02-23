

# This demo is part of the Getopt::ArgvFile distribution.
# It demonstrates how delay options processing until a
# separate function call.
# Jochen Stenzel, 2007.


# pragmata
use strict;




# ===> load Getopt::Argvm but do *not* process option files.
use Getopt::ArgvFile justload=>1;

# load an options processing module of your choice
use Getopt::Long;


# ===> *now* process option files
Getopt::ArgvFile::argvFile();



# process options
my %options;
GetOptions(
           \%options,

           'example',
           'demo',
          );
