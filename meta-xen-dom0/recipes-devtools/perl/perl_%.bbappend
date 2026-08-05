PARALLEL_MAKE = ""

#do_configure:append() {
#    printf '%s\n' 'utime 0, 0, "$spec/Makefile.PL" or die "Unable to timestamp $spec/Makefile.PL: $!";' >> ${B}/make_ext_Makefile.pl
#    find ${B} -name Makefile.PL -exec touch -t 197001010000.00 {} +
#}

#do_compile:prepend() {
#    find ${B} -name Makefile.PL -exec touch -t 197001010000.00 {} +
#}
