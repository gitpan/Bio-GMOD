package Bio::GMOD::Adaptor::WormBase;

use strict;
use vars qw/@ISA $AUTOLOAD/;
use Bio::GMOD::Adaptor;
use Bio::GMOD::Util::Rearrange;

@ISA = qw/Bio::GMOD::Adaptor/;

# Bio::GMOD::Adaptor::* can optionally read defaults and current versions
# from CGI scripts If not provided, the corresponding values can be
# overridden either as constants or as options passed to the new()
# method.

my %DEFAULTS = (		
		# DEFAULTS_CGI (optional)
		# A CGI script that provides these same values
		# Full URL to CGI that delivers key value pairs of these options This
		# is optional but lets you quickly change paths to system
		# resources. Moreover, these changes willl be invisible to end user.s
		# If not provided -- or if user is working offline -- these values
		# will be populated from this module.
		DEFAULTS_CGI => 'http://dev.wormbase.org/db/gmod/defaults',
		
		# NAME (required)
		# Symbolic name of the MOD / Adaptor
		NAME             => 'WormBase',

		# LIVE_NAME, LIVE_URL, LIVE_DESCRIPTION (required)
		# Live public server variables
		LIVE_NAME        => 'WormBase live server',
		LIVE_URL         => 'http://www.wormbase.org',
		LIVE_DESCRIPTION => 'The WormBase live public server',
		
		# DEVELOPMENT_NAME, DEVELOPMENT_URL, DEVELOPMENT_DESCRIPTION (optional)
		# Development server variables, if applicable
		DEVELOPMENT_NAME => 'WormBase development server',
		DEVELOPMENT_URL  => 'http://dev.wormbase.org',
		DEVELOPMENT_DESCRIPTION => 'The WormBase semi-public development server',		
		
		# VERSION_CGI_LIVE, VERSION_CGI_DEV (optional, but recommended!)
		# If you would like to provide your users a convenient
		# mechanism for fetching versions specify one or both
		# of these variables. At WormBase, the version cgi
		# checks the local verison of the database and returns
		# a string.  This script is available in the cgi-bin/
		# directory.
		VERSION_CGI_DEV  => 'http://dev.wormbase.org/db/gmod/version',
		VERSION_CGI_LIVE => 'http://www.wormbase.org/db/gmod/version',

		# Suitable local paths for WormBase
		ACEDB_PATH     => '/usr/local/acedb/elegans',  # This will actually be a symlink
		MYSQL_PATH     => '/usr/local/mysql/data',
		TMP_PATH       => '/usr/local/gmod/wormbase/releases',
		INSTALL_ROOT   => '/usr/local/wormbase',
		
		# Remote paths:
		FTP_SITE      => 'dev.wormbase.org',
		FTP_ROOT      => '/usr/local/ftp',   # full local path
		FTP_PATH      => '/pub/wormbase/mirror/database_tarballs',  # Relative

                # Where to find prepackaged databases
                DATABASE_REPOSITORY => '/pub/wormbase/mirror/database_tarballs',
                DATABASE_REPOSITORY_STABLE => '/pub/wormbase/mirror/database_tarballs/stable',

                # Tarball filenames
                ACEDB_TARBALL        => 'elegans_%s.ace.tgz',
                ELEGANS_GFF_TARBALL  => 'elegans_%s.gff.tgz',
                BRIGGSAE_GFF_TARBALL => 'briggsae_%s.gff.tgz',
                BLAST_TARBALL        => 'blast_%s.tgz',

                # Disk space requirements (GB)
                ACEDB_DISK_SPACE        => '10',
                ELEGANS_GFF_DISK_SPACE  => '3.5',
                BRIGGSAE_GFF_DISK_SPACE => '5',
                BLAST_DISK_SPACE        => '0.5',

		# Software updating
		RSYNC_URL       => 'rsync://dev.wormbase.org',
		RSYNC_MODULE    => 'wormbase-live',
		CVS_ROOT      => ':pserver:anonymous@brebiou.cshl.org:/usr/local/cvs',
		
		# PACKAGE PATHS (LOCAL) (NOT YET SYNCED WITH CGI)
		# Suitable constants for creating packages
		# PACKAGE_PATH   => (getpwnam('ftp'))[7]   . '/pub/wormbase/database_tarballs',
		# LOCAL_PACKAGE_PATH => (getpwnam('ftp'))[7]   . '/pub/wormbase/database_tarballs',
		# CURRENT_PACKAGE_SYMLINK => (getpwnam('ftp'))[7]   . '/pub/wormbase/database_tarballs/current_release',
		
		# Constants for archiving
		CURRENT_RELEASE => (getpwnam('ftp'))[7]   . '/pub/wormbase/elegans-current_release',

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
