#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Text::Chew' ) || print "Bail out!\n";
}

diag( "Testing Text::Chew $Text::Chew::VERSION, Perl $], $^X" );
