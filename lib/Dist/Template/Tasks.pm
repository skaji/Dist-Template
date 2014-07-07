package Dist::Template::Tasks;
use strict;
use warnings;
use utf8;

use CPAN::Meta;
use Config;
use Daiku;
use Module::CPANfile;
use Pod::Markdown;

sub slurp {
    open my $fh, "<:utf8", $_[0] or die "open $_[0]: $!\n";
    local $/; <$fh>
}
sub spew  {
    open my $fh, ">:utf8", $_[0] or die "open $_[0]: $!\n";
    print {$fh} $_[1]
}
sub module_path {
    my $module = shift;
    $module =~ s{::}{/}g;
    "lib/$module.pm";
}
sub dist_name {
    my $module = shift;
    $module =~ s{::}{-}g;
    $module;
}


my $MAKE = $Config{make};
sub import {
    shift;
    my ($module, %hash);
    if (@_ == 1) {
        $module = shift;
    } else {
        %hash = @_;
        $module = $hash{module} or die "Missing module option";
    }
    my $module_path = module_path($module);
    my $dist_name   = dist_name($module);
    my $readme      = $hash{readme} || $module_path;

    my $caller = caller;

    if (defined \&{ $caller . "::engine" }) {
        no warnings 'redefine';
        *engine = \&{ $caller . "::engine" };
    }

    task default => 'all';

    desc '(this is default) test, regen';
    task all => [qw(test regen)];

    desc 'build only';
    task build => 'Makefile' => sub {
        sh $MAKE;
    };

    desc "run test cases";
    task test => 'Makefile' => sub {
        sh $MAKE, 'test';
    };

    desc "cleanup";
    task clean => 'Makefile' => sub {
        sh $MAKE, 'realclean';
        sh "rm", "-rf", @{$hash{clean}} if $hash{clean};
    };

    desc "regenerate README.md and META.json";
    task regen => ['README.md', 'META.json'];

    file 'Makefile' => 'Makefile.PL' => sub {
        sh $^X, "Makefile.PL";
    };

    file 'README.md' => $readme => sub {
        my $p = Pod::Markdown->new;
        $p->output_string(\my $markdown);
        $p->parse_string_document(slurp $readme);
        spew "README.md", $markdown;
    };


    file 'META.json' => ['Makefile', 'cpanfile', $module_path] => sub {
        sh $MAKE, "metafile";
        my ($dir) = grep -d, glob "$dist_name-*";

        my $meta = CPAN::Meta->load_file("$dir/META.json");
        my $prereqs = Module::CPANfile->load("cpanfile")
            ->prereqs->as_string_hash;

        CPAN::Meta->new({
            %{$meta->as_struct},
            dynamic_config => 0,
            prereqs => $prereqs
        })->save("META.json");

    };
}

1;
