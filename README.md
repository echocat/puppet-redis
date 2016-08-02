#redis

####Table of Contents

1. [Overview - What is the redis module?](#overview)
2. [Setup - The basics of getting started with redis](#setup)
    * [Beginning with redis - Installation](#beginning-with-redis)
    * [Run multiple instances on same host](#run-multiple-instances-on-same-host)
    * [Create a cluster-enabled instance](#Create a cluster-enable instance)
    * [Setting up sentinel with two monitors](#setting-up-sentinel-with-two-monitors)
3. [Usage - The class and defined types available for configuration](#usage)
    * [Classes and Defined Types](#classes-and-defined-types)
        * [Class: redis::install](#class-redisinstall)
        * [Defined Type: redis::server](#defined-type-redisserver)
        * [Defined Type: redis::sentinel](#defined-type-redissentinel)
4. [Requirements](#requirements)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributing to the redis module](#contributing)

##Overview

This module installs and makes basic configs for multiple redis instances on
the same node. It installs redis via REPO or from source. (http://redis.io/)
It also can configure the monitoring server Sentinel.

[![Puppet Forge](http://img.shields.io/puppetforge/v/dwerder/redis.svg)](https://forge.puppetlabs.com/dwerder/redis)
[![Build Status](https://secure.travis-ci.org/echocat/puppet-redis.png?branch=master)](https://travis-ci.org/echocat/puppet-redis)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/dwerder/redis.svg)](https://forge.puppetlabs.com/dwerder/redis)

##Setup

**What redis affects:**

* packages/configuration to compile and install redis from source
* services/configuration files to run multiple redis and sentinels

###Beginning with redis

To just compile and install redis binaries. As default the
latest stable release will be used.

```puppet
  class { 'redis::install': }
```

To install a specific redis version use the following parameters.
Most of the time you will only need `redis_version`.

```puppet
  class { 'redis::install':
    redis_version     => '2.8.8',
    redis_build_dir   => '/opt',
    redis_install_dir => '/usr/bin'
  }
```
To install redis from package use the following parameters.
You will need `redis_version` and `redis_package`.
```puppet
  class { 'redis::install':
    redis_version  => '2.8.18-1.el6.remi',
    redis_package  => true,
  }
```

###Run multiple instances on same host

As example run two redis instances on port 6379 and 6380.

```puppet
node 'redis.my.domain' {

  # install latest stable build.
  class { 'redis::install': }

  redis::server {
    'instance1':
      redis_memory    => '1g',
      redis_ip        => '0.0.0.0',
      redis_port      => 6379,
      redis_mempolicy => 'allkeys-lru',
      redis_timeout   => 0,
      redis_nr_dbs    => 16,
      redis_loglevel  => 'notice',
      running         => true,
      enabled         => true
  }

  redis::server {
    'secondRedis':
      redis_memory    => '112m',
      redis_ip        => '0.0.0.0',
      redis_port      => 6380,
      redis_mempolicy => 'allkeys-lru',
      redis_timeout   => 0,
      redis_nr_dbs    => 2,
      redis_loglevel  => 'warning',
      running         => true,
      enabled         => true
  }
}
```

###Run highly available on different hosts

As example of running a high availability cluster with authentication enabled.

```puppet
node 'redis-master.my.domain' {

  # install latest stable build.
  class { 'redis::install': }

  redis::server {
    'master':
      redis_memory               => '1g',
      redis_ip                   => '0.0.0.0',
      redis_port                 => 6379,
      running                    => true,
      enabled                    => true,
      requirepass                => 'some_really_long_random_password',
      client_output_buffer_limit => {
        'normal' => '0 0 0',
        'slave'  => '500000000 300000000 60',
      },
  }
}

node 'redis-slave.my.domain' {

  # install latest stable build.
  class { 'redis::install': }

  redis::server {
    'slave':
      redis_memory    => '1g',
      redis_ip        => '0.0.0.0',
      redis_port      => 6379,
      running         => true,
      enabled         => true,
      requirepass     => 'some_really_long_random_password',
      slaveof         => 'redis-master.my.domain 6379',
      masterauth      => 'some_really_long_random_password',
  }
}
```

###Create a cluster-enable instance

Please note that right now you can only create cluster-enabled instances
but you cannot configure a Redis Cluster only with this module. You should
still use `redis-trib.rb` from Redis source distribution or configure it
by hand with redis cluster commands. Moreover, the cluster mode will be enabled
only for Redis >= 3.0

A simple example of a cluster-enabled instance, with a timeout of 5 seconds to
detect if another node is dead.

```puppet
node 'redis-cluster.my.domain' {

  # install latest stable build.
  class { 'redis::install': }

  redis::server {
    'cluster-instance':
      redis_memory         => '1g',
      redis_ip             => '0.0.0.0',
      redis_port           => 6379,
      running              => true,
      enabled              => true,
      cluster_enabled      => true,
      cluster_node_timeout => '5000',
  }
}
```

### Example using Hiera

    redis::install::redis_package: true
    redis::install::redis_version: '2:2.8.17-1+deb8u1'
    redis::servers:
      'name_server':
        requirepass: 'strongpass'
        enabled: true
        redis_ip: '0.0.0.0'
        redis_port: '6800'
        redis_log_dir: '/var/log/redis/'

###Setting up sentinel with two monitors

You can create multiple sentinels on one node. But most of the time you will
want to create a sentinel with one or more monitors configured.

```puppet
node 'sentinel.my.domain' {

  # install latest stable build.
  class { 'redis::install': redis_version => '2.8.8' }

  redis::sentinel {'clusters':
    monitors => {
      'mymaster' => {
        master_host             => '127.0.0.1',
        master_port             => 6378,
        quorum                  => 2,
        down_after_milliseconds => 30000,
        parallel-syncs          => 1,
        failover_timeout        => 180000
      },
      'securetRedisCluster' => {
        master_host             => '10.20.30.1',
        master_port             => 6379,
        quorum                  => 2,
        down_after_milliseconds => 30000,
        parallel-syncs          => 5,
        failover_timeout        => 180000,
        auth-pass => 'secret_Password',
        notification-script => '/tmp/notify.sh',
        client-reconfig-script => '/tmp/reconfig.sh'
      }
    }
  }
```

##Usage

###Classes and Defined Types

This module compiles and installs redis with the class `redis::install`.
The redis service(s) are configured with the defined type `redis::server`.

####Class: `redis::install`

This class downloads, compiles and installs redis. It does not configure any
redis services. This is done by defined type redis::server.

**Parameters within `redis::install`:**

#####`redis_version`

The redis version to be installed.
By default, the latest stable build will be installed.

#####`redis_build_dir`

Default is '/opt/' (string)
The dir to store redis source code. This will result in a
directoy like '/opt/redis-2.8.8/'

#####`redis_install_dir`

Default is '/usr/bin' (string).
The dir to which the newly built redis binaries are copied.

#####`redis_user`

Redis system user. Default: undef (string)
Default 'undef' results to 'root' as redis system user

Some redis install packages create the redis system user by default (at
least SLES and Ubuntu provide redis install packages).
Normally the log directory and the pid directory are created also by
the redis install package. Therefor, these values must be adjusted too.


#####`redis_group`

Redis system group. Default: undef (string)
Default 'undef' results to 'root' as redis system group

#####`download_base`

Url where to find the source tar.gz.
Default value is 'http://download.redis.io/releases'

####Defined Type: `redis::server`

Used to configure redis instances. You can setup multiple redis servers on the
same node. See the setup examples.

**Parameters within `redis::server`

#####`redis_name`

Name of Redis instance. Default: call name of the function.
The name is used to create the init script(s), which follows the pattern
`redis-server_${redis_name}`

#####`redis_memory`

Default is '100mb' (string).
Sets amount of memory used. eg. 100mb or 4g.

#####`redis_ip`

Default is '127.0.0.1' (string). Listen IP of redis.

#####`redis_port`

Listen port of Redis. Default: 6379

#####`redis_usesocket`

To enable unixsocket options. Default: false

#####`redis_socket`

Unix socket to use. Default: /tmp/redis.sock

#####`redis_socketperm`

Permission of socket file. Default: 755

#####`redis_mempolicy`

Algorithm used to manage keys. See Redis docs for possible values. Default: allkeys-lru

#####`redis_memsamples`

Number of samples to use for LRU policies. Default: 3

#####`redis_timeout`

Default: 0

#####`redis_nr_dbs`

Number of databases provided by redis. Default: 1

#####`redis_dbfilename`

Name of database dump file. Default: dump.rdb

#####`redis_dir`

Default is '/var/lib' (string)
Path for persistent data. Path is <redis_dir>/redis_<redis_name>/.

#####`redis_pid_dir`

Default is '/var/run' (string).
Path for pidfile. Full pidfile path is <redis_pid_dir>/redis_<redis_name>.pid.

#####`redis_log_dir`

Default is '/var/log' (string).
Path for log. Full log path is <redis_log_dir>/redis_<redis_name>.log.

#####`redis_loglevel`

Loglevel of Redis. Default: 'notice' (string)

#####`running`

Configure if Redis should be running or not. Default: true (boolean)

#####`enabled`

Configure if Redis is started at boot. Default: true (boolean)

#####`requirepass`

Supply a password if you want authentication with Redis. Default: undef (string)

#####`maxclients`

Max clients of Redis instance. Default: undef (number)

#####`appendfsync_on_rewrite`

Configure the no-appendfsync-on-rewrite variable. Set to yes to enable the option. Defaults off. Default: false (boolean)

#####`aof_rewrite_percentage`

Configure the percentage size difference between the last aof filesize and the newest to trigger a rewrite. Default 100

#####`aof_rewrite_minsize`

Configure the minimum size in mb of the aof file to trigger size comparisons for rewriting. Default: 64

#####`redis_appendfsync`

Configure the value for when an fsync should happen. Values are either everysec, always, or no. Default: everysec

#####`redis_append_enable`

Enable or disable the appendonly file option. Default: false (boolean)

#####`redis_enabled_append_file`

Enable custom append file. Default: false (boolean)

#####`redis_append_file`

Define the path for the append file. Optional. Default: undef

#####`save`

Configure Redis save snapshotting. Example: [[900, 1], [300, 10]]. Default: []

#####`force_rewrite`

Boolean. Default: `false`

Configure if the redis config is overwritten by puppet followed by a restart.
Since redis automatically rewrite their config since
version 2.8 setting this to `true` will trigger a redis restart on each puppet
run with redis 2.8 or later.

#####`client_output_buffer_limit`

Hash containing 3 possible classes as keys (normal, slave, pubsub) and with the
values set to the hard limit, soft limit and seconds.
Default: empty

#####`manage_logrotate`

Configure logrotate rules for redis server. Default: true

##### High Availability Options

#####`slaveof`

Configure Redis Master on a slave. Default: undef (string)

#####`masterauth`

Password used when connecting to a master server which requires authentication. Default: undef (string)

#####`slave_server_stale_data`

Configure Redis slave to server stale data. Default: true (boolean)

#####`slave_read_only`

Configure Redis slave to be in read-only mode. Default: true (boolean)

#####`repl_timeout`

Configure Redis slave replication timeout in seconds. Default: 60 (number)

#####`repl_backlog_size`

Configure Redis slave backlog size in bytes. Default: undef

#####`repl_ping_slave_period`

Configure Redis replication ping slave period in seconds. Default: 10 (number)

##### Cluster Options

#####`cluster_enabled`

Enable Redis Cluster. Supported only in Redis 3.x. Default: false

#####`cluster_node_timeout`

Timeout in ms to declare a node as failed.

#####`cluster_slave_validity_factor`

Configure slave validity factor. Please read the Redis documentation to learn more about this parameter.

#####`cluster_migration_barrier`

Slaves migrate to orphaned masters only if there are still at least this given number of other working slaves for their old master.

#####`cluster_require_full_coverage`

By default Redis Cluster nodes stop accepting queries if they detect there is at least an hash slot uncovered.

####Defined Type: `redis::sentinel`

Used to configure sentinel instances. You can setup multiple sentinel servers
on the same node. And you can configure multiple monitors within a sentinel.
See the setup examples.

**Parameters within `redis::sentinel`

#####`sentinel_name`

Name of Redis instance. Default: call name of the function.
The name is used to create the init script(s), which follows the pattern
`redis-sentinel_${sentinel_name}`

#####`sentinel_ip`

Listen IP of sentinel. Default: 6379

#####`sentinel_port`

Listen port of sentinel. Default: 6379

#####`sentinel_log_dir`

Default is '/var/log' (string).
Path for log. Full log path is `sentinel_log_dir`/sentinel_`sentinel_name`.log.

#####`sentinel_pid_dir`

Default is '/var/run' (string).
Path for pid file. Full pid file path is `sentinel_pid_dir`/sentinel_`sentinel_name`.pid.

#####`sentinel_run_dir`

Default: `/var/run/redis` (string)
Since sentinels automatically rewrite their config since version 2.8 the puppet managed config will be copied
to this directory and than sentinel will start with this copy.

#####`monitors`

Default is
```
{
  'mymaster' => {
    master_host             => '127.0.0.1',
    master_port             => 6379,
    quorum                  => 2,
    down_after_milliseconds => 30000,
    parallel-syncs          => 1,
    failover_timeout        => 180000,
    ### optional
    auth-pass => 'secret_Password',
    notification-script => '/var/redis/notify.sh',
    client-reconfig-script => '/var/redis/reconfig.sh'
  },
}
```
Hashmap of monitors.

#####`running`

Configure if Redis should be running or not. Default: true (boolean)

#####`enabled`

Configure if Redis is started at boot. Default: true (boolean)

#####`force_rewrite`

Boolean. Default: `false`

Configure if the sentinels config is overwritten by puppet followed by a
sentinel restart. Since sentinels automatically rewrite their config since
version 2.8 setting this to `true` will trigger a sentinel restart on each puppet
run with redis 2.8 or later.

#####`manage_logrotate`

Configure logrotate rules for redis server. Default: true

##Requirements

###Modules needed:

stdlib by puppetlabs

###Software versions needed:

facter > 1.6.2
puppet > 2.6.2

##Limitations

This module is tested on CentOS 6.5 and Debian 7 (Wheezy) and should also run without problems on

* RHEL/CentOS/Scientific 6+
* Debian 6+
* Ubunutu 10.04 and newer
* SLES 11 SP3

Limitation on SLES:
 * Installation from source is not tested
 * Redis sentinel configuration/management is not tested

##Contributing

Echocat modules are open projects. So if you want to make this module even better, you can contribute to this module on [Github](https://github.com/echocat/puppet-redis).
