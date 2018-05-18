# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include nrpe
class nrpe (
  Array[String] $allowed_hosts,
  Array[String] $includecfg,
  Integer $bytes_critical,
  Integer $bytes_warning,
  Integer $command_timeout,
  Integer $connection_timeout,
  Integer $dont_blame_nrpe,
  Integer $nrpedebug,
  Integer $percent_check_limit,
  Integer $server_port,
  String $allow_weak_random_seed,
  String $command_prefix,
  String $include_dir,
  String $log_facility,
  String $nrpe_cfg,
  String $nrpe_group,
  String $nrpe_package,
  String $nrpe_service,
  String $nrpe_user,
  String $pid_file,
  String $plugindir,
  String $plugins_package,
  String $root_group,
  String $server_address,
  Boolean $nrpehasstatus,
) {
  include stdlib

  $ahosts = join( $allowed_hosts, ',' )

  package { $plugins_package:
    ensure => installed,
  }

  package { $nrpe_package:
    ensure => installed,
  }

  file { $include_dir:
    ensure  => directory,
    owner   => root,
    group   => $root_group,
    mode    => '0755',
    notify  => Service[$nrpe_service],
    require => Package[$nrpe_package],
  }

  file { $nrpe_cfg:
    content => template('nrpe/nrpe.cfg.erb'),
    owner   => root,
    group   => $root_group,
    mode    => '0644',
    notify  => Service[$nrpe_service],
    require => Package[$nrpe_package],
  }

  service { 'nrpe_service':
    ensure    => running,
    name      => $nrpe_service,
    enable    => true,
    require   => Package[$nrpe_package],
    hasstatus => $nrpehasstatus,
    pattern   => 'nrpe',
  }

}
