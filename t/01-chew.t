#!perl -T
use 5.010;
use strict;
use warnings;
use Test::More;

plan tests => 67;

use Text::Chew qw(chew chewed);
use Data::Dumper;

sub evalwarn (&) {
    my ($sub) = @_;
    my @result;
    my $result;
    if (wantarray) {
        eval {
            @result = &$sub;
        };
    } else {
        eval {
            $result = &$sub;
        };
    }
    if ($@) {
        warn $@;
    }
    if (wantarray) {
        return @result;
    } else {
        return $result;
    }
}

diag('$_');
{
    local $_ = "one\r\n";
    evalwarn {
        chew;
    };
    ok($_ eq "one");
}
{
    local $_ = "two\r\n";
    evalwarn {
        chew $_;
    };
    ok($_ eq "two");
}
{
    local $_ = "three\r\n";
    evalwarn {
        chew($_);
    };
    ok($_ eq "three");
}
diag('multiple scalar arguments');
{
    my ($a, $b, $c, $d) = ("four", "five\n", "six\r", "seven\r\n");
    evalwarn {
        chew $a, $b, $c, $d;
    };
    ok($a eq "four");
    ok($b eq "five");
    ok($c eq "six");
    ok($d eq "seven");
}
{
    my ($a, $b, $c, $d) = ("eight", "nine\n", "ten\r", "eleven\r\n");
    evalwarn {
        chew($a, $b, $c, $d);
    };
    ok($a eq "eight");
    ok($b eq "nine");
    ok($c eq "ten");
    ok($d eq "eleven");
}
diag('@array arguments');
{
    my @foo = ("twelve", "thirteen\n", "fourteen\r", "fifteen\r\n");
    evalwarn {
        chew @foo;
    };
    ok($foo[0] eq "twelve");
    ok($foo[1] eq "thirteen");
    ok($foo[2] eq "fourteen");
    ok($foo[3] eq "fifteen");
    ok(scalar @foo == 4);       # sixteen
}
{
    my @foo = ("seventeen", "eighteen\n", "nineteen\r", "twenty\r\n");
    evalwarn {
        chew(@foo);
    };
    ok($foo[0] eq "seventeen");
    ok($foo[1] eq "eighteen");
    ok($foo[2] eq "nineteen");
    ok($foo[3] eq "twenty");
    ok(scalar @foo == 4);       # twenty-one
}
diag('%hash arguments');
{
    local $Text::Chew::DEBUG = 1;
    my %foo = ("twenty-two\r\n"   => "twenty-effin-two\r\n",
               "twenty-three\r\n" => "twenty-effin-three\r\n");
    evalwarn {
        chew %foo;
    };
    my $keys   = join(", ", sort { $a cmp $b } keys %foo);
    my $values = join(", ", sort { $a cmp $b } values %foo);
    ok($keys   eq "twenty-three\r\n, twenty-two\r\n");
    ok($values eq "twenty-effin-three, twenty-effin-two");
}
{
    local $Text::Chew::DEBUG = 1;
    my %foo = ("twenty-four\r\n" => "twenty-effin-four\r\n",
               "twenty-five\r\n" => "twenty-effin-five\r\n");
    evalwarn {
        chew(%foo);
    };
    my $keys   = join(", ", sort { $a cmp $b } keys %foo);
    my $values = join(", ", sort { $a cmp $b } values %foo);
    ok($keys   eq "twenty-five\r\n, twenty-four\r\n");
    ok($values eq "twenty-effin-five, twenty-effin-four");
}
diag('array reference');
{
    my $foo = ["twelve", "thirteen\n", "fourteen\r", "fifteen\r\n"];
    evalwarn {
        chew $foo;
    };
    ok($foo->[0] eq "twelve");
    ok($foo->[1] eq "thirteen");
    ok($foo->[2] eq "fourteen");
    ok($foo->[3] eq "fifteen");
    ok(scalar @$foo == 4);       # sixteen
}
{
    my $foo = ["seventeen", "eighteen\n", "nineteen\r", "twenty\r\n"];
    evalwarn {
        chew($foo);
    };
    ok($foo->[0] eq "seventeen");
    ok($foo->[1] eq "eighteen");
    ok($foo->[2] eq "nineteen");
    ok($foo->[3] eq "twenty");
    ok(scalar @$foo == 4);       # twenty-one
}
diag('hash reference');
{
    my $foo = {"twenty-two\r\n"   => "twenty-effin-two\r\n",
               "twenty-three\r\n" => "twenty-effin-three\r\n"};
    evalwarn {
        chew $foo;
    };
    my $keys   = join(", ", sort { $a cmp $b } keys %$foo);
    my $values = join(", ", sort { $a cmp $b } values %$foo);
    ok($keys   eq "twenty-three\r\n, twenty-two\r\n");
    ok($values eq "twenty-effin-three, twenty-effin-two");
}
{
    my $foo = {"twenty-four\r\n" => "twenty-effin-four\r\n",
               "twenty-five\r\n" => "twenty-effin-five\r\n"};
    evalwarn {
        chew($foo);
    };
    my $keys   = join(", ", sort { $a cmp $b } keys %$foo);
    my $values = join(", ", sort { $a cmp $b } values %$foo);
    ok($keys   eq "twenty-five\r\n, twenty-four\r\n");
    ok($values eq "twenty-effin-five, twenty-effin-four");
}
diag('\@array reference');
{
    my @foo = ("twelve", "thirteen\n", "fourteen\r", "fifteen\r\n");
    evalwarn {
        chew \@foo;
    };
    ok($foo[0] eq "twelve");
    ok($foo[1] eq "thirteen");
    ok($foo[2] eq "fourteen");
    ok($foo[3] eq "fifteen");
    ok(scalar @foo == 4);       # sixteen
}
{
    my @foo = ("seventeen", "eighteen\n", "nineteen\r", "twenty\r\n");
    evalwarn {
        chew(\@foo);
    };
    ok($foo[0] eq "seventeen");
    ok($foo[1] eq "eighteen");
    ok($foo[2] eq "nineteen");
    ok($foo[3] eq "twenty");
    ok(scalar @foo == 4);       # twenty-one
}
diag('\%hash reference');
{
    my %foo = ("twenty-two\r\n"   => "twenty-effin-two\r\n",
               "twenty-three\r\n" => "twenty-effin-three\r\n");
    evalwarn {
        chew \%foo;
    };
    my $keys   = join(", ", sort { $a cmp $b } keys %foo);
    my $values = join(", ", sort { $a cmp $b } values %foo);
    ok($keys   eq "twenty-three\r\n, twenty-two\r\n");
    ok($values eq "twenty-effin-three, twenty-effin-two");
}
{
    my %foo = ("twenty-four\r\n" => "twenty-effin-four\r\n",
               "twenty-five\r\n" => "twenty-effin-five\r\n");
    evalwarn {
        chew(\%foo);
    };
    my $keys   = join(", ", sort { $a cmp $b } keys %foo);
    my $values = join(", ", sort { $a cmp $b } values %foo);
    ok($keys   eq "twenty-five\r\n, twenty-four\r\n");
    ok($values eq "twenty-effin-five, twenty-effin-four");
}
diag('return value');
{
    my $foo = ["seventeen", "eighteen\n", "nineteen\r", "twenty\r\n"];
    my $result = evalwarn {
        chew($foo);
    };
    ok($foo->[0] eq "seventeen");
    ok($foo->[1] eq "eighteen");
    ok($foo->[2] eq "nineteen");
    ok($foo->[3] eq "twenty");
    ok(scalar @$foo == 4);       # twenty-one
    ok($result == 4);
}
diag('chewed');
{
    my @foo = ("\none\n", "\ntwo\n", "\nthree\n", "\nfour\n");
    my @bar = evalwarn {
        chewed(@foo);
    };
    ok(scalar @bar == 4);
    ok($bar[0] eq "\none");
    ok($bar[1] eq "\ntwo");
    ok($bar[2] eq "\nthree");
    ok($bar[3] eq "\nfour");
}
diag('hash variable as second argument');
{
    local $Text::Chew::DEBUG = 1;
    my $junk = "foo\n";
    my %junk = ("one\n" => "two\n", "three\n" => "four\n");
    evalwarn {
        chew $junk, %junk;
    };
    ok($junk eq "foo");
    my $keys   = join(", ", sort { $a cmp $b } keys   %junk);
    my $values = join(", ", sort { $a cmp $b } values %junk);
    ok($keys   eq "one\n, three\n");
    ok($values eq "four, two");
}
