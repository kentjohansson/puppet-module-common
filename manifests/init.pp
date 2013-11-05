# == Class: common
#
# This class is applied to *ALL* nodes
#
# === Copyright
#
# Copyright 2013 GH Solutions, LLC
#
class common (
  $users                            = undef,
  $groups                           = undef,
  $manage_root_password             = false,
  $root_password                    = '$1$cI5K51$dexSpdv6346YReZcK2H1k.', # puppet
  $create_opt_lsb_provider_name_dir = false,
  $lsb_provider_name                = 'UNSET',
  $enable_dnsclient                 = false,
  $enable_hosts                     = false,
  $enable_inittab                   = false,
  $enable_mailaliases               = false,
  $enable_motd                      = false,
  $enable_network                   = false,
  $enable_nsswitch                  = false,
  $enable_ntp                       = false,
  $enable_pam                       = false,
  $enable_puppet_agent              = false,
  $enable_rsyslog                   = false,
  $enable_selinux                   = false,
  $enable_ssh                       = false,
  $enable_utils                     = false,
  $enable_vim                       = false,
  $enable_wget                      = false,
  # include classes based on virtual or physical
  $enable_virtual                   = false,
  $enable_physical                  = false,
  # include classes based on osfamily fact
  $enable_debian                    = false,
  $enable_redhat                    = false,
  $enable_solaris                   = false,
  $enable_suse                      = false,
) {

  if str2bool($dnsclient_enabled) {
     include dnsclient
  }
  if str2bool($enable_dnsclient) {
    include dnsclient
  }
  if str2bool($enable_hosts) {
    include hosts
  }
  if str2bool($enable_inittab) {
    include inittab
  }
  if str2bool($enable_mailaliases) {
    include mailaliases
  }
  if str2bool($enable_motd) {
    include motd
  }
  if str2bool($enable_network) {
    include network
  }
  if str2bool($enable_nsswitch) {
    include nsswitch
  }
  if str2bool($enable_ntp) {
    include ntp
  }
  if str2bool($enable_pam) {
    include pam
  }
  if str2bool($enable_puppet_agent) {
    include puppet::agent
  }
  if str2bool($enable_wget) {
    include wget
  }
  if str2bool($enable_vim) {
    include vim
  }
  if str2bool($enable_utils) {
    include utils
  }
  if str2bool($enable_ssh) {
    include ssh
  }
  if str2bool($enable_selinux) {
    include selinux
  }
  if str2bool($enable_rsyslog) {
    include rsyslog
  }

  # only allow supported OS's
  case $::osfamily {
    'debian': {
      if str2bool($enable_debian) {
        include debian
      }
    }
    'redhat': {
      if str2bool($enable_redhat) {
        include redhat
      }
    }
    'solaris': {
      if str2bool($enable_solaris) {
        include solaris
      }
    }
    'suse': {
      if str2bool($enable_suse) {
        include suse
      }
    }
    default: {
      fail("Supported OS families are Debian, RedHat, Solaris, and Suse. Detected osfamily is ${::osfamily}.")
    }
  }


  # validate type and convert string to boolean if necessary
  $is_virtual_type = type($::is_virtual)
  if $is_virtual_type == 'string' {
    $is_virtual = str2bool($::is_virtual)
  } else {
    $is_virtual = $::is_virtual
  }

  # include modules depending on if we are virtual or not
  case $is_virtual {
    true: {
      if str2bool($enable_virtual) {
        include virtual
      }
    }
    false: {
      if str2bool($enable_physical) {
        include physical
      }
    }
    default: {
      fail("is_virtual must be boolean true or false and is ${is_virtual}.")
    }
  }

  # validate type and convert string to boolean if necessary
  $manage_root_password_type = type($manage_root_password)
  if $manage_root_password_type == 'string' {
    $manage_root_password_real = str2bool($manage_root_password)
  } else {
    $manage_root_password_real = $manage_root_password
  }

  if $manage_root_password_real == true {

    # validate root_password - fail if not a string
    $root_password_type = type($root_password)
    if $root_password_type != 'string' {
      fail('common::root_password is not a string.')
    }

    user { 'root':
      password => $root_password,
    }
  }

  # validate type and convert string to boolean if necessary
  $create_opt_lsb_provider_name_dir_type = type($create_opt_lsb_provider_name_dir)
  if $create_opt_lsb_provider_name_dir_type == 'string' {
    $create_opt_lsb_provider_name_dir_real = str2bool($create_opt_lsb_provider_name_dir)
  } else {
    $create_opt_lsb_provider_name_dir_real = $create_opt_lsb_provider_name_dir
  }

  if $create_opt_lsb_provider_name_dir_real == true {

    # validate lsb_provider_name - fail if not a string
    $lsb_provider_name_type = type($lsb_provider_name)
    if $lsb_provider_name_type != 'string' {
      fail('common::lsb_provider_name is not a string.')
    }

    if $lsb_provider_name != 'UNSET' {

      # basic filesystem requirements
      file { "/opt/${lsb_provider_name}":
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
    }
  }

  if $users != undef {

    # Create virtual user resources
    create_resources('@common::mkuser',$common::users)

    # Collect all virtual users
    Common::Mkuser <||>
  }

  if $groups != undef {

    # Create virtual group resources
    create_resources('@group',$common::groups)

    # Collect all virtual groups
    Group <||>
  }
}
