# == Class: mcollective::params
#
class mcollective::params {
  $broker_vhost = '/mcollective'
  $broker_user = 'guest'
  $broker_password = 'guest'
  $broker_ssl = true
  $broker_ssl_cert = "/var/lib/puppet/ssl/certs/${::fqdn}.pem"
  $broker_ssl_key = "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
  $broker_ssl_ca = '/var/lib/puppet/ssl/certs/ca.pem'
  $security_secret = ''
#  $security_ssl_server_private = "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
#  $security_ssl_server_public = "/var/lib/puppet/ssl/certs/${::fqdn}.pem"
  $security_ssl_server_private = '/etc/mcollective/ssl/server-private.pem'
  $security_ssl_server_public = '/etc/mcollective/ssl/server-public.pem'
#  $security_ssl_client_private = "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem"
#  $security_ssl_client_public = "/var/lib/puppet/ssl/certs/${::fqdn}.pem"
  $security_ssl_client_private = false
  $security_ssl_client_public = false
  $connector = 'rabbitmq'
  $puppetca_cadir = '/srv/puppetca/ca/'
  $rpcauthorization = false
  $rpcauthprovider = 'action_policy'
  $rpcauth_allow_unconfigured = 0
  $rpcauth_enable_default = 1
  $cert_dir = '/etc/mcollective/ssl/clients'
  $policies_dir = '/etc/mcollective/policies'
  $node = true
  $client = false

  include ruby

  case $::osfamily {
    'Debian': {
      $client_require = Package['rubygems', 'ruby-stomp']
      $server_require = Package['rubygems', 'ruby-stomp']
      $libdir = '/usr/share/mcollective/plugins'
    }

    'RedHat': {
      $client_require = Package['rubygems', 'rubygem-stomp']
      $server_require = Package['rubygems', 'rubygem-stomp', 'rubygem-net-ping']
      $libdir = '/usr/libexec/mcollective'
    }

    default: {
      fail("Unsupported OS family ${::osfamily}")
    }
  }
}
