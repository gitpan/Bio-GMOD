#!perl
use Config;
use File::Basename qw(&basename &dirname);
use Cwd;

$origdir = cwd;
chdir dirname($0);
$file = basename($0, '.PL','.PLS');
$file .= $^O eq 'VMS' ? '.com' : '.pl';

open OUT,">$file" or die "Can't create $file: $!";

print "Extracting $file (with variable substitutions)\n";

print OUT <<"!GROK!THIS!";
$Config{startperl}
!GROK!THIS!

# In the following, perl variables are not expanded during extraction.

print OUT <<'!NO!SUBS!';

use strict;
use Getopt::Long;
use Bio::GMOD::Update;
#use Bio::GMOD::CheckVersions;

my (@STEPS,$UPDATE_DATABASES,$UPDATE_SOFTWARE,
    @EXCLUDE,$VERSION,$SYNC_TO,$FORCE,$HELP,
    $MYSQL,$ACEDB,$TMP,$PURGE,$FTP_SITE);
GetOptions(
	    'sync_to=s'      => \$SYNC_TO, # one of live or dev
	    'force'          => \$FORCE,
	    'version=s'      => \$VERSION,
            'purge'          => \$PURGE,
            'update_databases' => \$UPDATE_DATABASES,
            'update_software'  => \$UPDATE_SOFTWARE,
            'steps=s'        => \@STEPS,
            'exclude=s'      => \@EXCLUDE,
            'mysql=s'        => \$MYSQL,
            'acedb=s'        => \$ACEDB,
            'tmp=s'          => \$TMP,
            'ftp_site=s'     => \$FTP_SITE,
	    'help'           => \$HELP);

my $USAGE = <<USAGE;
This script is a derivative of gmod_update_installation.pl, customized
for maintenence of a WormBase installation.

  % gmod_update_installation-wormbase.pl [options]

For a full description of options, see:

  % perldoc gmod_update_installation-wormbase.pl

USAGE

die $USAGE if $HELP;

$MYSQL       ||= '/usr/local/mysql/data';
$TMP         ||= '/usr/local/gmod/wormbase/releases';
$SYNC_TO     ||= 'live';
$FTP_SITE    ||= 'dev.wormbase.org',
@STEPS = split(/,/,join(',',@STEPS));

push (@STEPS,qw/acedb elegans_gff briggsae_gff blast/) if $UPDATE_DATABASES;
push (@STEPS,qw/software/) if $UPDATE_SOFTWARE;

# In essence, do $gmod->update() if @STEPS is not provided
# $gmod->update(-version => $desired_version);
push (@STEPS,qw/acedb elegans_gff briggsae_gff blast software/)
   if (!$UPDATE_DATABASES && !$UPDATE_SOFTWARE && !@STEPS);

my %steps = map { $_ => 1 } @STEPS;

my $gmod = Bio::GMOD::Update->new(-mod        => 'WormBase',
                                  -tmp_path   => $TMP,
			          -mysql_path => $MYSQL,
			          -acedb_path => $ACEDB
                                  -ftp_site   => $FTP_SITE,
                                  );

# Fetch the current live, local, and development versions of the MOD
# Each method will return a hash reference with keys of:
#      status, url, title, version, versiond

my %live  = $gmod->live_version();
my %dev   = $gmod->development_version();
my %local = $gmod->local_version();

if (keys %live < 1) {
  print "WARNING: Could not check the live versions.  You must be online to update your WormBase installation.\n";
  die;
}

print "LIVE SITE ($live{url})\n";
print "----------------------------\n";
print_keys(\%live);

print "DEV SITE ($dev{url})\n";
print "----------------------------\n";
print_keys(\%dev);

print "LOCAL INSTALLATION\n";
print "----------------------------\n";
print_keys(\%local);

# The desired version, fetched automatically or provided with --version
my $desired_version = ($SYNC_TO eq 'dev') ? $dev{version} : $live{version};
$desired_version = $VERSION if $VERSION;

# Which rsync module should we sync to?
my $rsync_module = ($SYNC_TO eq 'dev') ? 'wormbase-dev' : 'wormbase-live';

# Check to see if we are up-to-date only if we are NOT trying to force
# an install

# Synchronize software if requested (or skip if not)
do_rsync() unless (!defined $steps{software});

unless ($FORCE) {
  if ($local{version} eq $desired_version) {
    print "Your WormBase installation is up-to-date: " . $local{version} . "\n";
    exit;
  }
}

foreach (@STEPS) {
    # Assume we will be downloading
    $gmod->prepare_tmp_dir(-sync_to => $SYNC_TO) if (@STEPS > 2);

     my %steps2methods = ( acedb        => 'fetch_acedb',
                             elegans_gff  => 'fetch_elegans_gff',
                             briggsae_gff => 'fetch_briggsae_gff',
                             blast        => 'fetch_blast_blat');
     my $method = $steps2methods{$_};
     if ($_ eq 'analyze_logs') {
        $gmod->analyze_logs(-version => $desired_version,
	                    -site    => `hostname`);
      } elsif ($method) {
         $gmod->$method(-version => $desired_version);
      } else {}
}

