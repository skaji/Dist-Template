use strict;
use warnings;
use utf8;
use Test::More;
use File::pushd qw(tempd pushd);
use File::Which 'which';

use Dist::Template;

{
    my $gurad = tempd;
    my $d = Dist::Template->new;
    $d->create('My::Module');
    my $dir = 'My-Module';
    ok -d $dir;
    ok -f "$dir/Daikufile";
    if (my $daiku = which "daiku") {
        my $guard = pushd $dir;
        ok system($daiku) == 0;
        ok -f "README.md";
        ok -f "META.json";
    }
}

done_testing;
