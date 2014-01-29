# Class: mcollective
#
# This class provides a simple way to deploy MCollective nodes and clients.
# It will install and configure the necessary packages.
#
# This module supports generic STOMP and RabbitMQ connectors,
# with optional SSL support.
#
# It supports PSK and SSL as authentication methods.
#
# Parameters:
#   ['node']              - Whether to install an MCollective node.
#                           Defaults to true.
#   ['client']            - Whether to install an MCollective client.
#                           Defaults to false.
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
#   ['security_ssl_server_private'] - If SSL is used, the path to the SSL
#                                     private server key (shared).
#   ['security_ssl_server_public']  - If SSL is used, the path to the SSL
#                                     public server key (shared).
#   ['security_ssl_client_private'] - If SSL is used, the path to the SSL
#                                     private client key.
#   ['security_ssl_client_public']  - If SSL is used, the path to the SSL
#                                     public client key.
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
# - Deploys MCollective nodes and clients
#
# Sample Usage:
#   class { '::mcollective':
#     broker_host       => 'rabbitmq.example.com',
#     broker_port       => '61614',
#     security_provider => 'psk',
#     security_secret   => 'P@S5w0rD',
#   }
#
#   class { '::mcollective':
#     broker_host                 => 'rabbitmq.example.com',
#     broker_port                 => '61614',
#     security_provider           => 'ssl',
#   }
#
class mcollective (
  $broker_host,
  $broker_port,
  $security_provider,
  $node = $mcollective::params::node,
  $client = $mcollective::params::client,
  $broker_vhost = $mcollective::params::broker_vhost,
  $broker_user = $mcollective::params::broker_user,
  $broker_password = $mcollective::params::broker_password,
  $broker_ssl = $mcollective::params::broker_ssl,
  $broker_ssl_cert = $mcollective::params::broker_ssl_cert,
  $broker_ssl_key = $mcollective::params::broker_ssl_key,
  $broker_ssl_ca = $mcollective::params::broker_ssl_ca,
  $security_secret = $mcollective::params::security_secret,
  $security_ssl_server_private = $mcollective::params::security_ssl_server_private,
  $security_ssl_server_public = $mcollective::params::security_ssl_server_public,
  $security_ssl_client_private = $mcollective::params::security_ssl_client_private,
  $security_ssl_client_public = $mcollective::params::security_ssl_client_public,
  $connector = $mcollective::params::connector,
  $puppetca_cadir = $mcollective::params::puppetca_cadir,
  $rpcauthorization = $mcollective::params::rpcauthorization,
  $rpcauthprovider = $mcollective::params::rpcauthprovider,
  $rpcauth_allow_unconfigured = $mcollective::params::rpcauth_allow_unconfigured,
  $rpcauth_enable_default = $mcollective::params::rpcauth_enable_default,
  $cert_dir = $mcollective::params::cert_dir,
  $policies_dir = $mcollective::params::policies_dir,
) inherits ::mcollective::params {

  if ($node) {
    class { '::mcollective::node':
      broker_host                => $broker_host,
      broker_port                => $broker_port,
      security_provider          => $security_provider,
      broker_vhost               => $broker_vhost,
      broker_user                => $broker_user,
      broker_password            => $broker_password,
      broker_ssl                 => $broker_ssl,
      broker_ssl_cert            => $broker_ssl_cert,
      broker_ssl_key             => $broker_ssl_key,
      broker_ssl_ca              => $broker_ssl_ca,
      security_secret            => $security_secret,
      security_ssl_private       => $security_ssl_server_private,
      security_ssl_public        => $security_ssl_server_public,
      connector                  => $connector,
      puppetca_cadir             => $puppetca_cadir,
      rpcauthorization           => $rpcauthorization,
      rpcauthprovider            => $rpcauthprovider,
      rpcauth_allow_unconfigured => $rpcauth_allow_unconfigured,
      rpcauth_enable_default     => $rpcauth_enable_default,
      cert_dir                   => $cert_dir,
      policies_dir               => $policies_dir,
    }
  }

  if ($client) {
    class { '::mcollective::client':
      broker_host                 => $broker_host,
      broker_port                 => $broker_port,
      security_provider           => $security_provider,
      broker_vhost                => $broker_vhost,
      broker_user                 => $broker_user,
      broker_password             => $broker_password,
      broker_ssl                  => $broker_ssl,
      broker_ssl_cert             => $broker_ssl_cert,
      broker_ssl_key              => $broker_ssl_key,
      broker_ssl_ca               => $broker_ssl_ca,
      security_secret             => $security_secret,
      security_ssl_server_public  => $security_ssl_server_public,
      security_ssl_client_private => $security_ssl_client_private,
      security_ssl_client_public  => $security_ssl_client_public,
      connector                   => $connector,
      puppetca_cadir              => $puppetca_cadir,
    }
  }
}
