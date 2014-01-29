# Definition: mcollective::application
#
# Deploys an MCollective application.
#
# You should declare mcollective::client before using this.
#
# Parameters:
#   ['ensure']  - Whether the plugin should be present or absent.
#   ['source']  - Where to get the application from.
#                 Defaults to "puppet:///modules/${module_name}/application/${name}.rb"
#
# Actions:
# - Deploys an MCollective application.
#
# Sample Usage:
#   mcollective::application { 'healthcheck':
#     ensure         => present,
#   }
#
define mcollective::application (
  $ensure='present',
  $source=''
) {
  if !defined(Class['mcollective::client']) {
    fail('You must declare class mcollective::client before using mcollective::application')
  }

  $filesrc = $source ? {
    ''      => "puppet:///modules/${module_name}/application/${name}.rb",
    default => $source,
  }

  file {"${mcollective::client::mcollective_libdir}/mcollective/application/${name}.rb":
    ensure => $ensure,
    source => $filesrc,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
