package pf::SNMP::Extreme::Summit_X250e;

=head1 NAME

pf::SNMP::Extreme::Summit_X250e - Object oriented module to parse SNMP traps 
and manage Extreme Networks' Summit X250e switches

=head1 STATUS

This module is currently only a placeholder, see pf::SNMP::Extreme.

=cut

use strict;
use warnings;
use Log::Log4perl;
use Net::SNMP;
use base ('pf::SNMP::Extreme::Summit');

# importing switch constants
use pf::SNMP::constants;
use pf::util;

=head1 AUTHOR

Olivier Bilodeau <obilodeau@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2009,2010 Inverse inc.

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

# vim: set shiftwidth=4:
# vim: set expandtab:
# vim: set backspace=indent,eol,start:
