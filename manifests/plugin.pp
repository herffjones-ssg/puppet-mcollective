# Definition: mcollective::plugin
#
# Sets up an MCollective plugin using packages.
#
# Parameters:
#   ['ensure']         - Whether the plugin should be present or absent.
#
# Actions:
# - Installs an MCollective plugin using packages.
#
# Sample Usage:
#   mcollective::plugin { 'puppetca':
#     ensure         => present,
#   }
#
define mcollective::plugin (
  $ensure = 'present',
  $client = false,
) {

  $pkg_prefix = "mcollective-${name}"

  package { "${pkg_prefix}-agent":
    ensure => $ensure,
    notify => Exec['reload mcollective'],
  }

  if $client == true {
    package { "${pkg_prefix}-client":
      ensure => $ensure,
      notify => Exec['reload mcollective'],
    }
  }
}
