#!/bin/bash
 # Copyright Smoothwall Ltd 2015

# This is intentionally ran twice
perl $BUGZILLA_ROOT/checksetup.pl $BUGZILLA_ROOT/checksetup_answers.txt
perl $BUGZILLA_ROOT/checksetup.pl $BUGZILLA_ROOT/checksetup_answers.txt
