package Bio::GMOD::Adaptor::WormBase;

use strict;
use vars qw/@ISA $VERSION $AUTOLOAD/;
use Bio::GMOD::Adaptor;
use Bio::GMOD::Util::Rearrange;

@ISA = qw/Bio::GMOD::Adaptor/;

$VERSION = '0.01';

# Bio::GMOD::Adaptor::* can optionally read defaults and current versions
# from CGI scripts If not provided, the corresponding values can be
# overridden either as constants or as options passed to the new()
# method.

my %DEFAULTS = (		
		# A CGI script that provides these same values
		# Full URL to CGI that delivers key value pairs of these options This
		# is optional but lets you quickly change paths to system
		# resources. Moreover, these changes willl be invisible to end user.s
		# If not provided -- or if user is working offline -- these values
		# will be populated from this module.
		DEFAULTS_CGI => 'http://dev.wormbase.org/db/gmod/defaults',

		# Live, public server variables
		NAME             => 'WormBase',
		LIVE_URL         => 'http://www.wormbase.org',
		LIVE_DESCRIPTION => 'The WormBase live public server',
		
		# Development server variables, if applicable
		DEVELOPMENT_URL  => 'http://dev.wormbase.org',
		DEVELOPMENT_DESCRIPTION => 'The WormBase semi-public development server',		

		# If You would like to provide your users a convenient mechanism for
		# fetching versions specify on or both of these variables. At WormBase,
		# the dump_version cgi simply checks the local verisonof the database
		# and returns a string.  This script is available in the etc/ directory.
		VERSION_CGI_DEV  => 'http://dev.wormbase.org/db/gmod/version',
		VERSION_CGI_LIVE => 'http://www.wormbase.org/db/gmod/version',

		# Software updating
		RSYNC_URL       => 'rsync://dev.wormbase.org',
		RSYNC_MODULE    => 'wormbase-live',
		# CVS_ROOT      => ':pserver:anonymous@brebiou.cshl.org:/usr/local/cvs',
		
		# Local paths
		MYSQL_PATH     => '/usr/local/mysql/data',
		TMP_PATH       => '/usr/local/gmod/wormbase/releases',
		INSTALL_ROOT   => '/usr/local/wormbase',

		# Packaging constants
		PACKAGE_URL  => 'http://dev.wormbase.org',  # Host that serves up the packages

		# PACKAGE PATHS (LOCAL)
		LOCAL_PACKAGE_PATH => (getpwnam('ftp'))[7]   . '/pub/wormbase/database_tarballs',
		CURRENT_PACKAGE_SYMLINK => (getpwnam('ftp'))[7]   . '/pub/wormbase/database_tarballs/current_release',
		
		# Suitable constants for creating packages
		# PACKAGE_PATH   => (getpwnam('ftp'))[7]   . '/pub/wormbase/database_tarballs',
		
		# Some local paths specific to WormBase
		ACEDB_PATH   => '/usr/local/acedb/elegans',  # This should actually be a symlink

		# REMOTE FTP PATHS:
		FTP_SITE      => 'caltech.wormbase.org',
		FTP_SITE      => 'dev.wormbase.org',
		FTP_ROOT      => '/usr/local/ftp',
		FTP_PATH      => '/pub/wormbase/database_tarballs',
		FTP_LIBRARIES => '/pub/wormbase/software/macosx/libraries',

		# Constants for archiving
		CURRENT_RELEASE => (getpwnam('ftp'))[7]   . '/pub/wormbase/elegans-current_release',
		# GENE_DUMPS      => $DEFAULTS{CURRENT_RELEASE} . '/GENE_DUMPS',
	       );



sub defaults {
  my $self = shift;
  return (keys %DEFAULTS);
}


# Automatically create lc data accessor methods
# for each configuration variable
sub AUTOLOAD {
  my $self = shift;
  my $attr = $AUTOLOAD;
  $attr =~ s/.*:://;
  return unless $attr =~ /[^A-Z]/;  # skip DESTROY and all-cap methods
  return if $attr eq 'new'; # Provided by superclass
  #  die "invalid attribute method: ->$attr()" unless $DEFAULTS{uc($attr)};
  $self->{uc($attr)} = shift if @_;
  my $val = $self->{defaults}->{lc($attr)};  # Get what is already there
  $val ||= $DEFAULTS{uc($attr)};  # Perhaps it hasn't been defined yet.
  return $val;
}


#######################################################
#  PACKAGING-SPECIFIC SUBROUTINES
#######################################################
## THESE SUBROUTINES ARE ALL NOW PART OF ARCHIVE

# MOD specific packaging of a data release
# At WormBase, we prepare simple tarballs of ACeDB and MySQL databases
# for the convenience of our users
#sub build_package {
#  my ($self,@p) = @_;
#  my ($to_package,$rebuild) = rearrange([qw/RELEASE REBUILD/],@p);

#  # First, we check the currently installed version of the database
#  my $current_db = $self->local_version();

