#!/usr/bin/perl

# filename: wormbase.pm.defaults
# Author: T. Harris
# This simple CGI collects default values for
# those using WormBase.pm

# In particular, it includes paths for building and installing
# WormBase packages.

use lib '../lib';
use CGI 'param','header','path_info';
use Ace;
use Ace::Browser::AceSubs;
use ElegansSubs;
use strict;

use vars qw($DB);
$DB = OpenDatabase() || AceError("Couldn't open database.");

print header('text/plain');
print "# WormBase Site Defaults\n";
print "# This information is used for automated package building and installing\n";

print "#######################################\n";
print "# SERVERS\n";
print "#######################################\n";
print "# The WormBase live server\n";
print "LIVE_URL=http://www.wormbase.org\n";
print "LIVE_DESCRIPTION=The primary WormBase public server\n";
print "VERSION_CGI_LIVE=http://www.wormbase.org/db/gmod/version\n";


print "# Various constants used for packaging and versioning\n";
print "DEVELOPMENT_URL=http://dev.wormbase.org\n";
print "DEVELOPMENT_DESCRIPTION=The WormBase semi-public development server\n";
print "VERSION_CGI_DEV=http://dev.wormbase.org/db/gmod/version\n";


print "PACKAGE_URL=http://dev.wormbase.org\n";


print "#######################################\n";
print "# LOCAL PATHS\n";
print "#######################################\n";
print "# Full path to the local acedb installation.\n";
print "# This should actually be a symlink pointing to the current elegans_WSXXX release\n";
print "ACEDB_PATH=/usr/local/acedb\n";
print "MYSQL_PATH=/usr/local/mysql/data\n";
print "TMP_PATH=/usr/local/gmod/wormbase/releases\n";


print "#######################################\n";
print "# PACKAGE PATHS\n";
print "#######################################\n";
print "ARCHIVE_PATH='/usr/local/ftp/pub/wormbase/database_tarballs\n";
#print "CURRENT_PACKAGE_SYMLINK=/usr/local/ftp/pub/wormbase/database_tarballs/current_release\n";

print "#######################################\n";
print "# REMOTE PATHS\n";
print "#######################################\n";
print "FTP_SITE=dev.wormbase.org\n";
print "FTP_ROOT=/usr/local/ftp\n";
print "FTP_BASE=/pub/wormbase\n";

# Repositories may or may not be on the FTP site.
# This is particualtyltrue archived versions of WormBase
print "DATABASE_REPOSITORY=/pub/wormbase/mirror/database_tarballs\n";
print "DATABASE_REPOSITORY_STABLE=/pub/wormbase/mirror/database_tarballs/stable\n";

# DEPRECATED....
print "LIBRARY_REPOSITORY=/pub/wormbase/software/macosx/libraries\n";

# NOT YET IN USE
print "ARCHIVE_REPOSITORY=/pub/wormbase/archive\n";

print "#######################################\n";
print "# CVS PATHS\n";
print "#######################################\n";
print 'CVS_ROOT=:pserver:anonymous@brebiou.cshl.org:/usr/local/cvs' . "\n";


print "#######################################\n";
print "# ARCHIVING CONSTANTS\n";
print "#######################################\n";
print "CURRENT_RELEASE=/pub/wormbase/elegans-current_release\n";

#use constant GENE_DUMPS      => CURRENT_RELEASE . '/GENE_DUMPS';


print "#######################################\n";
print "# TARBALL FILENAMES\n";
print "#######################################\n";
print "ACEDB_TARBALL=elegans_%s.ace.tgz\n";
print "ELEGANS_GFF_TARBALL=elegans_%s.gff.tgz\n";
print "BRIGGSAE_GFF_TARBALL=briggsae_%s.gff.tgz\n";
print "BLAST_TARBALL=blast_%s.tgz\n";


exit 0;
