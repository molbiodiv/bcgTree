
# an option with a named environment variable
-envoptn $G_AF_NAMED_VAR/file
-envoptn "$G_AF_NAMED_VAR/file"
-envoptn '$G_AF_NAMED_VAR/file'

# an option with a symbolic variable
-envopts ${G_AF_SYM_VAR}/file
-envopts "${G_AF_SYM_VAR}/file"
-envopts '${G_AF_SYM_VAR}/file'

# both in one line
-envoptn $G_AF_NAMED_VAR/file -envopts ${G_AF_SYM_VAR}/file

# both in one line, multiply
-envoptn $G_AF_NAMED_VAR/file -envopts ${G_AF_SYM_VAR}/file -envoptn $G_AF_NAMED_VAR/file -envopts ${G_AF_SYM_VAR}/file

# an option with an environment variable and an empty string in between
-envoptn '' $G_AF_NAMED_VAR/file

# an option with an undefined environment variable
-envoptu $G_AF_UNKNOWN_VAR/file

# an option with a guarded environment variable
-envoptg \$G_AF_GUARDED_VAR/file
