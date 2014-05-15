use strict;
use warnings;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile
    NAME => '<?= $arg->{module_name} ?>',
    VERSION_FROM => 'lib/<?= $arg->{module_path} ?>',
    ABSTRACT_FROM => 'lib/<?= $arg->{module_path} ?>',
    AUTHOR => '<?= $arg->{author_name} ?> <<?= $arg->{author_email} ?>>',
    LICENSE => 'perl',
    EXE_FILES => [],
;
