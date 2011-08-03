# Install and configure resolv.conf
#
# This installs and configures resolv.conf file which is used by the resident
# resolver library for DNS lookup.
#
# == Parameters
#
# === Common Parameters
#
# These parameters are normal parameters that affect the resolv.conf contents.
#
# [nameserver]
#   *Optional* An array of name servers.
# [domain]
#   *Optional* Queries for names within this domain can use short names
#   relative to the domain.
# [search]
#   *Optional* Search list for host-name lookup.
# [sortlist]
#   *Optional* This allows addresses returned by DNS to be sorted. It accepts
#   an ordered list of IP-address-netmask pairs. Netmask is optional.
# [ndots]
#   *Optional* Sets the threshold for the number of dots which must appear in
#   a query before an absolute query will be made.
# [timeout]
#   *Optional* Sets the amount of time the resolver will wait for a response
#   from a remote name server.
# [attempts]
#   *Optional* Sets the number of times the resolver will query its name 
#   servers.
# [rotate]
#   *Optional* If true causes round robin selection of nameservers from those
#   listed.
# [no_check_names]
#   *Optional* Disables checking of hostnames and mail names for invalid 
#   characters.
# [inet6]
#   *Optional* Attempt AAAA queries before A queries for hostname lookups.
# [ip6_bytestring]
#   *Optional* Causes reverse IPv6 lookups to be made using the bit-label 
#   format described in RFC 2673.
# [ip6_dotint]
#   *Optional* When set reverse IPv6 lookups are made in the ip6.int zone.
# [edns0]
#   *Optional* This enables support for the DNS extensions described in RFC 
#   2671.
#
# === Advanced Parameters
#
# These parameters affect the behaviour of this plugin, and are generally 
# automatically configured.
#
# [resolvconf_path]
#   *Optional* Modify this parameter if your resolv.conf file is not in the
#   normal place (/etc/resolv.conf). This is often used if your resolv.conf
#   is a symlink to another location.
# [resolvconf_content]
#   *Optional* A string which will contain the full contents of your
#   resolv.conf file. This allows the user to override the built-in behaviour
#   and provide their own custom content if they desire.
#
# == Examples
#
# Basic configuration:
#
#   class { 'resolver':
#     nameserver => ['127.0.0.1', '8.8.8.8'],
#     domain => "puppetlabs.com",
#     search => "lan.puppetlabs.com",
#   }
#
# Configuration with options:
#
#   class { "resolver':
#     nameserver => "127.0.0.1",
#     ndots => 2,
#     no_check_names => true,
#     timeout => 30,
#   }
#
# == Authors
#
# Pupppetlabs <info@puppetlabs.com>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class resolver (
  $nameserver = undef,
  $domain = undef,
  $search = undef,
  $sortlist = undef,
  $ndots = undef,
  $timeout = undef,
  $attempts = undef,
  $rotate = undef,
  $no_check_names = undef,
  $inet6 = undef,
  $ip6_bytestring = undef,
  $ip6_dotint = undef,
  $edns0 = undef,
  $resolvconf_path = "/etc/resolv.conf",
  $resolvconf_contents = undef
  ) {

  # Domain and search are mutually exclusive, so return an error to avoid 
  # ambiguity.
  if $search and $domain {
    fail("The options 'search' and 'domain' are mutually exclusive, and if both are combined the behaviour is ambigious. 'search' is the recommended parameter to use. Consult the man page for resolv.conf for more details.")
  }

  # Because timeout overlaps with a ruby function, we prefix it to avoid 
  # namespace clash when we try to use it in the template.
  $_timeout = $timeout

  # Install resolv.conf in the specified path. If the user supplied their own
  # content just use that, otherwise use the template we have supplied.
  file { $resolvconf_path:
    content => $resolvconf_contents ? {
      undef => template("${module_name}/resolv.conf"),
      default => $resolvconf_contents
    }
  }
}
