# Overview #

This module allows you to manage the DNS resolver library configuration for 
your host. It manages all aspects of the resolv.conf configuration file
specifically.

# Installation #

This module should be placed in your module search path.  The module is
designed to be automatically updated with Puppet Enterprise updates and should
not be modified.  Customization of the module behavior is intended to be done
in a namespace outside of the resolver module or using a YAML data file outside
of the module directory structure.

# Quick Start #

Basic configuration can be provided by instantiating the resolver class like 
so:

    class { "resolver":
      search => ["puppetlabs.com","lan.puppetlabs.com"],
      nameserver => ["127.0.0.1", "8.8.8.8"],
    }

This would create a resolv.conf file that looks something like this:

    nameserver 127.0.0.1
    nameserver 8.8.8.8
    search puppetlabs.com lan.puppetlabs.com

More advanced options are available for resolv.conf:

    class { "resolver":
      search => ["puppetlabs.com","lan.puppetlabs.com"],
      nameserver => ["127.0.0.1", "8.8.8.8"],
      ndots => 3,
      timeout => 60,
    }

