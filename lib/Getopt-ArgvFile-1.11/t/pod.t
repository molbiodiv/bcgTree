
# set pragma
use strict;

# load test module
use Test::More;

# test POD if Test::Pod is installed
eval "use Test::Pod 1.00";
plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
all_pod_files_ok();

