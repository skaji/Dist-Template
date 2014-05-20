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
    s{^lib/}{}; s{/}{::};
    push @module, $_;
}, "lib";

use_ok $_ for @module;

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
copy 'META.json' => 'MYMETA.json' if -f 'META.json';

WriteMakefile
    NAME => '<?= $arg->{module_name} ?>',
    VERSION_FROM => 'lib/<?= $arg->{module_path} ?>',
    ABSTRACT_FROM => 'lib/<?= $arg->{module_path} ?>',
    AUTHOR => ['<?= $arg->{author_name} ?> <<?= $arg->{author_email} ?>>'],
    LICENSE => 'perl',
    EXE_FILES => [],
    NO_MYMETA => 1,
;

@@ Module.pm
package <?= $arg->{module_name} ?>;
use strict;
use warnings;
use utf8;

our $VERSION = '0.001';


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

