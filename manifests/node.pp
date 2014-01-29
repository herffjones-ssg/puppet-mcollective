# Class: mcollective::node
#
# This class provides a simple way to deploy an MCollective node.
# It will install and configure the necessary packages.
#
# This module supports generic STOMP and RabbitMQ connectors,
# with optional SSL support.
#
# It supports PSK and SSL as authentication methods.
#
# Parameters:
#   ['broker_host']       - The middleware broker host to use.
#   ['broker_port']       - The middleware broker port to use.
#   ['broker_vhost']      - The middleware broker vhost to use.
#                           Currently only used with RabbitMQ.
#   ['broker_user']       - The middleware broker user to use.
#                           If set to false, the user entry will be
#                           ommited from the configuration file
#                           (useful if you want to force using
#                           environment variables instead).
#   ['broker_password']   - The middleware broker password to use.
#   ['broker_ssl']        - Whether to use stomp over SSL
#   ['broker_ssl_cert']   - If using SSL, the path to the SSL public key.
#                           Defaults to Puppet's public certicate.
#   ['broker_ssl_key']    - If using SSL, the path to the SSL private key.
#                           Defaults to Puppet's private certicate.
#   ['broker_ssl_ca']     - If using SSL, the path to the SSL CA certificate.
#                           Defaults to Puppet's CA certificate.
#   ['security_provider'] - The security provider to use.
#                           Currently supported are 'psk' and 'ssl'.
#   ['security_secret']   - If PSK is used, the value of the shared password.
#   ['security_ssl_private'] - If SSL is used, the path to the SSL
#                              private key (shared).
#   ['security_ssl_public']  - If SSL is used, the path to the SSL
#                              public key (shared).
#   ['connector']         - The connector to use. Either 'stomp' or 'rabbitmq'.
#                           Defaults to 'rabbitmq'.
#   ['puppetca_cadir']    - Path to the Puppet CA directory.
#   ['rpcauthorization']  - Whether to use RPC authorization.
#                           False by default.
#   ['rpcauthprovider']   - The RPC authorization plugin to use.
#                           Defaults to 'action_policy'.
#   ['rpcauth_allow_unconfigured'] - Whether to allow unconfigured agents
#                                    with RPC auth. Values are '0' or '1'.
#                                    Defaults to '0'.
#   ['rpcauth_enable_default']     - Whether to enable RPC authorization
#                                    by default. Values are '0' or '1'.
#                                    Defaults to '1'.
#   ['cert_dir']          - Path to the client certificates directory.
#                           Defaults to '/etc/mcollective/ssl/clients'.
#   ['policies_dir']      - Path to the policies directory.
#                           Defaults to '/etc/mcollective/policies'.
#
# Actions:
# - Deploys an MCollective node
#
# Sample Usage:
#   class { '::mcollective::node':
#     broker_host       => 'rabbitmq.example.com',
#     broker_port       => '61614',
#     security_provider => 'psk',
#     security_secret   => 'P@S5w0rD',
#   }
#
#   class { '::mcollective::node':
#     broker_host                 => 'rabbitmq.example.com',
#     broker_port                 => '61614',
#     security_provider           => 'ssl',
#   }
#
class mcollective::node (
  $broker_host,
  $broker_port,
  $security_provider,
  $broker_vhost = $mcollective::params::broker_vhost,
  $broker_user = $mcollective::params::broker_user,
  $broker_password = $mcollective::params::broker_password,
  $broker_ssl = $mcollective::params::broker_ssl,
  $broker_ssl_cert = $mcollective::params::broker_ssl_cert,
  $broker_ssl_key = $mcollective::params::broker_ssl_key,
  $broker_ssl_ca = $mcollective::params::broker_ssl_ca,
  $security_secret = $mcollective::params::security_secret,
  $security_ssl_private = $mcollective::params::security_ssl_server_private,
  $security_ssl_public = $mcollective::params::security_ssl_server_public,
  $connector = $mcollective::params::connector,
  $puppetca_cadir = $mcollective::params::puppetca_cadir,
  $rpcauthorization = $mcollective::params::rpcauthorization,
  $rpcauthprovider = $mcollective::params::rpcauthprovider,
  $rpcauth_allow_unconfigured = $mcollective::params::rpcauth_allow_unconfigured,
  $rpcauth_enable_default = $mcollective::params::rpcauth_enable_default,
  $cert_dir = $mcollective::params::cert_dir,
  $policies_dir = $mcollective::params::policies_dir,
  $mco_agent_path = "/usr/libexec/mcollective/mcollective/agent/",
  $mco_application_path = "/usr/libexec/mcollective/mcollective/application/",
) inherits ::mcollective::params {

  # Recent Upstart requires daemonize to be set to 0
  # warning: do not name this variable $daemonize!
  $mcollective_daemonize = $::operatingsystem ? {
    default => 1
  }

  file { [$cert_dir, $policies_dir]:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    recurse => true,
    purge   => true,
    require => Package['mcollective'],
  }

  $mcollective_libdir = $mcollective::params::libdir

  case $::osfamily {

    'Debian': {

      package { 'libstomp-ruby':
        ensure => absent,
      }
      package { 'ruby-stomp':
        ensure  => present,
        require => Package['libstomp-ruby'],
        notify  => Service['mcollective'],
      }

      augeas { 'Enable mcollective':
        lens    => 'Shellvars.lns',
        incl    => '/etc/default/mcollective',
        changes => 'set RUN yes',
        require => Package['mcollective'],
        notify  => Service['mcollective'],
      }

    }

    'RedHat': {
      package { ['rubygem-net-ping', 'rubygem-stomp']:
        ensure => present,
        notify => Service['mcollective'],
      }

    }

    default: {
      fail("Unsupported OS family: ${::osfamily}")
    }

  }

  package { 'mcollective':
    ensure  => present,
    require => $mcollective::params::server_require,
  }

  service { 'mcollective':
    ensure    => running,
    hasstatus => true,
    enable    => true,
    require   => Package['mcollective'],
  }

  exec { 'reload mcollective':
    #command    => 'pkill -USR1 -f "ruby.*mcollectived"',
    command     => 'service mcollective reload-agents',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }

  file { '/etc/mcollective/server.cfg':
    ensure  => present,
    mode    => '0640',
    owner   => 'root',
    group   => 'root',
    content => template('mcollective/server.cfg.erb'),
    notify  => Service['mcollective'],
    require => Package['mcollective'],
  }

  file { "/usr/local/bin/facter_to_yaml.rb":
    source  => "puppet:///modules/mcollective/facter_to_yaml.rb",
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }

  file { "mcollective_agents":
    ensure  => directory,
    path    => $mco_agent_path,
    source  => "puppet:///modules/mcollective/agent/",
    recurse => remote,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Exec['reload mcollective'],
  }

  file { "mcollective_application":
    ensure  => directory,
    path    => $mco_application_path,
    source  => "puppet:///modules/mcollective/application/",
    recurse => remote,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    notify  => Exec['reload mcollective'],
  }

  cron { "factertoyaml":
    command => "/usr/local/bin/facter_to_yaml.rb",
    user    => root,
    minute  => [1, 31],
    require => File["/usr/local/bin/facter_to_yaml.rb"],
  }
  #  file { '/etc/mcollective/facts.yaml':
  #  ensure   => present,
  #  backup   => false,
  #  owner    => 'root',
  #  group    => 'root',
  #  mode     => '0400',
  #  loglevel => debug,  # this is needed to avoid it being logged and reported
  #                      # on every run
  #                      # avoid including highly-dynamic facts as they will
  #                      # cause unnecessary template writes
#    content => template('mcollective/facts.yaml.erb'),
#  content  => inline_template('<%= Hash[scope.to_hash.reject { |k,v| k.to_s =~ /(uptime|timestamp|memory|free|swap|path)/ }.sort].to_yaml %>'),
#    require  => Package['mcollective'],
#    }
}
