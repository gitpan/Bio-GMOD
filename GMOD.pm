package Bio::GMOD;

# Perl subroutines for unifying data access across MODs 
# Includes some maintenance utilites to assist MOD 
# in packaging and distributing their databases.

use strict;
use warnings;
use vars qw/@ISA $VERSION/;

use Bio::GMOD::Util::Status;
use Bio::GMOD::Util::Rearrange;

@ISA = qw/Bio::GMOD::Util::Status/;

$VERSION = '0.01';

sub new {
  my ($self,@p) = @_;
  my ($mod,$species,$organism,$overrides) = rearrange([qw/MOD SPECIES ORGANISM/],@p);
  $self->logit(-msg => "You must provide either a MOD, a species, or an organism.",
	       -die => 1)
    unless $mod || $species || $organism;
  $mod = $self->species2mod($species) if $species;
  $self->logit(-msg => "The species $species is not a currently available MOD.",
	       -die => 1) unless $mod;

  $mod = $self->organism2mod($organism) if $organism;
  $self->logit(-msg => "The organism $organism is not a currently available MOD.",
	       -die => 1) unless $mod;

  my $adaptor_class = "Bio::GMOD::Adaptor::$mod";
  eval "require $adaptor_class" or $self->logit(-msg=>"Could not subclass $adaptor_class: $!",-die=>1);
  my $adaptor = $adaptor_class->new($overrides);
  my $name = $adaptor->name;

  my $this = {};

  # Establish generic subclassing for the various top level classes
  # This assumes that none of these subclasses will require their own new()
  my $subclass = "$self" . "::$name";
  if ($name && eval "require $subclass" ) {
    bless $this,$subclass;
  } else {
    bless $this,$self;
  }
  $this->{adaptor} = $adaptor;
  $this->{mod}     = $mod;
  return $this;
}


sub species2mod {
  my ($self,$provided_species) = @_;
  my %species2mod = (
		     elegans  => 'WormBase',
		     briggsae => 'WormBase',
		     remanei  => 'WormBase',
		     japonica => 'WormBase',
		     melanogaster => 'FlyBase',
		     cerevisae => 'SGD',
		    );
  return ($species2mod{$provided_species}) if defined $species2mod{$provided_species};

  # Maybe someone has used Genus species or G. species
  foreach my $species (keys %species2mod) {
    return $species if ($provided_species =~ /$species/);
  }
  return 0;
}

sub organism2mod {
  my ($self,$organism) = @_;
  my %organism2mod = (
		     worm      => 'WormBase',
		     nematode  => 'WormBase',
		     fruitfly  => 'FlyBase',
		     fly       => 'FlyBase',
		     yeast     => 'SGD',
		    );
  return ($organism2mod{$organism}) if defined $organism2mod{$organism};
  return 0;
}

# Return the appropriate adaptor object
sub adaptor { return shift->{adaptor}; }
sub mod     { return shift->{mod};     }

1;

=pod

=head1 NAME

Bio::GMOD - Unified API across Model Organism Databases

=head1 SYNOPSIS

Check the installed version of a MOD

  use Bio::GMOD::Util::CheckVersions.pm
  my $gmod    = Bio::GMOD::Util::CheckVersions->new(-mod=>'WormBase');
  my $version = $gmod->live_version;

Update a MOD installation

  use Bio::GMOD::Update;
  my $gmod = Bio::GMOD::Update->new(-mod=>'WormBase');
  $gmod->update();

Build archives of MOD releases (coming soon...)

Do some common datamining tasks (coming soon...)

=head1 DESCRIPTION

Bio::GMOD is a unified API for accessing various Model Organism Databases.
It is a part of the Generic Model Organism Database project, as well
as distributed on CPAN.

MODs are highly curated resources of biological knowledge. MODs
typically incorporate the typical information found at common
community sites such as NCBI.  However, they greatly extend this
information, placing it within a framework of experimental and
published observations of biological function gleaned from experiments
in model organisms.

Given the great proliferation of MODs, cross-site data mining
strategies have been difficult to implement.  Furthermore, the
quickly-evolving nature of these projects have made installing a MOD
locally and keeping it up-to-date a delicate and time-consuming
experience.

Bio::GMOD aims to solve these problems by:

   1.  Making MODs easy to install
   2.  Making MODs easy to upgrade
   3.  Enabling cross-MOD data mining through a unified API
   4.  Insulating programmatic end users from model changes

=head1 NOTES FOR DEVELOPERS

Bio::GMOD.pm uses a generically subclass-able architecture that lets
MOD developers support various features as needed or desired.  For
example, a developer may wish to override the default methods for
Update.pm by building a Bio::GMOD::Update::FlyBase package that
provides an update() method, as well as various supporting methods.

Currently, the only participating MOD is WormBase.  The authors hope
that this will change in the future!

=head1 PUBLIC METHODS

=over 4

=item Bio::GMOD->new(@options)

 Name          : new()
 Status        : public
 Required args : mod || organism || species
 Optional args : hash of system defaults to override
 Returns       : Bio::GMOD::* object as appropriate, with embedded 
                 Bio::GMOD::Adaptor::* object

Bio::GMOD->new() is the generic factory new constructor for all of
Bio::GMOD.pm (with the exception of Bio::GMOD::Adaptor, discussed
elsewhere).  new() will create an object of the appropriate class,
including dynamic subclassing when necessary, as well as initializing
an appropriate default Bio::GMOD::Adaptor::* object.

 Required options:
 You must provide one of the following three arguments:
 -mod       The symbolic name of the MOD to use (WormBase, FlyBase, SGD, etc)
 -species   A species to use (inc case you don't know the symbolic name)
 -organism  Even more generic, you can also specify an organism (ie 'worm')

Any additional options, passed in the named parameter "-name => value"
style will automatically be considered to be default values specific
to the MOD adaptor of choice.  These values will be parsed and loaded
into the Bio::GMOD::Adaptor::"your_mod" object.  A corresponding accessor
method (ie $adaptor->name) will be generated.  See Bio::GMOD::Adaptor for
additional details.

=item $self->species2mod($species);

 Name          : species2mod($species)
 Status        : public
 Required args : a species name
 Optional args : none
 Returns       : a MOD name as string

Provided with a single species, return the most appropriate MOD name.
Species can be in the form of "G. species", "Genus species", or simple
"species" for the lazy.

  eg:
  my $mod = $self->_species2mod('elegans');
  # $mod contains 'WormBase'

=item $self->organism2mod($organism)

 Name          : organism2mod($organism)
 Status        : public
 Required args : a general organism name
 Optional args : none
 Returns       : a MOD name as string

Like species2mod(), _organism2mod translates a general organism into
the most appropriate hosting MOD.

  eg:
  my $mod = $self->_organism2mod('nematode');
  # $mod contains 'WormBase'

=back

=head1 BUGS

None reported.

=head1 SEE ALSO

L<Bio::GMOD::Update>, L<Bio::GMOD::Adaptor>

=head1 AUTHOR

Todd W. Harris E<lt>harris@cshl.orgE<gt>.

Copyright (c) 2003-2005 Cold Spring Harbor Laboratory.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 ACKNOWLEDGEMENTS

Much thanks to David Craig (dacraig@stanford.edu) for extensive alpha
testing.

=cut
