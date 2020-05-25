#!/usr/bin/perl -w

#------------------------------------------------------------------------------
# Name       : run_playbooks.pl
# Author     : Stuart Pineo  <svpineo@gmail.com>
# Usage      : ./run_playbooks.pl --ansible-home <absolute or relative path> [ --stop --debug --verbose ]
# Description: By default, start up the AWS EC2 cluster instances and Zookeeper/Hadoop/Accumulo applications.
# The '--stop' command-line argument shuts off the cluster but prompts the user first.
# The '--start' command-line argument starts up the cluster/applications (if omitted, this is the default action).
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

our ($ANSIBLE_HOME, $START, $STOP);

use Getopt::Long;
GetOptions(
    'ansible-home=s' => \$ANSIBLE_HOME,
    'start'          => \$START,
    'stop'           => \$STOP,
    'debug'          => \$DEBUG,
    'verbose'        => \$VERBOSE,
    'help|usage'     => \&usage,
);

# Verify/cd to Ansible Home
#
! $ANSIBLE_HOME && &usage("Command-line argument '--ansible-home' is not defined.");
! -d $ANSIBLE_HOME && die("Incorrect or inaccessible directory specified for 'ansible-home': $ANSIBLE_HOME");
chdir($ANSIBLE_HOME);

# Playbook related configuration
#
our $PB_CMD = qw|ansible-playbook|;

# Inventories
#
our $CLUSTER_CONF_INV = qw|zk_ha_ac_conf|;
our $SERVERS_INV      = qw|servers|;
our $HOSTS_INV        = qw|ansible_hosts|;

our $STOP_CONF = [
    {
        'prompt'      => qq|Stop the Cluster?|,
        'playbook'    => 'zk_ha_ac_stop.yml',
        'inventories' => [ $CLUSTER_CONF_INV ]
    },
];

our $START_CONF = [
    {
        'prompt'      => qq|Start up the Cluster?|,
        'playbook'    => 'zk_ha_ac_instances.yml',
        'inventories' => [ $CLUSTER_CONF_INV ]
    },
    {
        'prompt'      => qq|Update the Security Group?|,
        'playbook'    => 'zk_ha_ac_group.yml',
        'inventories' => [ $CLUSTER_CONF_INV ]
    },
    {
        'prompt'      => qq|Create the 'servers' File?|,
        'playbook'    => 'zk_ha_ac_servers.yml',
        'inventories' => [ $CLUSTER_CONF_INV ]
    },
    {
        'prompt'      => qq|Create the '.aliases' File?|,
        'playbook'    => 'zk_ha_ac_aliases.yml',
        'inventories' => [ $CLUSTER_CONF_INV ]
    },
    {
        'prompt'      => qq|Configure Zookeeper?|,
        'playbook'    => 'zookeeper_conf.yml',
        'inventories' => [ $SERVERS_INV, $HOSTS_INV ]
    },
    {
        'prompt'      => qq|Start the Zookeeper Daemons?|,
        'playbook'    => 'zookeeper_daemons.yml',
        'inventories' => [ $SERVERS_INV, $HOSTS_INV ]
    },
    {
        'prompt'      => qq|Configure Hadoop?|,
        'playbook'    => 'hadoop_conf.yml',
        'inventories' => [ $SERVERS_INV, $HOSTS_INV ]
    },
    {
        'prompt'      => qq|Start the Hadoop Daemons?|,
        'playbook'    => 'hadoop_daemons.yml',
        'inventories' => [ $SERVERS_INV, $HOSTS_INV ]
    },
    {
        'prompt'      => qq|Configure Accumulo?|,
        'playbook'    => 'accumulo_conf.yml',
        'inventories' => [ $SERVERS_INV, $HOSTS_INV ]
    },
    {
        'prompt'      => qq|Start the Accumulo Daemons?|,
        'playbook'    => 'accumulo_daemons.yml',
        'inventories' => [ $SERVERS_INV, $HOSTS_INV ]
    },
];

my $action = $STOP ? $STOP_CONF : $START_CONF;

# Determine what action (or action sequence) to take
#
if ($STOP) {
    $action = $STOP_CONF;

} else {
    ! $START && print STDERR "No action specified, assuming '--start'\n";
    $action = $START_CONF;
}

# Run the playbooks
#
foreach my $conf (@$action) {
    &runPlaybook($conf->{'prompt'}, $conf->{'playbook'}, @{$conf->{'inventories'}});
}


#------------------------------------------------------------------------------
# runPlaybook: Invoke an Ansible Playbook command
#------------------------------------------------------------------------------

sub runPlaybook {
    my ($prompt, $playbook, @inventories) = @_;

    print STDERR qq|$prompt (y/n or 'e' to exit) => |;
    my $ans = <STDIN>;
    chomp $ans;

    ($ans eq 'e') && exit(0);

    if ($ans eq 'y') {
        my $inv_list = join(' ', map{"-i ./inventories/$_" } @inventories);
        my $command = qq|$PB_CMD $inv_list ./playbooks/$playbook|;

        print STDERR "Running command: $command\n";

        my $stat = &runCmd($command);
        if ($stat != 0) {
            print STDERR "Command Failed, retry? (y/n) => ";
            my $retry = <STDIN>;
            chomp $retry;

            if ($retry eq 'y') {
                $stat = &runCmd($command);
            }

            ($stat != 0) && die("Command '$command' failed: $!");
        }
    }
}

#------------------------------------------------------------------------------
# runCmd: Run the command
#------------------------------------------------------------------------------

sub runCmd {
    my $cmd = shift;

    open FH, "$cmd |";
    while (<FH>) {
        print STDERR $_;
    }
    close FH ;
    my $stat   = $?;

    return $stat;
}

#------------------------------------------------------------------------------
# usage: Print usage when invoked with -help or -usage
#------------------------------------------------------------------------------

sub usage {
    my $msg_str = shift;

    $msg_str && print STDERR qq|Message : $msg_str\n|;

    print STDERR <<_USAGE;
Usage   : ./$COMMAND --ansible-home <absolute or relative path> [ --start --stop  --debug --verbose ]
Examples: ./$COMMAND --ansible-home .. --debug   # Start up the instances and configure/run the cluster (prompt driven)
          ./$COMMAND --ansible-home .. --start   # Same as previous command without the --debug
          ./$COMMAND -=ansible-home .. --stop    # Stop the cluster (prompt driven)
_USAGE

    exit(1);
}


