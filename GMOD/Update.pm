package Bio::GMOD::Update;

use strict;
use vars qw/@ISA $AUTOLOAD/;

use Bio::GMOD;
use Bio::GMOD::Util::Mirror;
use Bio::GMOD::Util::CheckVersions;
use Bio::GMOD::Util::Rearrange;


@ISA = qw/Bio::GMOD Bio::GMOD::Util::CheckVersions/;

# Currently, there is no generic update method.  Bio::GMOD::Update
# must be subclassed for your particular MOD

sub update {
  my $self = shift;
  my $adaptor = $self->adaptor;
  my $name = $adaptor->name;

  $self->logit("$name does not currently support automated updates at this time. Please ask the administrators of $name to add this functionality.",
	       -die => 1);
}


# MORE TWEAKS NEEDED - configuration, verbosity, etc
sub mirror {
  my ($self,@p) = @_;
  my ($remote_path,$local_path,$is_optional) = rearrange([qw/REMOTE_PATH LOCAL_PATH IS_OPTIONAL/],@p);
  my $adaptor = $self->adaptor;
  $local_path ||= $adaptor->tmp_path;
  $self->logit(-msg => "Must supply a local path in which to download files",
	       -die => 1) unless $local_path;
  my $ftp = Bio::GMOD::Util::Mirror->new(-host      => $adaptor->ftp_site,
					 -path      => $remote_path,
					 -localpath => $local_path,
					 -verbose   => 1);
  my $result = $ftp->mirror();

  # TODO: Clear out the local directory if mirroring fails
  # TODO: Resumable downloads.
  if ($result) {
    $self->logit(-msg     => "$remote_path successfully downloaded");
  } else {
    return 0 if $is_optional;
    $self->logit(-msg         => "$remote_path failed to download: $!",
		 -die         => 1);
  }
  return 1;
}

sub prepare_tmp_dir {
  my $self     = shift;
  my $adaptor  = $self->adaptor;
  my $version  = $adaptor->version;
  my $tmp_path = $adaptor->tmp_path;

  $self->logit(-msg => "Creating temporary directory at $tmp_path");
  unless (-e "$tmp_path/$version") {
    my $command = <<END;
mkdir -p $tmp_path/$version
chmod -R 0775 $tmp_path
END
;
  my $result = system($command);
    if ($result == 0) {
      $self->logit(-msg => "Successfully created temporary directory");
    } else {
      $self->logit(-msg => "Cannot make temporary directory: $!",
		   -die => 1);
    }
  }
}



sub cleanup {
  my $self = shift;
  my $tmp = $self->tmp_path;
  $self->logit(-msg => "Cleaning up $tmp");
  system("rm -rf $tmp/*");
}


#########################################################
# Rsync tasks
#########################################################
# Install path should have a trailing slash
sub rsync_software {
  my ($self,@p) = @_;
  my ($rsync_module,$exclude,$install_root) = rearrange([qw/MODULE EXCLUDE INSTALL_ROOT/],@p);
  my $adaptor     = $self->adaptor;
  $adaptor->parse_params(@p);
  $install_root ||= $adaptor->install_root;
  $rsync_module .= '/' unless ($rsync_module =~ /\/$/);  # Add trailing slash

  my $rsync_url   = $adaptor->rsync_url;
  $rsync_module ||= $adaptor->rsync_module;
  my $rsync_path   = $rsync_url . ($rsync_module ? "/$rsync_module" : '');
  print "$install_root $rsync_module $exclude $rsync_path\n";
  my $result = system("rsync -rztpvl $exclude $rsync_path $install_root");
  $self->test_for_error($result,"Rsync'ing the WormBase mirror");
}

__END__


=pod

=head1 NAME

Bio::GMOD::Update - Generics methods for updating a Bio::GMOD installation

=head1 SYNOPSIS

  # Update your Bio::GMOD installation
  use Bio::GMOD::Update;
  my $mod = Bio::GMOD::Update->new(-mod => 'WormBase');
  $mod->update(-version => 'WS136');

=head1 DESCRIPTION

Bio::GMOD::Update contains subroutines that simplify the maintenance
of a Bio::GMOD installation.

=head1 PUBLIC METHODS

=over 4

=item $mod = Bio::GMOD::Update->new()

The generic new() method is provided by Bio::GMOD.pm.  new() provides
the ability to override system installation paths.  If you have a
default installation for your MOD of interest, this should not be
necessary. You will not normally interact with Bio::GMOD::Update
objects, but instead with Bio::GMOD::Update::"MOD" objects.

See Bio::GMOD.pm and Bio::GMOD::Adaptor::* for a full description of
all default paths for your MOD of interest.

=item $mod->update(@options)

update() is a wrapper method overriden by Bio::GMOD::Update::"MOD"
update().  The update() method should return an array of all
components installed as well as have the package variable "status"
set.

=item $mod->cleanup()

Delete the contents of the temporary directory following an update.
See Bio::GMOD::Update::* for how this method might affect you!

=item $self->prepare_tmp_dir

Prepare the temporary directory for downloading.

=item $self->mirror(@options);

Generic mirroring of files or directories (recursively)

=back

=head1 BUGS

None reported.

=head1 SEE ALSO

L<Bio::GMOD>, L<Bio::GMOD::Util::CheckVersions>

=head1 AUTHOR

Todd W. Harris E<lt>harris@cshl.eduE<gt>.

Copyright (c) 2003-2005 Cold Spring Harbor Laboratory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


1;












