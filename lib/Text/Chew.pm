package Text::Chew;

use 5.010;
use strict;
use warnings;

=head1 NAME

Text::Chew - A safer, more robust version of chomp

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Text::Chew;

Example 1:

    while (<>) {
        chew;                   # instead of chomp
        ...
    }

Example 2:

    my @lines = <>;
    chew @lines;
    ...

Example 3:

    use Text::Chew qw(chewed);

    my @lines = <>;
    my @chewed_lines = chewed(@lines);
    ...

=head1 DESCRIPTION

This module exports the C<chew> function, which removes any trailing
line terminator from the string(s) supplied to it or the special
string C<$_>.

Perl 5's C<chomp> builtin is generally safe as long as your program
only reads files with the same line terminators as specified in C<$/>
(C<$INPUT_RECORD_SEPARATOR>), which is generally C<"\n"> most of the
time.  However, when reading files with Microsoft Windows/DOS CRLF
line terminators (C<"\r\n">), C<chomp> will only remove the C<"\n">,
leaving a trailing C<"\r">.

C<Text::Chew> exists now, and you should probably start using it.

C<chew> will automatically remove any of the following line
terminators from the end of your string(s) regardless of your C<$/>
setting:

=over 4

=item *

Unix LF (C<\n>)

=item *

Windows/DOS CRLF (C<\r\n>)

=item *

Vintage Macintosh CR (<\r>)

=item *

Any string matching the C<\R> regular expression sequence.  See
L<perlrebackslash/"Misc"> for details.

=back

=cut

require Exporter;

our @ISA;
our @EXPORT;
our @EXPORT_OK;

BEGIN {
    push(@ISA, "Exporter");
    push(@EXPORT, qw(chew));
    push(@EXPORT_OK, qw(chew chewed));
}

=head1 EXPORT

C<Text::Chew> exports C<chew> by default.  It can export the following
functions:

=over 4

=item chew

=item chewed

=back

=head1 SUBROUTINES

=head2 chew

The C<chew> function modifies its arguments and returns the total
number of characters removed.

When no arguments are specified, C<chew> modifies the special variable
C<$_>.

You can pass an array, hash, or scalar variable as its first argument:

    chew $scalar;
    chew @array;
    chew %hash;

Each value of an C<@array> will be modified.  Each value of a C<%hash>
will be modified; keys will be left alone.

You may also pass references:

    chew \$scalar1;
    chew \@array1;
    chew \%hash1;
    chew $scalarref;
    chew $arrayref;
    chew $hashref;

You may also pass multiple arguments.  Each argument can be a scalar,
array, or hash variable, or a scalar, array, or hash reference.

    chew $scalar, @array, %hash, $scalarref, $arrayref, $hashref;

=cut

our $DEBUG;

use Data::Dumper;

# NOTE: when chew is passed with a %hash, the `@` in the prototype
# causes the %hash to be unfurled into a bunch of aliases.  `chew`
# will happily modify those aliases but because only the values of
# hashes are lvalues, only the values of the hash will be modified.

sub chew (@);
sub chew (@) {
    if (!scalar @_) {
        if (s/\R\z//) {
            return length $&;
        } else {
            return 0;
        }
    }
    if ($DEBUG) {
        local $Data::Dumper::Indent = 0;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Useqq = 1;
        warn("<< " . Dumper(\@_));
    }
    my $chars = 0;
    local $_;
    foreach (@_) {
        if (ref $_) {
            if (ref $_ eq "HASH") {
                foreach (values %$_) {
                    $chars += chew;
                }
            } elsif (ref $_ eq "ARRAY") {
                foreach (@$_) {
                    $chars += chew;
                }
            } elsif (ref $_ eq "SCALAR") {
                local $_ = $$_;
                $chars += chew;
            }
        } else {
            $chars += chew;
        }
    }
    if ($DEBUG) {
        local $Data::Dumper::Indent = 0;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Useqq = 1;
        warn(">> " . Dumper(\@_));
    }
    return $chars;
}

=head2 chewed

The C<chewed> function takes each of its string arguments and returns
a modified version.  Unlike C<chew>, C<chewed> does not modify its
arguments.

Also unlike C<chewed>, when passed a C<%hash>, the hash will be
unfurled into an C<@array>, and modified versions of both the keys and
values will be returned.

In a scalar context, C<chewed> returns a reference to an array of
modified strings.  In an array context, C<chewed> just returns the
array of modified strings.

=cut

sub chewed {
    my @strings = @_;
    my @result;
    foreach my $string (@strings) {
        if (!ref($string)) {
            chew($string);
            push(@result, $string);
        }
    }
    return @strings if wantarray;
    return \@strings;
}

=head1 GIT REPOSITORY

C<https://github.com/dse/perl-text-chew>

=head1 AUTHOR

Darren Embry, C<< <dse at webonastick.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Darren Embry.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;                              # End of Text::Chew
