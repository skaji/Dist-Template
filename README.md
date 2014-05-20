# NAME

Dist::Template - create cpan module templates

# SYNOPSIS

    $ distt Hello::World
    $ cd Hello-World
    $ ls -F
    Changes  Daikufile  Makefile.PL  cpanfile  lib/  t/

    $ daiku --tasks
    daiku all    # (this is default) test, regen
    daiku test   # run test cases
    daiku clean  # cleanup
    daiku regen  # regenerate README.md and META.json

# DESCRIPTION

Dist::Template creates cpan module templates.

# WHY NEW?

Dist::Template prepares Daikufile,
which is similar to ruby's Rakefile.
When I develop cpan modules, I sometimes want to
define custom commands. For example,
fatpack, CI specific commands.
Daikufile helps that.

# SEE ALSO

`Daiku`

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
