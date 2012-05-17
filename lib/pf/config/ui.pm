package pf::config::ui;

=head1 NAME

pf::config::ui - OO module that holds the ui.conf configuration

=head1 SYNOPSIS

The pf::config::ui OO module holds the content of conf/ui.conf hot in memory.

=head1 DEVELOPER NOTES

Singleton patterns means you should not keep state within this module.

=cut

=head1 FILES

conf/ui.conf

=cut
use strict;
use warnings;

use Log::Log4perl;

our $VERSION = 1.00;

use pf::config;

my $singleton;

=head1 SUBROUTINES

=over

=item instance

Get the singleton instance of pf::config::ui. Create it if it doesn't exist.

=cut
sub instance {
    my ( $class, %args ) = @_;

    if (!defined($singleton)) {
        $singleton = $class->new(%args);
    }

    return $singleton;
}

=item new

Constructor. Usually you don't want to call this constructor but use the 
pf::config::ui::custom subclass instead.

=cut

sub new {
    my ( $class, %argv ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);
    $logger->debug("instantiating new " . __PACKAGE__ . " object");
    my $self = bless {}, $class;
    return $self;
}

=back

=head1 METHODS

=over

=cut
my $_ui_conf_tie = undef;

=item _ui_conf

Load ui.conf into a Config::IniFiles tied hashref

=cut
sub _ui_conf {
    my ($self) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    unless (defined $_ui_conf_tie) {
        my %conf;
        tie %conf, 'Config::IniFiles', ( -file => "$conf_dir/ui.conf" );
        my @errors = @Config::IniFiles::errors;
        if ( scalar(@errors) || !%conf ) {
            $logger->logdie("Error reading ui.conf: " . join( "\n", @errors ) . "\n" );
        }

        $_ui_conf_tie = \%conf;
    }

    return $_ui_conf_tie;
}

=item field_order

Return the correct field order listed in ui.conf for a given resource.

Ex resources:

    interfaceconfig get

=cut
# TODO there is caching opportunity here
# TODO once bin/pfcmd is only a web services client we can get rid of 
#      $resource and do auto-lookup based on caller and get rid of all
#      hard-coded names
sub field_order {
    my ($self, $resource) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my $uiconfig = $self->_ui_conf();
    my @fields;
    foreach my $section ( sort tied(%$uiconfig)->Sections ) {

        # skipping sections without command
        next if (!defined($uiconfig->{$section}->{command}));

        if ($resource =~ /^$uiconfig->{$section}->{command}/) {

            foreach my $val ( split( /\s*,\s*/, $uiconfig->{$section}->{'display'} ) ) {
                $val =~ s/-//;
                push @fields, $val;
            }
            last;
        }
    }
    return (@fields);
}

=back

=head1 AUTHOR

Olivier Bilodeau <obilodeau@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2012 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;
