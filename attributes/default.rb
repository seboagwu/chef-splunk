#
# Author: Joshua Timberman <joshua@chef.io>
# Copyright (c) 2014, Chef Software, Inc <legal@chef.io>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Assume default use case is a Universal Forwarder (client).
default['splunk']['accept_license'] = false
default['splunk']['is_server']      = false
default['splunk']['receiver_port']  = '9997'
default['splunk']['web_port']       = '443'
default['splunk']['ratelimit_kilobytessec'] = '2048'

default['splunk']['setup_auth'] = true
default['splunk']['user'] = {
  'username' => 'splunk',
  'comment'  => 'Splunk Server',
  'home'     => '/opt/splunkforwarder',
  'shell'    => '/bin/bash',
  'uid'      => 396
}

default['splunk']['ssl_options'] = {
  'enable_ssl' => false,
  'data_bag' => 'vault',
  'data_bag_item' => 'splunk_certificates',
  'keyfile' => 'self-signed.example.com.key',
  'crtfile' => 'self-signed.example.com.crt'
}

default['splunk']['clustering'] = {
  'enabled' => false,
  'mode' => 'master', # master|slave|searchhead
  'replication_factor' => 3,
  'search_factor' => 2,
  'replication_port' => 9887
}

default['splunk']['shclustering']= {
  'enabled' => false,
  'mode' => "member", # member|captain
  'label' => "shcluster1",
  'replication_factor' => 2,
  'replication_port' => 9900,
  'deployer_url' => '',
  'mgmt_uri' => "https://#{node['fqdn']}:8089",
  'shcluster_members' => [],
  'shcluster_secret' => nil
}

# Add key value pairs to this to add configuration pairs to the output.conf file
# 'sslCertPath' => '$SPLUNK_HOME/etc/certs/cert.pem'
default['splunk']['outputs_conf'] = {
  'forwardedindex.0.whitelist' => '.*',
  'forwardedindex.1.blacklist' => '_.*',
  'forwardedindex.2.whitelist' => '_audit',
  'forwardedindex.filter.disable' => 'false'
}

# Add a host name if you need inputs.conf file to be configured
# Note: if host is empty the inputs.conf template will not be used.
default['splunk']['inputs_conf']['host'] = ''
default['splunk']['inputs_conf']['ports'] = []

# If the `is_server` attribute is set (via an overridable location
# like a role), then set particular attribute defaults based on the
# server, rather than Universal Forwarder. We hardcode the path
# because we don't want to rely on automagic.
default['splunk']['user']['home'] = '/opt/splunk' if node['splunk']['is_server']

default['splunk']['server']['runasroot'] = true

case node['platform_family']
when 'rhel', 'fedora'
  if node['kernel']['machine'] == 'x86_64'
    default['splunk']['forwarder']['url'] = 'https://download.splunk.com/products/universalforwarder/releases/6.4.2/linux/splunkforwarder-6.4.2-00f5bb3fa822-linux-2.6-x86_64.rpm'
    default['splunk']['server']['url'] = 'https://download.splunk.com/products/splunk/releases/6.4.2/linux/splunk-6.4.2-00f5bb3fa822-linux-2.6-x86_64.rpm'
  else
    default['splunk']['forwarder']['url'] = 'https://download.splunk.com/products/universalforwarder/releases/6.4.2/linux/splunkforwarder-6.4.2-00f5bb3fa822.i386.rpm'
    default['splunk']['server']['url'] = 'http://download.splunk.com/products/splunk/releases/6.3.3/linux/splunk-6.3.3-f44afce176d0.i386.rpm'
  end
when 'debian'
  if node['kernel']['machine'] == 'x86_64'
    default['splunk']['forwarder']['url'] = 'https://download.splunk.com/products/universalforwarder/releases/6.4.2/linux/splunkforwarder-6.4.2-00f5bb3fa822-linux-2.6-amd64.deb'
    default['splunk']['server']['url'] = 'https://download.splunk.com/products/splunk/releases/6.4.2/linux/splunk-6.4.2-00f5bb3fa822-linux-2.6-amd64.deb'
  else
    default['splunk']['forwarder']['url'] = 'https://download.splunk.com/products/universalforwarder/releases/6.4.2/linux/splunkforwarder-6.4.2-00f5bb3fa822-linux-2.6-intel.deb'
    default['splunk']['server']['url'] = 'http://download.splunk.com/products/splunk/releases/6.3.3/linux/splunk-6.3.3-f44afce176d0-linux-2.6-intel.deb'
  end
when 'omnios'
  default['splunk']['forwarder']['url'] = 'https://download.splunk.com/products/universalforwarder/releases/6.4.2/solaris/splunkforwarder-6.4.2-00f5bb3fa822-solaris-10-intel.pkg.Z'
  default['splunk']['server']['url'] = 'https://download.splunk.com/products/splunk/releases/6.4.2/solaris/splunk-6.4.2-00f5bb3fa822-solaris-10-intel.pkg.Z'
end
