# NAME

Dist::Template - create cpan module templates

# SYNOPSIS

    $ distt My::Module
    -> Writing t/00_compile.t
    -> Writing Changes
    -> Writing Daikufile
    -> Writing Makefile.PL
    -> Writing lib/zzz4.pm
    -> Writing .gitignore
    -> Writing cpanfile

    $ cd My-Module
    $ daiku -T
    daiku all    # (this is default) test, regen, clean
    daiku test   # run test cases
    daiku clean  # cleanup
    daiku regen  # regenerate README.md and META.json

    $ daiku

# DESCRIPTION

Dist::Template creates cpan module templates.
It generates Daikufile too, thus
you can develop your module with `daiku` command.

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
