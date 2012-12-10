#!/usr/bin/env perl

use strict;
use warnings;

use Mojolicious::Lite;

use Time::Piece;

# see format at: http://www.unix.com/man-page/FreeBSD/3/strftime/
my $format = '%Y,%m,%d,%H,%M,%S';

helper 'time' => sub {
  my $self = shift;
  my $time = shift || gmtime;

  unless ( eval { $time->isa('Time::Piece') } ) {
    $time = Time::Piece->strptime( $time, $format );
  }

  return $time;
};

helper 'countdown' => sub {
  my $self = shift;
  my $to = shift || '';
  $to = eval { $self->time( $to ) }
    || $self->render( text => "Error parsing format: $format (given: '$to')" );

  my $now = $self->time;
  my $text = ($to - $now)->pretty;
  $text .= ' ago' if $to < $now;

  return wantarray ? ($text, $now) : $text;
};

any '/countdown' => sub {
  my $self = shift;
  my $to = $self->param('to')
    || $self->render( text => "Usage: /countdown?to=$format" );
  my $countdown = $self->countdown( $to );
  $self->render( text => $countdown );
};

my $next_year = gmtime->year + 1;

any '/:time' => { 'time' => $next_year } => sub {
  my $self = shift;
  my $to = $self->param('time');
  $to = $self->time($to);
  
  my ($countdown, $now) = $self->countdown( $to );

  $self->title( "Countdown to: $to" );

  $self->render('example', countdown => $countdown, now => "$now");
};

app->start;

__DATA__

@@ example.html.ep
<!DOCTYPE html>
<head>
  <title><%= title %></title>
</head>
<h2>
  %= title
</h2>
<body>
  <p>
    %= $countdown
  </p>
  <p>It is currently <%= $now %></p>
  <p>
    %= link_to q{Matt's PSGI Archive} => 'https://github.com/davorg/matts-psgi-archive/';
  <p>
</body>


