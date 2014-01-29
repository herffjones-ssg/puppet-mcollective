# == Class: mcollective::role
#
# A bit of a hack so that we can use Puppet v3's data lookup in Hiera to see if
# a system is a client or just a server. This keeps us from doing a major
# refactor on the rest of the code. This class is meant to be included in the
# common class and applied to all nodes. The nodes that you want to be a
# client, will need to have 'mcollective::role::client: true' in Hiera.
#
# == Parameters
#
# [*resource_type_whitelist*]
# resources to be whitelisted. This is used by the puppet agent with 'mco
# puppet resource'. Valid types string and array.
# - default: undef
#
class mcollective::role (
  $broker_host             = "puppet.${::domain}",
  $broker_port             = '61613',
  $security_secret         = 'badpsk',
  $client                  = false,
  $manage_firewall         = false,
  $resource_type_whitelist = undef,
) {

  if $resource_type_whitelist {

    # get type for case statement
    $whitelist_var_type = type($resource_type_whitelist)

    case $whitelist_var_type {

      # if string, take it as it is
      'string': {
        $real_resource_type_whitelist = $resource_type_whitelist
      }

      # if array, join each element with a comma
      'array': {
        $real_resource_type_whitelist = join($resource_type_whitelist, ',')
      }

      # fail if not an array or string
      default: {
        fail("mcollective::role::resource_type_whitelist is type <${whitelist_var_type}> and must be an array or string.")
      }
    }
  }

  class { '::mcollective':
    broker_host       => $broker_host,
    broker_port       => $broker_port,
    broker_ssl        => false,
    security_provider => 'psk',
    broker_user       => 'guest',
    broker_password   => 'guest',
    broker_vhost      => 'mcollective',
    security_secret   => $security_secret,
    connector         => 'stomp',
    node              => true,
    client            => $client,
  }

  if $client == true {

    if $manage_firewall == true {
      firewall { '61613 open port 61613 for MCollective':
        action => 'accept',
        dport  => 61613,
        proto  => 'tcp',
      }
    }

    include wget

    class { 'rabbitmq::server':
      port              => '5672',
      delete_guest_user => false,
      version           => '2.6.1',
    }

    wget::fetch { 'amqp_client':
      source      => 'http://ssgsvn.herffjones.hj-int/file_repo/rabbitmq/amqp_client-2.6.1.ez',
      destination => '/usr/lib/rabbitmq/lib/rabbitmq_server-2.6.1/plugins/amqp_client-2.6.1.ez',
      timeout     => 0,
      verbose     => false,
      require     => Class['rabbitmq::server'],
      notify      => Service['rabbitmq-server'],
    }

    wget::fetch { 'rabbitmq_stomp':
      source      => 'http://ssgsvn.herffjones.hj-int/file_repo/rabbitmq/rabbitmq_stomp-2.6.1.ez',
      destination => '/usr/lib/rabbitmq/lib/rabbitmq_server-2.6.1/plugins/rabbitmq_stomp-2.6.1.ez',
      timeout     => 0,
      verbose     => false,
      require     => Class['rabbitmq::server'],
      notify      => Service['rabbitmq-server'],
    }
  }

  mcollective::plugin { 'filemgr':
    client => $client,
  }

  mcollective::plugin { 'iptables':
    client => $client,
  }

  mcollective::plugin { 'nrpe':
    client => $client,
  }

  mcollective::plugin { 'package':
    client => $client,
  }

  mcollective::plugin { 'puppet':
    client => $client,
  }

  mcollective::plugin { 'service':
    client => $client,
  }
}
