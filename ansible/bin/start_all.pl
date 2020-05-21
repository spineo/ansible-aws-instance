#!/usr/bin/perl -w

#------------------------------------------------------------------------------
# Name       : start_all.pl
# Author     : Stuart Pineo  <svpineo@gmail.com>
# Usage      :
# Description: Start up AWS EC2 Instances and Zookeeper/Hadoop/Accumulo Cluster
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Copyright (c) 2020 Stuart Pineo
#
#------------------------------------------------------------------------------

use strict;
use warnings;

use Getopt::Long;
use Carp qw(croak carp);
use Data::Dumper;

# Global variables
#
our $COMMAND = `basename $0`;
chomp($COMMAND);

our $VERSION = "1.0";

# Generic variables
#
our $VERBOSE = 0;
our $DEBUG   = 0;

use Getopt::Long;
GetOptions(
    'debug'      => \$DEBUG,
    'verbose'    => \$VERBOSE,
    'help|usage' => \&usage,
);

#------------------------------------------------------------------------------
# usage: Print usage when invoked with -help or -usage
#------------------------------------------------------------------------------

sub usage {
    print STDERR <<_USAGE;
Usage:   ./$COMMAND --debug --verbose
Example: ./$COMMAND --debug --verbose
_USAGE

    exit(1);
}


