<?php
/**
 * TODO short desc
 *
 * TODO long desc
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
 * USA.
 * 
 * @author      Dominik Gehl <dgehl@inverse.ca>
 * @copyright   2008-2010 Inverse inc.
 * @license     http://opensource.org/licenses/gpl-2.0.php      GPL
 */

$current_top="person";
$current_sub="add";

require('../common.php');
include_once('../header.php');

  PrintAdd(get_headings($current_top), 'vert');

include('../footer.php');

?>
