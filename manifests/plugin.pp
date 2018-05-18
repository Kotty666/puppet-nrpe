# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   nrpe::plugin { 'namevar': }
define nrpe::plugin(
  $plugin=$name,
  $plugindir=$nrpe::plugindir,
) {
  file { "${::nrpe::plugindir}/${plugin}":
    ensure  => file,
    source  => "puppet:///modules/${module_name}/${plugin}",
    owner   => 'root',
    group   => $::nrpe::root_group,
    mode    => '0755',
    notify  => Service[$::nrpe::nrpe_service],
    require => Package[$::nrpe::plugins_package],
  }
}