#  # Is the requested version on the server?
#  if ($to_package) {
#    if ($to_package ne $current_db) {
#      return "The currently installed version ($installed) does not match the requested package build ($release). Package not created.";
#    }
#  } else {
#    $to_package = $current_db;
#  }
  
#  # Check to see if this release has already been packaged
#  my $current_package = $self->package_version();
#  if ($current_package eq $to_package && !$rebuild) {
#    return "$to_package has already been packaged. Pass the --rebuild option to build_package() to rebuild"
#  }
  
#  $self->{to_package} = $to_package;
#  $self->package_acedb()          or die "Couldn't package acedb database for $new_ws: $!\n";
#  $self->package_elegans_gff()    or die "Couldn't package elegans GFF database for $new_ws: $!\n";
#  $self->package_briggsae_gff()   or die "Couldn't package briggsae GFF database for $new_ws: $!\n";
#  $self->package_blast()          or die "Couldn't package blast/blat databases for $new_ws: $!\n";
#  $self->adjust_symlink()         or die "Couldn't adjust symlinks to new database tarballs for $new_ws: $!\n";
#  $self->do_archive()             or die "Couldn't do archiving for $new_ws: $!\n";
#}



## These are all WormBase specific subroutines
## for the Bio::GMOD module they should all be contained in their own
## adaptor space
## Acedb
#sub package_acedb {
#  my $self     = shift;
#  my $tarballs = LOCAL_PACKAGE_PATH;
#  my $new_ws   = $self->{to_package};
#  my $base = "$tarballs/$new_ws";
#  my $command = <<END;
#mkdir -p $base
#tar -czf $base/elegans_${new_ws}.ace.tgz -C /usr/local/acedb elegans_${new_ws} --exclude 'database/oldlogs' --exclude 'database/serverlog.wrm*' --exclude 'database/log.wrm'
#END
#;

#system($command) == 0 or return 0;
#return 1;
#}


#sub package_elegans_gff {
#  my $self     = shift;
#  my $tarballs = LOCAL_PACKAGE_PATH;
#  my $new_ws   = $self->{to_package};
#  my $base = "$tarballs/$new_ws";
#my $command = <<END;
#mkdir -p $base
#tar -czf $base/elegans_${new_ws}.gff.tgz -C ${mysql_data} elegans elegans_pmap --exclude '*bak*'
#END
#;

#system($command) == 0 or return 0;
#return 1;
#}

#sub package_briggsae_gff {
#  my $self     = shift;
#  my $tarballs = LOCAL_PACKAGE_PATH;
#  my $new_ws   = $self->{to_package};
#  my $base = "$tarballs/$new_ws";
#  my $command = <<END;
#mkdir -p $base
#tar -czf $base/briggsae_${new_ws}.gff.tgz -C ${mysql_data} briggsae --exclude '*bak*'
#END
#;

#system($command) == 0 or return 0;
#return 1;
#}

#  # package up the blast and blat databases together
#  sub package_blast {
#  my $self     = shift;
#  my $tarballs = LOCAL_PACKAGE_PATH;
#  my $new_ws   = $self->{to_package};
#  my $base = "$tarballs/$new_ws";
#  my $command = <<END;
#mkdir -p $base
#tar -czf $base/blast.${new_ws}.tgz -C /usr/local/wormbase/blast blast_${new_ws} -C /usr/local/wormbase blat --exclude 'old_nib' --exclude  'CVS'
#END
#;

#system($command) == 0 or return 0;
#return 1;
#}


#sub adjust_symlink {
#  my $self     = shift;
#  my $tarballs = LOCAL_PACKAGE_PATH;
#  my $new_ws   = $self->{to_package};
#  # Will I *remain* in this directory?
#  chdir($tarballs);
#  unlink("$tarballs/current_release");
#  symlink("$new_ws","$tarballs/current_release");
#}


__END__

=pod

=head1 NAME

Bio::GMOD::Adaptor::WormBase - Defaults for programmatically interacting with Wormbase

=head1 SYNPOSIS

  my $adaptor = Bio::GMOD::Adaptor::WormBase->new();

=head1 DESCRIPTION

Bio::GMOD::Adaptor::WormBase objects are created internally by the new()
method provided by Bio::GMOD::Adaptor.  Adaptor::* objects contain
appropriate defaults for interacting programmatically with the GMOD of
choice.

Defaults are read dynamically from the WormBase server at runtime.
This helps to insulate your scripts from changes in the WormBase
infrastructure.  If using Bio::GMOD offline, defaults will be
populated from those hard-coded in this adaptor.  You may also supply
these defaults as hash=>key pairs to the new method.

For descriptions of all currently known parameters, see
Bio::GMOD::Adaptor::WormBase.pm or the default list maintained at
http://dev.wormbase.org/db/gmod/defaults

=head1 BUGS

None reported.

=head1 SEE ALSO

L<Bio::GMOD>

=head1 AUTHOR

Todd W. Harris E<lt>harris@cshl.eduE<gt>.

Copyright (c) 2003-2005 Cold Spring Harbor Laboratory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut



1;
