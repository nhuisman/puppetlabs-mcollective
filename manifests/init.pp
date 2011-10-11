# Class: mcollective
#
# This module manages MCollective.
#
# Parameters:
#
#  [*version*]            - The version of the MCollective package(s) to
#                             be installed.
#  [*server*]             - Boolean determining whether you would like to
#                             install the server component.
#  [*server_config*]      - The content of the MCollective server configuration
#                             file.
#  [*server_config_file*] - The full path to the MCollective server
#                             configuration file.
#  [*client*]             - Boolean determining whether you would like to
#                             install the client component.
#  [*client_config*]      - The content of the MCollective client configuration
#                             file.
#  [*client_config_file*] - The full path to the MCollective client
#                             configuration file.
#  [*stomp_server*]       - The hostname of the stomp server.
#  [*mc_security_provider*] - The MCollective security provider
#  [*mc_security_psk*]    - The MCollective pre shared key
#
# Actions:
#
# Requires:
#
#   Class['java']
#   Class['activemq']
#
# Sample Usage:
#
# The module works with sensible defaults:
#
# node default {
#   include mcollective
# }
#
# These defaults are:
#
# node default {
#   class { 'mcollective':
#     version             => 'present',
#     server              => true,
#     server_config       => template('mcollective/server.cfg.erb'),
#     server_config_file  => '/etc/mcollective/server.cfg',
#     client              => true,
#     client_config       => template('mcollective/client.cfg.erb'),
#     client_config_file  => '/home/mcollective/.mcollective',
#     stomp_server        => 'stomp',
#   }
# }
#
class mcollective
(
  $config_data = hiera("mcollective")
)

  class { "mcollective::params": 
    config_data => $config_data
  }


  # Service Name:
  $service_name = $enterprise ? {
    true  => 'pe-mcollective',
    false => 'mcollective',
  }

  if $version == 'UNSET' {
      $version_real = 'present'
  } else {
      $version_real = $version
  }

  if $client_config == 'UNSET' {
    $client_config_real = template('mcollective/client.cfg.erb')
  } else {
    $client_config_real = $client_config
  }
  if $server_config == 'UNSET' {
    $server_config_real = template('mcollective/server.cfg.erb')
  } else {
    $server_config_real = $server_config
  }

  # Add anchor resources for containment
  anchor { 'mcollective::begin': }
  anchor { 'mcollective::end': }

  if $server_real {
    class { 'mcollective::server::base':
      version         => $version_real,
      enterprise      => $enterprise,
      manage_packages => $manage_packages,
      service_name    => $service_name,
      config          => $server_config_real,
      config_file     => $server_config_file_real,
      require         => Anchor['mcollective::begin'],
    }
    # Also manage the plugins
    if $manage_plugins {
      class { 'mcollective::plugins':
        require => Class['mcollective::server::base'],
        before  => Anchor['mcollective::end'],
      }
    }
  }

  if $client_real {
    class { 'mcollective::client::base':
      version         => $version_real,
      config          => $client_config_real,
      config_file     => $client_config_file_real,
      manage_packages => $manage_packages,
      require         => Anchor['mcollective::begin'],
      before          => Anchor['mcollective::end'],
    }
  }

}

