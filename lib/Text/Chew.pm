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

    while (<>) {
        chew;                   # instead of chomp
        ...
    }

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



=cut

our $DEBUG;
our $BEFORE;
our $AFTER;

use Data::Dumper;

sub chew (;+@);
sub chew (;+@) {
    if (!scalar @_) {
        if (s/\R\z//) {
            return length $&;
        } else {
            return 0;
        }
    }
    if ($DEBUG) {
        $BEFORE = \@_;
        local $Data::Dumper::Indent = 0;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Useqq = 1;
        warn("<< " . Dumper($BEFORE));
    } else {
        $BEFORE = undef;
        $AFTER = undef;
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
        $AFTER = \@_;
        local $Data::Dumper::Indent = 0;
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Useqq = 1;
        warn(">> " . Dumper($AFTER));
    }
    return $chars;
}

=head2 chewed

=cut

sub chewed {
    my @strings = @_;
    foreach my $string (@strings) {
        chew($string);
    }
    return @strings if wantarray;
    return \@strings;
}

=head1 AUTHOR

Darren Embry, C<< <dse at webonastick.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-text-chew at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Text-Chew>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Text::Chew

You can also (eventually) look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Chew>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Text-Chew>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Text-Chew>

=item * Search CPAN

L<http://search.cpan.org/dist/Text-Chew/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2018 Darren Embry.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;                              # End of Text::Chew
