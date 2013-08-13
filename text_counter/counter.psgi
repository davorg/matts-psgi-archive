#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use Dancer;
use DBI;
use File::Spec;
use FindBin;
use Data::Dumper;

my $dbh = init_db_connection();

get '/' => sub {
    my $count = increment_and_get_count($dbh);
    return $count;
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
