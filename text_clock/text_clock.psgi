#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Dancer;
use Time::Piece;

my $Display_Format    = '';
my $Display_Week_Day  = 1;
my $Display_Month     = 1;
my $Display_Month_Day = 1;
my $Display_Year      = 1;
my $Display_Time      = 1;
my $Display_Time_Zone = 1;

get '/' => sub {   
    return date();
};


sub date {
    if (! $Display_Format) {
        $Display_Format = build_format();
    }
    
    return localtime->strftime($Display_Format);
}

sub build_format {
    my @date_fmt;
    
    push @date_fmt, '%A'       if $Display_Week_Day;
    push @date_fmt, '%B'       if $Display_Month;
    push @date_fmt, '%d'       if $Display_Month_Day;
    push @date_fmt, '%Y'       if $Display_Year;
    push @date_fmt, '%H:%M:%S' if $Display_Time;
    push @date_fmt, '%Z'       if $Display_Time_Zone;
    
    return join ' ', @date_fmt;
}

dance;