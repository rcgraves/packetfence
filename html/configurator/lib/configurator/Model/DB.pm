package configurator::Model::DB;

=head1 NAME

configurator::Model::DB - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

use strict;
use warnings;

use DBI;
use Moose;
use namespace::autoclean;

use pf::config;
use pf::error;
use pf::util;

extends 'Catalyst::Model';

my $dbHandler;

=head1 METHODS

=over

=item assign

=cut
sub assign {
    my ( $self, $db, $user, $password ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my $status_msg;

    $db = $dbHandler->quote_identifier($db);
    
    # Create global PF user
    my $sql_query = "GRANT SELECT,INSERT,UPDATE,DELETE,EXECUTE,LOCK TABLES ON $db.* TO ?\@'%' IDENTIFIED BY ?";
    $dbHandler->do($sql_query, undef, $user, $password);
    if ( $DBI::errstr ) {
        $status_msg = "Error creating the user $user on database $db";
        $logger->warn("$status_msg | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    # Create localhost PF user
    $sql_query = "GRANT SELECT,INSERT,UPDATE,DELETE,EXECUTE,LOCK TABLES ON $db.* TO ?\@localhost IDENTIFIED BY ?";
    $dbHandler->do($sql_query, undef, $user, $password);
    if ( $DBI::errstr ) {
        $status_msg = "Error creating the user $user on database $db";
        $logger->warn("$status_msg | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    # Apply the new privileges
    $dbHandler->do("FLUSH PRIVILEGES");
    if ( $DBI::errstr ) {
        $status_msg = "Error creating the user $user on database $db";
        $logger->warn("$status_msg | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    $status_msg = "Successfully created the user $user on database $db";
    $logger->info("$status_msg");
    return ( $STATUS::OK, $status_msg );
}

=item connect

=cut
sub connect {
    my ( $self, $db, $user, $password ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my $status_msg;

    $dbHandler = DBI->connect( "dbi:mysql:dbname=$db;host=localhost;port=3306", $user, $password );
    if ( !$dbHandler ) {
        $status_msg = "Error in connection to the database $db with user $user";
        $logger->warn("$status_msg | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    $status_msg = "Successfully connected to the database $db with user $user";
    $logger->info("$status_msg");
    return ( $STATUS::OK, $status_msg );
}

=item create

=cut
sub create {
    my ( $self, $db, $root_user, $root_password ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my ( $status_msg, $result );

    # Instantiate a DBI driver
    my $dbDriver = DBI->install_driver("mysql");
    if ( !$dbDriver ) {
        $status_msg = "Error in creating the database $db";
        $logger->warn("$status_msg | USER: $root_user | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    # Create the requested database
    $result = $dbDriver->func('createdb', $db, 'localhost', $root_user, $root_password, 'admin');
    if ( !$result ) {
        $status_msg = "Error in creating the database $db";
        $logger->warn("$status_msg | USER: $root_user | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    $status_msg = "Successfully created the database $db";
    $logger->info("$status_msg | USER: $root_user");
    return ( $STATUS::OK, $status_msg );
}

=item secureInstallation

=cut
sub secureInstallation {
    my ( $self, $root_user, $root_password ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my ($status, $status_msg);

    # Changing root password
    my $sql_query = "UPDATE user SET Password=PASSWORD(?) WHERE User=?";
    $dbHandler->do($sql_query, undef, $root_password, $root_user);
    if ( $DBI::errstr ) {
        $status_msg = "Error changing root user $root_user password";
        $logger->warn("$status_msg | $DBI::errstr");
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    # Remove root remote connection
    $sql_query = "DELETE FROM user WHERE User=? AND Host='%'";
    $dbHandler->do($sql_query, undef, $root_user);
    if ( $DBI::errstr ) {
        $status_msg = "Error setting correct permissions to root user $root_user";
        $logger->warn("$status_msg | $DBI::errstr");
        return ($STATUS::INTERNAL_SERVER_ERROR, $status_msg);
    }

    # Apply the new privileges
    $dbHandler->do("FLUSH PRIVILEGES");
    if ( $DBI::errstr ) {
        $status_msg = "Error applying new privileges to root user $root_user";
        $logger->warn("$status_msg | $DBI::errstr");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    $status_msg = "Successfully secured mysql installation";
    $logger->info("$status_msg");
    return ($STATUS::OK, $status_msg);
}

=item schema

TODO: Check error handling for pf_run... (undef or whatever)

TODO: sanitize parameters going into pf_run with strict regex

=cut
sub schema {
    my ( $self, $db, $root_user, $root_password ) = @_;
    my $logger = Log::Log4perl::get_logger(__PACKAGE__);

    my ( $status_msg, $result );

    my $cmd = "/usr/bin/mysql -u $root_user -p'$root_password' $db < $install_dir/db/pf-schema.sql";
    eval { $result = pf_run($cmd) };
    if ( $@ ) {
        $status_msg = "Error applying the schema to the database $db";
        $logger->warn("$status_msg | USER: $root_user");
        return ( $STATUS::INTERNAL_SERVER_ERROR, $status_msg );
    }

    $status_msg = "Successfully applied the schema to the database $db";
    $logger->info("$status_msg | USER: $root_user");
    return ( $STATUS::OK, $status_msg );
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
