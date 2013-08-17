#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Dancer;
use DBI;
use File::Spec;
use FindBin;
use Imager;
use Imager::File::PNG;
use URI;

my $dbh = init_db_connection();

get '/' => sub {
    my $count = increment_and_get_count($dbh);
    return count_to_image($count);
};

dance;

#######################################

sub init_db_connection {
    # connect to the SQLite database
    my $counter_db_file = File::Spec->catfile($FindBin::Bin, 'counter.db');
    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=${counter_db_file}", # data source
        "",                                     # username
        "",                                     # password
        { RaiseError => 1 },                    # throw exceptions on failure
    ) or die "Failed to connect to SQLite DB: $DBI::errstr";

    # maybe initialize
    maybe_initialize_db($dbh);

    return $dbh;
}

sub maybe_initialize_db {
    my $dbh = shift;

    $dbh->do("CREATE TABLE IF NOT EXISTS Count(count INT DEFAULT 0);");

    my $sth = $dbh->prepare("SELECT count FROM Count;");
    $sth->execute();
    if (!$sth->fetchrow()) {
        $dbh->do("INSERT INTO Count VALUES(0)");
    }

    return;
}

sub increment_and_get_count {
    my $dbh = shift;

    $dbh->do("UPDATE Count SET count = count + 1;");

    my $sth = $dbh->prepare("SELECT count FROM Count;");
    $sth->execute();
    my ($count) = $sth->fetchrow();

    return $count;
}

sub count_to_image {
    my $count = shift;

    my $width = 20 * length($count);

    my $image = Imager->new(
        xsize => $width,
        ysize => 30,
        channels => 4
    );
    $image->box(filled => 1, color => '#FFFFFF');

    my $font_file = File::Spec->catfile($FindBin::Bin, 'Ubuntu-L.ttf');
    my $font = Imager::Font->new(
        file => $font_file,
        color => '#000000',
        size => 30
    );

    $image->align_string(
        string => "$count",
        font => $font,
        x => 5,
        y => 15,
        halign => 'left',
        valign => 'center',
        aa => 1, # anti-aliasing
    ) or die $image->errstr;

    my $image_data;
    $image->write(type => 'png', data => \$image_data)
        or die $image->errstr;

    my $URI = URI->new("data:");
    $URI->media_type("image/png");
    $URI->data("$image_data");

    return "<img src='$URI' alt='Counter: $count'>";
}
