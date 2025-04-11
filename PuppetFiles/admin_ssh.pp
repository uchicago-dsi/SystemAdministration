
#######################################
####New class for storage-cluster1####
#/etc/puppetlabs/code/modules/role/dsi_cluster/manifests

class dsi_cluster::admin_ssh {

  $ds_admin_user = '__ds_admin_ssh'
  $home_dir      = "/tank/homes/${ds_admin_user}"
  $ssh_dir       = "${home_dir}/.ssh"
  $ssh_key       = "puppet:///modules/dsi_cluster/ds_admin_ssh/ds_admin_id_rsa.pub"

  user { $ds_admin_user:
    ensure     => present,
    home       => $home_dir,
    managehome => true,
    shell      => '/bin/bash',
    uid        => 27124,
    gid        => 30712,
  }

  file { $home_dir:
    ensure  => directory,
    owner   => $ds_admin_user,
    group   => $ds_admin_user,
    mode    => '0755',
    require => User[$ds_admin_user],
  }

  file { $ssh_dir:
    ensure  => directory,
    owner   => $ds_admin_user,
    group   => $ds_admin_user,
    mode    => '0700',
    require => File[$home_dir],
  }

  file { "${ssh_dir}/authorized_keys":
    ensure  => present,
    source  => $ssh_key,
    owner   => $ds_admin_user,
    group   => $ds_admin_user,
    mode    => '0600',
    require => File[$ssh_dir],
  }

  #This is included on this class
  #I think I should create a class with this on the nodes we want the user admin has root privileges
  #or paste it on each node on /hiera/nodes/xxx.yaml
  file { "/etc/sudoers.d/20_${ds_admin_user}":
    ensure  => file,
    content => "${ds_admin_user} ALL=(ALL) NOPASSWD: ALL\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    require => User[$ds_admin_user],
  }
}


#############################################
#####file where the admin_ssh class will be included##########

class dsi_cluster::storage($variant) {

  include mollyguard
  include dsi_cluster::prometheus::node

case $variant {
  'tank': {
    include dsi_cluster::nfsserver
    include dsi_cluster::quotaserver::server
    include znapzend
    file { '/etc/exports.d/dsi_cluster.exports':
      source => "puppet:///modules/dsi_cluster/${facts['networking']['fqdn']}/dsi_cluster.exports",
      mode => '0644',
      notify => Exec['exportfs'],
    }
  }
'home': {
  include dsi_cluster::nfsserver
  include dsi_cluster::homeutils
  include znapzend
  #############NEW ENTRY#########################
  include dsi_cluster::admin_ssh #new entry class

  file { '/etc/exports.d/dsi_cluster.exports':
    source => "puppet:///modules/dsi_cluster/${facts['networking']['fqdn']}/dsi_cluster.exports",
    mode => '0644',
    notify => Exec['exportfs'],
  }

  file { '/root/tools':
    source => "puppet:///modules/dsi_cluster/${facts['networking']['fqdn']}/admintools",
    recurse => true,
    mode => 'u+rwx',
  }
  .
  .
  .
  .
  .
  .
  .
  .
  .
  .
  .
}