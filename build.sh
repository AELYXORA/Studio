#!/bin/sh
set -eu
: "${CC:=clang}"
mkdir -p build
"$CC" -x assembler-with-cpp -c src/ui/validate_x86_64_sysv.S -o build/ui_validate.o
"$CC" -x assembler-with-cpp -c tests/ui_abi_x86_64_sysv.S -o build/ui_test.o
"$CC" -no-pie build/ui_validate.o build/ui_test.o -o build/ui_abi_test
./build/ui_abi_test
