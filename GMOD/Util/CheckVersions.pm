package Bio::GMOD::Util::CheckVersions;
use strict;

use Bio::GMOD;
use Bio::GMOD::Util::Rearrange;
use LWP::UserAgent;

use vars qw/@ISA/;

@ISA = qw/Bio::GMOD/;

sub live_version {
  my ($self,@p) = @_;
  my $adaptor = $self->adaptor;
  my $response = _check_version_cgi($adaptor->live_url,$adaptor->version_cgi_live);
  return (wantarray ? %$response : $response->{version});
}


sub development_version {
  my ($self,@p) = @_;
  my $adaptor = $self->adaptor;
  unless ($adaptor->development_url) {
    return (wantarray ? ( site => 'no development server specified' ) : 'no development server specified');
  }
  my $response = _check_version_cgi($adaptor->development_url,$adaptor->version_cgi_dev);
  return (wantarray ? %$response : $response->{version});
}

sub mirror_version {
  my ($self,@p) = @_;
  my ($site,$cgi) = rearrange([qw/SITE CGI/],@p);
  my $adaptor = $self->adaptor;
  $site =~ s/\/$//;
  my $response = _check_version_cgi($site,"$site/$cgi");
  return (wantarray ? %$response : $response->{version});
}


sub local_version {
  # LOCAL VERSION SHOULD BE SUPPLIED BY CheckVersions subclass
}

# Placeholder - not sure if I am going to implement this
sub package_version {
}



# PRIVATE METHODS

sub _check_version_cgi {
  my ($site,$url) = @_;
  # Version script holds a simple cgi that dumps out the
  # title, release date, and version of the database
  $url ||= $site;
  my $ua  = LWP::UserAgent->new();
  $ua->agent('Bio::GMOD::Util::CheckVersions/$VERSION');
  my $request = HTTP::Request->new('GET',$url);
  my $response = $ua->request($request);
  my %response;
  if ($response->is_success) {
    # Parse out the content
    my $content = $response->content;
    my @lines = split("\n",$content);
    foreach (@lines) {
      my ($key,$val) = split("=");
      chomp $val;
      $response{$key} = $val;
    }
    $response{status} = "SUCCESS";
  } else {
    $response{error} = "FAILURE: Couldn't check version: " . $response->status_line;
  }
  $response{url} = $site;
  return \%response;
}



__END__



=pod

=head1 NAME

Bio::GMOD::Util::CheckVersions - find current versions of GMOD installations

=head1 SYNOPSIS

  use Bio::GMOD::Util::CheckVersions;
  my $gmod   = Bio::GMOD::Util::CheckVersions->new(-mod => 'WormBase');
  my $live   = $gmod->live_version();
  my $dev    = $gmod->development_version();
  my $local  = $gmod->local_version();

=head1 DESCRIPTION

Bio::GMOD::Util::CheckVersions provides several methods for determining the
current live and development versions of a MOD. In addition it
includes several methods for fetching locally installed version as
well as versions of installed packages, useful for updating and
archiving purposes.

By providing live_url annd version_cgi_live in the MOD adaptor
defaults -- as well as installing a suitable CGI, no additional
subclassing will be necessary. Likewise, to provide easy access to
development versions, provide the development_url and version_cgi_dev
variables.

Alternatively, you may provide custom methods for live_version,
development_version, and local_version by subclassing
Bio::GMOD::Util::CheckVersions, using the name of the MOD.

=head2 PUBLIC METHODS

=head3 CHECKING REMOTE VERSIONS

=over 4

=item Bio::GMOD::Util::CheckVersions->new(-mod => 'WormBase')

Create a new Bio::GMOD::Util::CheckVersions object.

=item $mod->live_version()

Fetch the version of the current live release. Called in scalar
context, this method returns the corresponding version; otherwise it
returns a hash with keys of:

   status        The status of the version check request
   url           The URL of the site checked
   title         The title of the database
   description   A brief description of the MOD
   version       The installed version at the site
   released      The date the current version was released

live_version() fetches the version from the master WormBase site at
www.wormbase.org,

=item $mod->development_version()

Fetch the version of the current development release.  Behaves as
live_version() described above but for the development server of the
current MOD, if one exists.  Called in scalar context,
development_version() returns the version, otherwise it returns the
same hash described for live_version();

=item $mod->mirror_version(-site=>http://www.wormbase.org')

Check the version and release date for any of the generic mirror
site. Called in scalar context, mirror_version() returns the
installed version, otherwise it returns the same hash described for
live_version();

 Required options:
 -site   url for site to fetch the version from (http://caltech.wormbase.org/)
 -cgi    the relative path to the version CGI (ie /cgi-bin/version)

=back

=head3 CHECKING LOCAL VERSIONS

=over 4

=item $mod->local_version()

local_version() should be supplied by a MOD specific CheckVersions
subclass.

=back

=head2 PRIVATE METHODS

=over 4

=item _check_version_cgi($site,$path_to_cgi);

Check the version at the provided site returning a hash of status,
title, version, released, and site. This subroutine relies on the
small CGI script located at /db/util/dump_version on each site.

=back

=head1 BUGS

None reported.

=head1 SEE ALSO

L<Bio::GMOD>

=head1 AUTHOR

Todd Harris E<lt>harris@cshl.eduE<gt>.

Copyright (c) 2003-2005 Cold Spring Harbor Laboratory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;
