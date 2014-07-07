package Dist::Template::Share;
1;
__DATA__

@@ 00_compile.t
use strict;
use warnings;
use utf8;
use Test::More;
use File::Find qw(find);

my @module;
find sub {
    local $_ = $File::Find::name;
    return unless s{\.pm$}{};
    s{^lib/}{}; s{/}{::}g;
    push @module, $_;
}, "lib";

use_ok $_ for @module;
ok system($^X, "-wc", $_) == 0 for glob "bin/* script/*";

done_testing;

@@ 01_basic.t
use strict;
use warnings;
use utf8;
use Test::More;
use <?= $arg->{module_name} ?>;

pass "todo";

done_testing;

@@ _gitignore
/*.bs
/*.c
/*.o
/*.old
/<?= $arg->{dist_name} ?>-*
/MYMETA.*
/Makefile
/blib
/pm_to_blib
/MANIFEST
/local
/cpanfile.snapshot

@@ Changes
Revision history for <?= $arg->{module_name} ?>

0.01  <?= $arg->{today} ?>

    initial version

@@ cpanfile
requires 'perl', '5.008005';

on test => sub {
    requires 'Test::More', '0.98';
};

@@ Daikufile
use Dist::Template::Tasks '<?= $arg->{module_name} ?>';

@@ Makefile.PL
use strict;
use warnings;
use ExtUtils::MakeMaker;
use File::Copy 'copy';

WriteMakefile
    NAME => '<?= $arg->{module_name} ?>',
    VERSION_FROM => 'lib/<?= $arg->{module_path} ?>',
    EXE_FILES => [glob "bin/* script/*"],
    NO_MYMETA => 1,
;

copy 'META.json' => 'MYMETA.json' if -f 'META.json';

@@ Module.pm
package <?= $arg->{module_name} ?>;
use strict;
use warnings;
use utf8;

our $VERSION = '0.01';


1;
<? ?>__END__

=encoding utf-8

=head1 NAME

<?= $arg->{module_name} ?> - new module

=head1 SYNOPSIS

    use <?= $arg->{module_name} ?>;

=head1 DESCRIPTION

<?= $arg->{module_name} ?> is a new module.

=head1 LICENSE

Copyright (C) <?= $arg->{author_name} ?>.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

<?= $arg->{author_name} ?> E<lt><?= $arg->{author_email} ?>E<gt>

=cut

