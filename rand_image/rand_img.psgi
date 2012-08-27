#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Dancer;

my $img_dir = 'public/img';

get '/' => sub {
    opendir my $dir, $img_dir or die $!;
    my @imgs = grep { -f "$img_dir/$_" } readdir $dir;
    my $img = @imgs[rand @imgs];
    
    warn $img;
    
    return redirect "/img/$img";
};

get '/img/:img' => sub {
    return send_file 'img/' . params->{img};
};

get '/test' => sub {
    return '<img src="/" />';
};

dance;