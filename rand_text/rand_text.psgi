#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Dancer;
use File::Spec;
use FindBin;

my $random_file = 'random.txt';
my $delimiter = "%%\n";

get '/' => sub {
    open my $file, '<', get_file($random_file) or error $!;
    my @phrases;
    {
        local $/ = $delimiter;
        chomp(@phrases = <$file>);
    }
    my $phrase = @phrases[rand @phrases];
    
    return $phrase;
};

dance;

sub get_file {
    my $file = shift;

    if (! File::Spec->file_name_is_absolute($file)) {
        $file = File::Spec->catfile($FindBin::Bin, $file);
    }

    return $file;
}
