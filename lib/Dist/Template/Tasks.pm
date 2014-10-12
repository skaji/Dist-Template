package Dist::Template::Tasks;
use strict;
use warnings;
use utf8;

use CPAN::Meta;
use Config;
use Daiku;
use Module::CPANfile;
use Pod::Markdown;
use Pod::Escapes;
require ExtUtils::MM_Unix;
require Dist::Template;

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

    my $clean = $hash{clean} && ref $hash{clean} ? $hash{clean}
              : $hash{clean}                     ? [$hash{clean}]
              : undef;

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
        local $ENV{HARNESS_OPTIONS} = "c" unless $ENV{HARNESS_OPTIONS};
        sh $MAKE, 'test';
    };

    desc "cleanup";
    task clean => 'Makefile' => sub {
        sh $MAKE, 'realclean';
        sh "rm", "-rf", @{$clean} if $clean;
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


    file 'META.json' => ['cpanfile', $module_path] => sub {
        my $mm = bless { DISTNAME => $dist_name }, 'ExtUtils::MM_Unix';
        my $abstract = $mm->parse_abstract($module_path);
        my $version  = $mm->parse_version($module_path);
        my $prereqs = Module::CPANfile->load("cpanfile")
            ->prereqs->as_string_hash;
        my $authors = _build_authors($module_path);

        my $spec = {
            "meta-spec" => {
                version => 2,
                url => "http://search.cpan.org/perldoc?CPAN::Meta::Spec",
            },
            license => ["perl_5"],
            abstract => $abstract,
            dynamic_config => 0,
            version => $version,
            name => $dist_name,
            prereqs => $prereqs,
            generated_by => "Dist::Template/$Dist::Template::VERSION",
            release_status => "unstable",
            no_index => { directory => [qw(t xt inc eg example author)] },
            author => $authors,
        };

        CPAN::Meta->new($spec)->save("META.json");
    };
}

# taken from Minilla::Metadata
sub _build_authors {
    my $path = shift;
    my $content = slurp $path;

    if ($content =~ m/
        =head \d \s+ (?:authors?)\b \s*
        ([^\n]*)
        |
        =head \d \s+ (?:licen[cs]e|licensing|copyright|legal)\b \s*
        .*? copyright .*? \d\d\d[\d.]+ \s* (?:\bby\b)? \s*
        ([^\n]*)
    /ixms) {
        my $author = $1 || $2;

        $author =~ s{ E<( (\d+) | ([A-Za-z]+) )> }{
            defined $2
            ? chr($2)
            : defined $Pod::Escapes::Name2character_number{$1}
            ? chr($Pod::Escapes::Name2character_number{$1})
            : do {
                warn "Unknown escape: E<$1>";
                "E<$1>";
            };
        }gex;

        my @authors;
        for (split /\n/, $author) {
            chomp;
            next unless /\S/;
            push @authors, $_;
        }
        return \@authors;
    } else {
        warn "Cannot determine author info from $path\n";
        return undef;
    }
}


1;
