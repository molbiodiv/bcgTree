use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'bcgTree',
    PREREQ_PM         => {'Log::Log4perl'  => '1.40'}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (AUTHOR         => 'Markus Ankenbrand <markus.ankenbrand@uni-wuerzburg.de>') : ()),
);
