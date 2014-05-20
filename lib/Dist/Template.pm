package Dist::Template;
use 5.008005;
use strict;
use warnings;
use Dist::Template::Share;
use File::pushd 'pushd';
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
    my $maker = Path::Maker->new(
        package => "Dist::Template::Share",
        template_header => "? my \$arg = shift;\n",
    );
    bless { maker => $maker }, $class;
}
sub create {
    my ($self, $pm) = @_;
    die "ERROR missing pm name\n" unless $pm;
    my $dist = pm_to_dist($pm);
    my $path = pm_to_path($pm);

    my %arg = (
        author_name  => $self->git_config('user.name'),
        author_email => $self->git_config('user.email'),
        module_name  => $pm,
        module_path  => $path,
        dist_name    => $dist,
        today        => scalar(localtime),
    );

    die "ERROR already exists $dist.\n" if -e $dist;
    warn "-> mkdir $dist\n";
    mkdir $dist or die "ERROR failed to create $dist: $!\n";
    {
        my $guard = pushd $dist;
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
            warn "-> writing $dist/$file{$from}\n";
            $self->{maker}->render_to_file($from => $file{$from}, \%arg);
        }
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

    $ distt Hello::World
    $ cd Hello-World
    $ ls -F
    Changes  Daikufile  Makefile.PL  cpanfile  lib/  t/

    $ daiku --tasks
    daiku all    # (this is default) test, regen
    daiku test   # run test cases
    daiku clean  # cleanup
    daiku regen  # regenerate README.md and META.json

=head1 DESCRIPTION

Dist::Template creates cpan module templates.

=head1 WHY NEW?

Dist::Template prepares Daikufile,
which is similar to ruby's Rakefile.
When I develop cpan modules, I sometimes want to
define custom commands. For example,
fatpack, CI specific commands.
Daikufile helps that.

=head1 SEE ALSO

L<Daiku>

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