print "Your WormBase installation is up-to-date ($desired_version)!\n";

$gmod->cleanup() if $PURGE;






###################################
# Begin subs
###################################
sub do_rsync {
  my $exclude = join(" ",map {"--exclude='$_'"} @EXCLUDE);
  $gmod->rsync_software(-module       => $rsync_module,
                        -exclude      => $exclude,
                        -install_root => '/usr/local/wormbase/',
                        );
}

sub print_keys {
  my $hash = shift;
  print "Status      : $hash->{status}\n";
  print "Title       : $hash->{title}\n";
  print "Version     : $hash->{version}\n";
  print "Released    : $hash->{released}\n\n";
}


__END__


=pod

=head1 NAME

gmod_update_installation-wormbase.pl

=head1 USAGE

 $ gmod_update_installation-wormbase.pl [options]

This script should be executed with superuser privileges.

=head1 OPTIONS

Available options include (default values in parenthesis):
 Versions and process tasks:
 --sync_to   [live || dev] Sync to the current live or dev version. (live)
 --version   Update to the provided version (if available on the server!)
 --force     [boolean] Force an update to the provided version (false)
 --purge     [boolean] Purge tmp download folder following upgrade (false)

 Update tasks:
 --update_databases [boolean] update the databases [true]
 --update_software  [boolean] update the software [true]
 --steps         [list...] Which components of the update to execute (all; see below)


 Code maintenance:
 --skip_software [boolean] Whether or not to update the software (see below)
 --exclude       [list...] Files, paths, or patterns to exclude from the rsync update (none)

 System paths:
 --mysql         Full path to the MySQL data directory (/usr/local/mysql/data)
 --tmp           Full path to the temporary directory to hold downloads (/usr/local/wormbase/tmp)
 --acedb         Full path to the acedb directory (/usr/local/acedb)
 --help          Display this message

=head1 Controlling which update steps are executed

You can broadly control which steps are executed by passing either the
--update_database and/or the --update_software flags.

If you would like more specific control, you can specify specific
steps to run during the update by passing a comma-separated list with
the "--steps" paramater.  Available steps are:

  acedb         Fetch and install the acedb database
  elegans_gff   Fetch and install the C. elegans GFF database
  briggsae_gff  Fetch and install the C. briggsae GFF database
  blast         Fetch and install the blast/blat databases
  software      Rsync the software
  analyze_logs  WormBase logs; requires Analog and ReportMagic

The --update_database flag is equivalent to "--steps
acedb,elegans_gff,briggsae_gff,blast" and the --update_software flag
is equivalent "--steps software".

If the --steps option is not specified or the --update_* options are
omitted, the following steps will be executed:

   acedb, elegans_gff, briggsae_gff, blast, software

=head1 Examples

Do an update of both software and databases

  ./gmod_update_installation-wormbase.pl \
           --sync_to live \
           --update_software \
           --update_databases

      Or more simply:

  ./gmod_update_installation-wormbase.pl \
           --sync_to live \

Fetch the most up-to-date version of the code without updating
databases:

  ./gmod_update_installation-wormbase.pl \
           --sync_to live \
           --update_software

Official mirror sites should use a command like:

  ./gmod_update_installation-wormbase.pl \
           --sync_to live \
           --update_databases \
           --update_software \
           --steps analyze_logs

Update databases without updating the software:

  ./gmod_update_installation-wormbase.pl \
           --sync_to live \
           --update_databases

=head1 Excluding files from the syncing process

If you have local files or directories stored in your WormBase
distribution, you can prevent them from being overwritten by the
update process by passing a space separated list of files/directories
with the '--exclude' option.  This options will be passed directly to
rsync.  See the rsync man page for more details.  Note that you do NOT
need to include files that contain local defaults (like localdefs.pm)
as these are exluded by default.

=head1 Running under cron

You may wish to run this script under cron to ensure that your
installation is always up-to-date.

A suggested crontab entry for a simple local installation is:

 0 2,14 * * * gmod_update_intallation.pl --sync_to live --purge 1

A suggested crontab entry for official WormBase mirror sites is:

 0 2,14 * * * gmod_update_intallation.pl --sync_to live \
        --update_databases --update_software \
        --steps analyze_logs

 
Crontab entries like these will check for updates twice a day --
including updating the software. Be sure to include any necessary
options as well, such as the path to your mysql data directory.

=head1 BUGS

None reported.

=head1 SEE ALSO

L<Bio::GMOD>, L<Bio::GMOD::Update>, L<Bio::GMOD::Update::WormBase>,
L<Bio::GMOD::Adaptor>, L<Bio::GMOD::Adaptor::WormBase>

=head1 AUTHOR

Todd W. Harris E<lt>harris@cshl.orgE<gt>.

Copyright (c) 2004-2005 Cold Spring Harbor Laboratory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


!NO!SUBS!
close OUT or die "Can't close $file: $!";
chmod 0755, $file or die "Can't reset permissions for $file: $!\n";
exec("$Config{'eunicefix'} $file") if $Config{'eunicefix'} ne ':';
chdir $origdir;
