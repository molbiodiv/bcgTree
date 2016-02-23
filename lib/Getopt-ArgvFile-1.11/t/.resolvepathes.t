
# same directory
-file1
./file1

# one level up
-file2
../file2

# same file
-file2
./../file2

# back to first file (relative to *this* file!!)
-file1
../././t/file1

# now, for a nested option file (relative to *this* file!!)
@././././.resolvepathes2.t

