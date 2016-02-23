
# set pragma
use strict;

# load test module
use Test::More;

# test POD coverage if Test::Pod::Coverage is installed
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage" if $@;
all_pod_coverage_ok();