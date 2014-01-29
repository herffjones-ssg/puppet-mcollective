#!/usr/bin/ruby
require 'facter'
require 'yaml'
rejected_facts = ["sshdsakey", "sshrsakey"]
custom_facts_location = "/var/lib/puppet/facts"
outputfile = "/etc/mcollective/facter_generated.yaml"

Facter.search(custom_facts_location)
facts = Facter.to_hash.reject { |k,v| rejected_facts.include? k }
File.open(outputfile, "w") { |fh| fh.write(facts.to_yaml) }
