# perl-text-chew

A safer, more robust version of `chomp`.  You should use it.

Perl 5's `chomp` builtin is usually safe to use, as long as you are
reading files with the same line terminators as whatever your
`$INPUT_RECORD_SEPARATOR` or `$/` is set to, which is usually just the
line feed character `"\n"`.

However, when reading files containing DOS/Windows CRLF line
terminators (`"\r\n"`), `chomp` only removes the line feed and leaves
the carriage return (`"\r"`) in place.

In this case, you *could* set `$/` to `"\r\n"`, but then `chomp` will
not remove anything from a line that is only terminated by `"\n"`.

In any of those situations, `chomp` only behaves correctly when all
the files your program processes use the same line terminators.

The `Text::Chew` module provides the `chew` function, which will
automatically remove any of the following line terminators from your
strings:

- Unix LF (`"\n"`)
- DOS/Windows CRLF (`"\r\n"`)
- Vintage Macintosh CR (`"\r"`)
- Anything else considered a linebreak sequence by Unicode (as
  implemented by Perl 5.10's `\R` regular expression sequence)

## Installation

To install this module, run the following commands:

    perl Makefile.PL
    make
    make test
    make install

## Support and Documentation

SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc Text::Chew

You can also (eventually) look for information at:

    RT, CPAN's request tracker (report bugs here)
        http://rt.cpan.org/NoAuth/Bugs.html?Dist=Text-Chew

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/Text-Chew

    CPAN Ratings
        http://cpanratings.perl.org/d/Text-Chew

    Search CPAN
        http://search.cpan.org/dist/Text-Chew/

## LICENSE AND COPYRIGHT

Copyright &copy; 2018 Darren Embry.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
