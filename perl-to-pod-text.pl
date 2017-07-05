#!/usr/bin/env perl

# Given a .pm, spew out the inline pod, as close to plain text as we can while
# attempting to keep line numbers, 

use v5.20;
use strict;
use warnings;

use Pod::Elemental;
use Pod::Elemental::Transformer::Pod5;

my $source = do { local $/; <> };
my $document = Pod::Elemental->read_string($source);

# say '===> started at line: ' . $_dap->start_line => q{} => $_->as_debug_string
#     for $document->children->@*;

### $document

my @lines;

for my $node ($document->children->@*) {
    next if $node->isa('Pod::Elemental::Element::Generic::Nonpod');
    next if $node->isa('Pod::Elemental::Element::Generic::Command')
        and $node->command() eq 'for';

    # skip if we're indented; that almost always means a code block
    next if $node->content =~ /^    /;

    # what are the two most common programming errors?
    my $line = $node->start_line - 1;

    # make columns work by replacing command with spaces
    my $prefix 
        = $node->isa('Pod::Elemental::Element::Generic::Command')
        ? (q{ } x (length($node->command)+1))
        : q{}
        ;

    my @content_lines = split(/\n/, $prefix . $node->content);
    @lines[$line..$line+@content_lines] = @content_lines;
}

@lines = map { defined $_ ? $_ : q{} } @lines;

### @lines

say for @lines;

__END__

Pod::Elemental::Transformer::Pod5->new->transform_node($document);

say '---------> ' . ref $document;

say '=============> DEBUG STRING';
print $document->as_debug_string, "\n"; # quick overview of doc structure

say;
say '=============> POD STRING';
print $document->as_pod_string, "\n";   # reproduce the document in Pod

say '===> started at line: ' . $_->start_line => $_->as_debug_string
    for $document->children->@*;

