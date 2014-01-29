# MCollective Puppet Module

**This module manages MCollective.**

It supports:
* generic STOMP and RabbitMQ connectors (optionally over SSL)
* PSK and SSL security providers
* Action policy rules

This module is provided by [Camptocamp](http://www.camptocamp.com/)

## Simple usage

This module has a single access point class:

    class { '::mcollective':
      broker_host       => 'rabbitmq.example.com',
      broker_port       => '61613',
      broker_ssl        => false,
      security_provider => 'psk',
      security_secret   => 'P@S5w0rD',
      node              => true,
      client            => false,
    }

    class { '::mcollective':
      broker_host       => 'rabbitmq.example.com',
      broker_port       => '61614',
      security_provider => 'ssl',
      node              => true,
      client            => true,
    }

## Classes

This module provides two classes to configure MCollective nodes and clients.

### mcollective::node

Installs and configures an MCollective node:

    class { '::mcollective::node':
      broker_host       => 'rabbitmq.example.com',
      broker_port       => '61614',
      security_provider => 'psk',
      security_secret   => 'P@S5w0rD',
    }

    class { '::mcollective::node':
      broker_host                 => 'rabbitmq.example.com',
      broker_port                 => '61614',
      security_provider           => 'ssl',
    }

### mcollective::client

Installs and configures an MCollective client:

    class { '::mcollective::client':
      broker_host       => 'rabbitmq.example.com',
      broker_port       => '61614',
      security_provider => 'psk',
      security_secret   => 'P@S5w0rD',
    }
 
    class { '::mcollective::client':
      broker_host       => 'rabbitmq.example.com',
      broker_port       => '61614',
      security_provider => 'ssl',
    }

## Definitions

Several definitions allow to enhance MCollective nodes and clients.

### mcollective::plugin

Installs an MCollective plugin using packages:

    mcollective::plugin { 'puppetca':
      ensure => present,
    }

### mcollective::application

Installs an MCollective application from a file:

    mcollective::application { 'healthcheck':
      ensure => present,
    }

### mcollective::client::certificate

Deploys a public client SSL certificate for authentication:

    mcollective::client::certificate { 'foo':
      ensure         => present,
      key_source_dir => 'puppet:///module_name/path/to/dir/',
    }

### mcollective::actionpolicy::base

Sets up an base action policy file for an agent:

    mcollective::actionpolicy::base { 'puppetd':
      ensure => present,
    }

### mcollective::actionpolicy

Sets up an action policy rule for an agent:

    mcollective::actionpolicy { 'Allow puppetd status for cert foo':
      ensure    => present,
      agent     => 'puppetd',
      rpccaller => 'cert=foo',
      actions   => 'status',
    }

## Contributing

Please report bugs and feature request using [GitHub issue
tracker](https://github.com/camptocamp/puppet-mcollective/issues).

For pull requests, it is very much appreciated to check your Puppet manifest
with [puppet-lint](https://github.com/camptocamp/puppet-apt/issues) to follow the recommended Puppet style guidelines from the
[Puppet Labs style guide](http://docs.puppetlabs.com/guides/style_guide.html).

## License

Copyright (c) 2013 <mailto:puppet@camptocamp.com> All rights reserved.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

