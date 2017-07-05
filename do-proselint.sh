#!/bin/sh

# proselint doesn't support linting on stdin (le sigh...), so here we capture
# stdin, put it in 'linting.txt', then lint it.
#
# Chris Weyl <cweyl@alumni.drew.edu> 2017

LINTED_FILE='linting.txt'

cat - | /bin/perl-to-pod-text.pl > "$LINTED_FILE"

proselint "$@" "$LINTED_FILE"
