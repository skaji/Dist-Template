package Dist::Template;
use 5.008005;
use strict;
use warnings;
use File::Share 'dist_dir';
use Cwd 'abs_path';
use Path::Maker;

our $VERSION = "0.01";

sub pm_to_dist {
    local $_ = shift;
    s{::}{-}g; $_;
}
sub pm_to_path {
    local $_ = shift;
    s{::}{/}g; "$_.pm";
}
sub path_to_pm {
    local $_ = shift;
    s{^lib/}{}; s{/}{::}g; s{\.pm$}{}; $_;
};


sub new {
    my $class = shift;
    my $dir = abs_path dist_dir(pm_to_dist(__PACKAGE__));
    my $maker = Path::Maker->new(
        template_dir => $dir,
        template_header => "? my \$arg = shift;\n",
    );
    bless { maker => $maker }, $class;
}
sub create {
    my ($self, $pm) = @_;
    die "ERROR missing pm name\n" unless $pm;
    my $dist = pm_to_dist($pm);
    my $path = pm_to_path($pm);
    die "ERROR already exists $dist\n" if -e $dist;
    mkdir $dist or die "ERROR failed to create $dist: $!\n";
    chdir $dist;

    my %arg = (
        author_name  => $self->git_config('user.name'),
        author_email => $self->git_config('user.email'),
        module_name  => $pm,
        module_path  => $path,
        dist_name    => $dist,
        today        => scalar(localtime),
    );
    my %file = (
        'Changes'      => 'Changes',
        '_gitignore'   => '.gitignore',
        'Module.pm'    => "lib/$path",
        '00_compile.t' => 't/00_compile.t',
        'cpanfile'     => 'cpanfile',
        'Daikufile'    => 'Daikufile',
        'Makefile.PL'  => 'Makefile.PL',
    );
    for my $from (sort keys %file) {
        warn "-> Writing $file{$from}\n";
        $self->{maker}->render_to_file($from => $file{$from}, \%arg);
    }
}


my %git_config;
sub git_config {
    my ($self, $key) = @_;
    unless (%git_config) {
        my @out = `git config --list`;
        if ($? != 0) {
            die "ERROR failed git config --list\n";
        }
        for (@out) {
            chomp;
            my ($k, $v) = split /=/, $_, 2;
            $git_config{$k} = $v;
        }
    }
    my $git_config = $git_config{$key}
        or die "ERROR missing git config $key\n";
    return $git_config;
}


1;
__END__

=encoding utf-8

=head1 NAME

Dist::Template - create cpan module templates

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Dist::Template creates cpan module templates.
It generates Daikufile too, thus
you can develop your module with `daiku` command!

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

