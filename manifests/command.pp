# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   nrpe::command { 'namevar': }
define nrpe::command(
  String $cmd,
  String $cmdname=$name,
  String $cwd=$::nrpe::plugindir,
  Optional[String] $run_as = '',
  $ensure=present
) {

  case $ensure {
    absent,present: {}
    default: {
      fail("Invalid ensure value passed to Nrpe::Command[${name}]")
    }
  }

  file { "${::nrpe::include_dir}/${cmdname}.cfg":
    ensure  => $ensure,
    content => template('nrpe/nrpe-command.cfg.erb'),
    owner   => root,
    group   => $::nrpe::root_group,
    mode    => '0644',
    require => File[$nrpe::include_dir],
    notify  => Service[$nrpe::nrpe_service],
  }
  if ( $run_as != '' ) {
    sudo::conf{ "puppet_nrpe_${cmdname}":
      priority => 50,
      content  => "${::nrpe::nrpe_user} ALL = (${run_as}) NOPASSWD: ${cwd}${cmd}"
    }
  }
}
