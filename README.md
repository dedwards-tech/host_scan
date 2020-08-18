# `host_scan' README

Host scan tool for gathering multiple host system state details before and after running a particular test.

THIS IS A WORK IN PROGRESS - NOT READY FOR CONSUMPTION 8/15/2020

# Design

1. a command list file contains a list of shell commands to execute remotely on every host,
based on the "common" os supported commands and "<os_type>" specific commands.
1. a network configuration file containing list of remote hosts and credentials (encrypted)
required to connect to the remote host.
    * the goal here is to use industry best practices for secure SSH connection.
1. a helper script to aid in managing encrypted credentials, references get stored in
source control, but actual passwords DO NOT!

left off here - design this properly!python 