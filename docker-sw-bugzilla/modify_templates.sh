#!/usr/bin/env bash
# Copyright Smoothwall Ltd 2015

# Add our default template
# Double backslashes to keep formatting the same and not put everything on one line
sed -i -e "/\[% defaultcontent = BLOCK %\]/,/\[% INCLUDE bug\/comment.html.tmpl/ c \\
[% defaultcontent = BLOCK %\]\\
[% IF cloned_bug_id %]\\
+++ This [% terms.bug %] was initially created as a clone of [% terms.Bug %] #[% cloned_bug_id %] +++\\
\\
\\
[% END %]\\
* Problem Summary\\
\\
\\
\\
* Environment / Configuration\\
\\
\\
\\
* Detailed Problem Description\\
\\
\\
\\
* Steps to Reproduce\\
\\
1.\\
2.\\
3.\\
\\
* Expected Results\\
\\
\\
\\
* Actual Results\\
\\
\\
\\
* Location of Debug-related Logs, etc.\\
\\
\\
\\
* Regression?\\
\\
\\
\\
* Customer Contact Details\\
\\
\\
\\
* Additional Information\\
\\
\\
\\
[%-# We are within a BLOCK. The comment will be correctly HTML-escaped\\
# by global/textarea.html.tmpl. So we must not escape the comment here. %]\\
[% comment FILTER none %]\\
[%- END %]\\
[% INCLUDE bug/comment.html.tmpl" $BUGZILLA_ROOT/template/en/default/bug/create/create.html.tmpl


# Change the font size for comments (Bugmail)
sed -i -e "/comment.body_full/c \
<pre style='font-size:14px;'>[% comment.body_full({ wrap => 1 }) FILTER quoteUrls(bug, comment, to_user) %]</pre>" \
$BUGZILLA_ROOT/template/en/default/email/bugmail.html.tmpl
