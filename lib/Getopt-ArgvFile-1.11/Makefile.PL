# Makefile.PL -- Makefile template for Getopt::ArgvFile.
#
# This file is part of the "Getopt::ArgvFile" module package.
# Getopt::ArgvFile is free software, you can redistribute it
# and/or modify it under the same terms as Perl itself.

# load module
use ExtUtils::MakeMaker;

# write makefile
WriteMakefile(
			  NAME         => 'Getopt::ArgvFile',
			  VERSION_FROM => 'ArgvFile.pm',
              LICENSE      => 'artistic',

              PREREQ_PM    => {
                               Text::ParseWords => 3.1,
                               Test::Harness    => 1.25,
                               Test::More       => 0.11,
                              },
			  dist         => {
			                   COMPRESS => 'gzip -9',
			                   SUFFIX   => 'tar.gz',
					  },
			 );
