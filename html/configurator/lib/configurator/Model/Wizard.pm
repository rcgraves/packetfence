package configurator::Model::Wizard;

=head1 NAME

configurator::Model::Wizard - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use Moose;
use namespace::autoclean;

use pf::config;

extends 'Catalyst::Model';

=head1 METHODS

=over

=item checkForRootUser

=cut
sub checkForRootUser {
    my ( $self ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my $status_msg;

    unless ( $< == 0 ) {
        $status_msg = "The configurator must run under the root user";
        $logger->error($status_msg);
        return ( 0, $status_msg );
    }

    return 1;
}

=item checkForUpgrade

=cut
sub checkForUpgrade {
    my ( $self ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my $filehandler;

    open( $filehandler, '<', "$install_dir/conf/currently-at" );
    my $currently_at = <$filehandler>;
    close( $filehandler );

    open( $filehandler, '<', "$install_dir/conf/pf-release" );
    my $pf_release = <$filehandler>;
    close( $filehandler );

    if ( (!$currently_at) || ($currently_at eq $pf_release) ) {
        $logger->info("Installation process");
        return "installation";
    } else {
        $logger->info("Upgrade process");
        return "upgrade";
    }
}

=back

=head1 AUTHORS

Derek Wuelfrath <dwuelfrath@inverse.ca>

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

__PACKAGE__->meta->make_immutable;

1;
