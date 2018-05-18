# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   nrpe::command_disks { 'namevar': }
define nrpe::command_disks(
  String $cwd=$::nrpe::plugindir,
  Integer $percent_check_limit=$::nrpe::percent_check_limit,
  Integer $bytes_warning=$::nrpe::bytes_warning,
  Integer $bytes_critical=$::nrpe::bytes_critical,
  $ensure='present'
) {
  case $ensure {
    absent,present: {}
    default: {
      fail("Invalid ensure value passed to Nrpe::Command_disks[${name}]")
    }
  }

  if ($::operatingsystem == 'CentOS') {
    $devel_packages = [ 'ruby-devel', 'libffi-devel', 'gcc' ]
    package { $devel_packages:
      ensure => latest,
      before => Package['sys-filesystem'],
    }
  }

  package { 'sys-filesystem':
    ensure   => installed,
    provider => gem,
  }


  file { "${nrpe::include_dir}/command_disks.cfg":
    ensure  => $ensure,
    content => template('nrpe/nrpe-command-disks.cfg.erb'),
    owner   => root,
    group   => $::nrpe::root_group,
    mode    => '0644',
    require => [ File[$::nrpe::include_dir], Package['sys-filesystem']],
    notify  => Service[$::nrpe::nrpe_service],
  }
}

