#!/usr/bin/perl

# filename: version.wormbase.cgi
# Author: T. Harris
# A simple script to report the state of the current database

use lib '../lib';
use CGI 'param','header','path_info';
use Ace;
use Ace::Browser::AceSubs;
use ElegansSubs;
use strict;

use vars qw($DB);
$DB = OpenDatabase() || AceError("Couldn't open database.");

print header('text/plain');

my $to_display = { database => { title=>1,version  =>1,release=>1},
		   #		code     => { version=>1,build =>1},
		   #		resources=> { memory=>1,classes=>1},
		 };

my %status  = $DB->status;
my $version = $status{database}->{version};
my $title   = $status{database}->{title};

# Fetch the modtime of the current release.
my @temp = stat('/usr/local/acedb/' . "elegans_$version");
my $modtime = localtime($temp[9]);

# Fetch the modtime of the package release
my @package_temp = stat('/usr/local/ftp/pub/wormbase/database_tarballs/' . "$version");
my $package_modtime = localtime($package_temp[9]);


print "title=WormBase, the $title\n";
print "version=$version\n";
print "released=$modtime\n";
print "package_version=$package_modtime\n" if $package_modtime;

exit 0;