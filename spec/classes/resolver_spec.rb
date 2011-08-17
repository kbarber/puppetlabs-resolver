#!/usr/bin/env rspec

require 'spec_helper'
require 'classes/shared'

describe 'resolver' do
  let(:params) { {} }

  describe "when setting resolver params" do

    # This parameter hash provides valid and invalid values for automatic
    # test generated. See 'classes/shared.rb' for details.
    parameters = {
      :nameserver => {
        :valid => [
          "1.1.1.1",
          "fe80::e2f8:47ff:fe09:dd74",
          "8.8.8.8",
          ["1.1.1.1","fe80::e2f8:47ff:fe09:dd74"],
          ["1.1.1.1","2.2.2.2","3.3.3.3"],
        ],
        :invalid => [
          "1.1.1_1", 
          "300.300.0.0",
          "fe80::e2f8:47ff:fe09:dg74",
          ["1.1.1.1","1.1.1.2","1.1.1.3","1.1.1.4"],
        ],
      },
      :search => {
        :valid => [
          "my.domain.com",
          "xn--bcher-kva.ch",
          "4bar3.org",
          "mydomain.com.",
          ["domain1.org","domain2.org","domain3.org"],
          ["domain1.org","domain2.org","domain3.org","domain4.org",
            "domain5.org","domain6.org"],
        ],
        :invalid => [
          "not valid",
          "invalid_domain.org",
          "invaliddomain%^&.org",
          ["too","many","domain","parts","here","thanks","yep"],
          ["valid.org","invalid_domain.org"],
        ],
      },
      :sortlist => {
        :valid => [
          "1.1.1.1",
          "2.3.2.2/255.255.255.0",
          "fe80::e2f8:47ff:fe09:dd74",
          ["1.1.1.1","2.3.2.2/255.255.255.0"],
          ["1.1.1.1","2.2.2.2","3.3.3.3","4.4.4.4","5.5.5.5","6.6.6.6",
            "7.7.7.7","8.8.8.8","9.9.9.9","10.10.10.10"],
        ],
        :invalid => [
          "not valid",
          ["1.1.1.1","2.2.2.2","3.3.3.3","4.4.4.4","5.5.5.5","6.6.6.6",
            "7.7.7.7","8.8.8.8","9.9.9.9","10.10.10.10","11.11.11.11"]
        ],
      },
      :ndots => {
        :valid => ["3","5","10"],
        :invalid => ["not valid","16","-1",["array"]],
      },
      :timeout => {
        :valid => ["30","15","1"],
        :invalid => ["not valid","31","0","-1",["array"]],
      },
      :attempts => {
        :valid => ["5","1"],
        :invalid => ["not valid","6","0","-40",["array"]],
      },
      :rotate => {
        :valid => [true, false],
        :invalid => ["not valid","true","false",["array"]],
      },
      :no_check_names => {
        :valid => [true, false],
        :invalid => ["not valid","true","false",["array"]],
      },
      :inet6 => {
        :valid => [true, false],
        :invalid => ["not valid","true","false",["array"]],
      },
      :ip6_bytestring => {
        :valid => [true, false],
        :invalid => ["not valid","true","false",["array"]],
      },
      :ip6_dotint => {
        :valid => [true, false],
        :invalid => ["not valid","true","false",["array"]],
      },
      :edns0 => {
        :valid => [true, false],
        :invalid => ["not valid","true","false",["array"]],
      },
      :resolvconf_path => {
        :valid => ["/tmp/resolv.conf","/foo/resolv.conf"],
        :invalid => [["array not valid"]],
      },
      :resolvconf_contents => {
        :valid => ["nameserver 127.0.0.1\n"],
        :invalid => [["array not valid"]],
      },
    }

    # Call shared example
    it_should_behave_like "a parameterized class", "resolver", parameters

    # Validation across properties
    it 'should raise an error when domain and search are both set' do
      params['domain'] = "my.domain.com"
      params['search'] = "my.domain.com"
      expect { subject }.should raise_error
    end
 
    # Check file creation occurs when default setting
    describe 'when using the default settings' do
      it { should create_file("/etc/resolv.conf") }
    end

    # Check file creation occurs when non-default setting for resolvconf_path
    describe 'when using a custom resolvconf_path' do
      it do
        params["resolvconf_path"] = "/etc/resolver/resolv.conf"
        should create_file("/etc/resolver/resolv.conf") 
      end
    end

    # Convenience helper for returning parameters for a type from the 
    # catalogue.
    def param(type, title, param) 
      catalogue.resource(type, title).send(:parameters)[param.to_sym]
    end

    # File content creation validation
    it 'should create a single nameserver entry when nameserver set' do
      params['nameserver'] = "1.1.1.1"
      content = param("file","/etc/resolv.conf","content")
      content.should =~ /\nnameserver 1.1.1.1\n/
    end

    it 'should create multiple nameserver entries when nameserver is an array' do
      params['nameserver'] = ["1.1.1.1","2.2.2.2","3.3.3.3"]
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\nnameserver 1.1.1.1\nnameserver 2.2.2.2\nnameserver 3.3.3.3\n/
    end

    it 'should create a domain entry when domain set' do
      params['domain'] = "foo.mydomain.com"
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\ndomain foo.mydomain.com\n/
    end

    it 'should create a search entry when search set' do
      params['search'] = "foo.mydomain.com"
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\nsearch foo.mydomain.com\n/
    end

    it 'should create multiple search entry when search set to an array' do
      params['search'] = ["host1","host2","host3"]
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\nsearch host1 host2 host3\n/
    end

    it 'should create a sortlist entry when sortlist set' do
      params['sortlist'] = "1.1.1.1"
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\nsortlist 1.1.1.1\n/
    end

    it 'should create a sortlist entry when sortlist set to an array' do
      params['sortlist'] = ["1.1.1.1","2.2.2.2","3.3.3.3/255.255.255.0"]
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\nsortlist 1.1.1.1 2.2.2.2 3.3.3.3\/255.255.255.0\n/
    end

    it 'should create an options list when integer options are set' do
      params['ndots'] = 3
      params['timeout'] = 15
      params['attempts'] = 5
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\noptions attempts:5 ndots:3 timeout:15\n/
    end

    it 'should create an options list when boolean options are set' do
      params['rotate'] = true
      params['no_check_names'] = true
      params['inet6'] = true
      params['ip6_bytestring'] = true
      params['ip6_dotint'] = true
      params['edns0'] = true
      content = param("file", "/etc/resolv.conf","content")
      content.should =~ /\noptions edns0 inet6 ip6-bytestring ip6-dotint no-check-names rotate\n/
    end

    it 'should generate a full file' do
      params["nameserver"] = ["127.0.0.1","1.1.1.1"]
      params["search"] = ["domain1.org","domain2.org"]
      params["sortlist"] = ["1.1.1.1","2.2.2.2"]
      params['ndots'] = 3
      params['inet6'] = true
      params['ip6_bytestring'] = true
      params['ip6_dotint'] = true
      content = param("file", "/etc/resolv.conf","content")
      content.should == <<EOS
# WARNING: This file is managed by puppet module 'resolver'.
nameserver 127.0.0.1
nameserver 1.1.1.1

search domain1.org domain2.org

sortlist 1.1.1.1 2.2.2.2

options inet6 ip6-bytestring ip6-dotint ndots:3
EOS
    end

  end
end

