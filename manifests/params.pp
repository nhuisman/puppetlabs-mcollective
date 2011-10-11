# Class: mcollective::params
#
#   This class provides parameters for all other classes in the mcollective
#   module.  This class should be inherited.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class mcollective::params 
(
  $config_data = hiera("mcollective")
)
{

  $version              = $config_data['configs']['version'] 
  $enterprise           = $config_data['configs']['enterprise']
  $manage_packages      = $config_data['configs']['manage_packages']
  $manage_plugins       = $config_data['configs']['manage_plugins'] 
  $server               = $config_data['configs']['server'] 
  $server_config        = $config_data['configs']['server_config']
  $server_config_file   = $config_data['configs']['server_config_file'] 
  $client               = $config_data['configs']['client']
  $client_config        = $config_data['configs']['client_config'] 
  $client_config_file   = $config_data['configs']['client_config_file']
  $mc_security_provider = $config_data['configs']['mc_security_provider']   
  $mc_security_psk      = $config_data['configs']['mc_security_psk']  
  $fact_source          = $config_data['configs']['fact_source'] 
  $yaml_facter_source   = $config_data['configs']['yaml_facter_source']
  $mc_topicprefix       = $config_data['configs']['mc_topicprefix']   
  $mc_main_collective   = $config_data['configs']['mc_main_collective']
  $mc_collectives       = $config_data['configs']['mc_collectives'] 
  $mc_logfile           = $config_data['configs']['mc_logfile']  
  $mc_loglevel          = $config_data['configs']['mc_loglevel']
  $mc_daemonize         = $config_data['configs']['mc_daemonize']
  
  $plugin_base          = $config_data['configs']['plugin_base']
  $plugin_subs 	      	= $config_data['configs']['plugin_subs'] 

  $client_config_owner  = $config_data['configs']['client_config_owner'] 
  $client_config_group  = $config_data['configs']['client_config_group'] 
  $server_config_owner  = $config_data['configs']['server_config_owner']
  $server_config_group  = $config_data['configs']['server_config_group']

  $stomp_user           = $config_data['configs']['stomp_user'] 
  $stomp_passwd         = $config_data['configs']['stomp_passwd']
  $stomp_server         = $config_data['configs']['stomp_server']   
  $stomp_port           = $config_data['configs']['stomp_port']    
  $pkg_state            = $config_data['configs']['pkg_state']

  $server_real               = $server
  $client_real               = $client
  $client_config_file_real   = $client_config_file
  $server_config_file_real   = $server_config_file
  $stomp_server_real         = $stomp_server
  $mc_security_provider_real = $mc_security_provider
  $mc_security_psk_real      = $mc_security_psk

  $v_bool = [ '^true$', '^false$' ]
  validate_bool($manage_packages)
  validate_bool($enterprise)
  validate_bool($manage_plugins)
  validate_re($server_config_file, '^/')
  validate_re($client_config_file, '^/')
  validate_re("$server", $v_bool)
  validate_re("$client", $v_bool)
  validate_re($version, '^[._0-9a-zA-Z:-]+$')
  validate_re($mc_security_provider, '^[a-zA-Z0-9_]+$')
  validate_re($mc_security_psk, '^[^ \t]+$')
  validate_re($fact_source, '^facter$|^yaml$')

  $nrpe_dir_real = $operatingsystem ? {
    /(?i-mx:centos|fedora|redhat|oel)/ => '/etc/nrpe.d',
    default                            => '/etc/nagios/nrpe.d',
  }
  $mc_service_name = $operatingsystem ? {
    /(?i-mx:darwin)/ => 'com.puppetlabs.mcollective',
    default          => 'mcollective',
  }

  $mc_libdir = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => '/usr/share/mcollective/plugins',
    /(?i-mx:centos|fedora|redhat|sles)/ => '/usr/libexec/mcollective',
  }

  $mc_service_start = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => '/etc/init.d/mcollective start',
    /(?i-mx:centos|fedora|redhat|sles)/ => '/sbin/service mcollective start',
  }

  $mc_service_stop = $operatingsystem ? {
    /(?i-mx:ubuntu|debian)/        => '/etc/init.d/mcollective stop',
    /(?i-mx:centos|fedora|redhat|sles)/ => '/sbin/service mcollective stop',
  }

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


}
