# == Function: redis::server
#
# Function to configure an redis server.
#
# === Parameters
#
# [*redis_name*]
#   Name of Redis instance. Default: call name of the function.
# [*redis_memory*]
#   Sets amount of memory used. eg. 100mb or 4g.
# [*redis_ip*]
#   Listen IP. Default: 127.0.0.1
# [*redis_port*]
#   Listen port of Redis. Default: 6379
# [*redis_usesocket*]
#   To enable unixsocket options. Default: false
# [*redis_socket*]
#   Unix socket to use. Default: /tmp/redis.sock
# [*redis_socketperm*]
#   Permission of socket file. Default: 755
# [*redis_mempolicy*]
#   Algorithm used to manage keys. See Redis docs for possible values. Default: allkeys-lru
# [*redis_memsamples*]
#   Number of samples to use for LRU policies. Default: 3
# [*redis_timeout*]
#   Default: 0
# [*redis_nr_dbs*]
#   Number of databases provided by redis. Default: 1
# [*redis_dbfilename*]
#   Name of database dump file. Default: dump.rdb
# [*redis_dir*]
#   Path for persistent data. Path is <redis_dir>/redis_<redis_name>/. Default: /var/lib
# [*redis_log_dir*]
#   Path for log. Full log path is <redis_log_dir>/redis_<redis_name>.log. Default: /var/log
# [*redis_loglevel*]
#   Loglevel of Redis. Default: notice
# [*running*]
#   Configure if Redis should be running or not. Default: true
# [*enabled*]
#   Configure if Redis is started at boot. Default: true
# [*requirepass*]
#   Configure Redis AUTH password
# [*maxclients*]
#   Configure Redis maximum clients
# [*appendfsync_on_rewrite*]
#   Configure the no-appendfsync-on-rewrite variable.
#   Set to yes to enable the option. Defaults off. Default: false
# [*aof_rewrite_percentage*]
#   Configure the percentage size difference between the last aof filesize
#   and the newest to trigger a rewrite. Default: 100
# [*aof_rewrite_minsize*]
#   Configure the minimum size in mb of the aof file to trigger size comparisons for rewriting.
#   Default: 64 (integer)
# [*redis_enabled_append_file*]
#   Enable custom append file. Default: false
# [*redis_append_file*]
#   Define the path for the append file. Optional. Default: undef
# [*redis_append_enable*]
#   Enable or disable the appendonly file option. Default: false
# [*slaveof*]
#   Configure Redis Master on a slave
# [*masterauth*]
#   Password used when connecting to a master server which requires authentication.
# [*slave_server_stale_data*]
#   Configure Redis slave to server stale data
# [*slave_read_only*]
#   Configure Redis slave to be in read-only mode
# [*repl_timeout*]
#   Configure Redis slave replication timeout
# [*repl_ping_slave_period*]
#   Configure Redis replication ping slave period
# [*repl_backlog_size*]
#   Replication backlog size (in bytes or multiples). Default: undef
# [*save*]
#   Configure Redis save snapshotting. Example: [[900, 1], [300, 10]]. Default: []
# [*hash_max_ziplist_entries*]
#   Threshold for ziplist entries. Default: 512
# [*hash_max_ziplist_value*]
#   Threshold for ziplist value. Default: 64
#
# [*protected_mode*]
#   If no password and/or no bind address is set, redis defaults to being reachable only
#   on the loopback interface. Turn this behaviour off by setting protected mode to 'no'.
#
# [*redis_run_dir*]
#
#   Default: `/var/run/redis`
#
#   Since redis automatically rewrite their config since version 2.8 what conflicts with puppet
#   the config files created by puppet will be copied to this directory and redis will be started from
#   this copy.
#
# [*client_output_buffer_limit*]
#   Hash containing 3 possible classes as keys (normal, slave, pubsub) and
#   with the values set to the hard limit, soft limit and seconds.
#   Default: empty
#
# [*manage_logrotate*]
#   Configure logrotate rules for redis server. Default: true
#
# [*cluster_enabled*]
#   Enable Redis Cluster. Supported only in Redis 3.x. Default: false
#
# [*cluster_node_timeout*]
#   Timeout in ms to declare a node as failed.
#
# [*cluster_slave_validity_factor*]
#   Configure slave validity factor. Please read the Redis documentation to learn more
#   about this parameter.
#
# [*cluster_migration_barrier*]
#   Slaves migrate to orphaned masters only if there are still at least this
#   given number of other working slaves for their old master.
#
# [*cluster_require_full_coverage*]
#   By default Redis Cluster nodes stop accepting queries if they detect there
#   is at least an hash slot uncovered.

define redis::server (
  $redis_name                    = $name,
  $redis_memory                  = '100mb',
  $redis_ip                      = '127.0.0.1',
  $redis_port                    = 6379,
  $redis_usesocket               = false,
  $redis_socket                  = '/tmp/redis.sock',
  $redis_socketperm              = 755,
  $redis_mempolicy               = 'allkeys-lru',
  $redis_memsamples              = 3,
  $redis_timeout                 = 0,
  $redis_nr_dbs                  = 1,
  $redis_dbfilename              = 'dump.rdb',
  $redis_dir                     = '/var/lib',
  $redis_log_dir                 = '/var/log',
  $redis_pid_dir                 = '/var/run',
  $redis_run_dir                 = '/var/run/redis',
  $redis_loglevel                = 'notice',
  $redis_appedfsync              = 'everysec',
  $running                       = true,
  $enabled                       = true,
  $requirepass                   = undef,
  $maxclients                    = undef,
  $appendfsync_on_rewrite        = false,
  $aof_rewrite_percentage        = 100,
  $aof_rewrite_minsize           = 64,
  $redis_appendfsync             = 'everysec',
  $redis_enabled_append_file     = false,
  $redis_append_file             = undef,
  $redis_append_enable           = false,
  $slaveof                       = undef,
  $masterauth                    = undef,
  $slave_serve_stale_data        = true,
  $slave_read_only               = true,
  $repl_timeout                  = 60,
  $repl_ping_slave_period        = 10,
  $repl_backlog_size             = undef,
  $save                          = [],
  $hash_max_ziplist_entries      = 512,
  $hash_max_ziplist_value        = 64,
  $client_output_buffer_limit    = {},
  $manage_logrotate              = true,
  $cluster_enabled               = false,
  $cluster_node_timeout          = undef,
  $cluster_slave_validity_factor = undef,
  $cluster_migration_barrier     = undef,
  $cluster_require_full_coverage = true,
  $protected_mode                = undef,
) {
  $redis_user              = $::redis::install::redis_user
  $redis_group             = $::redis::install::redis_group

  $redis_install_dir = $::redis::install::redis_install_dir
  $redis_init_script = $::operatingsystem ? {
    /(Debian|Ubuntu)/                                          => 'redis/etc/init.d/debian_redis-server.erb',
    /(Fedora|RedHat|CentOS|OEL|OracleLinux|Amazon|Scientific)/ => 'redis/etc/init.d/redhat_redis-server.erb',
    /(SLES)/                                                   => 'redis/etc/init.d/sles_redis-server.erb',
    /(Gentoo)/                                                 => 'redis/etc/init.d/gentoo_redis-server.erb',
    default                                                    => undef,
  }
  $redis_2_6_or_greater = versioncmp($::redis::install::redis_version,'2.6') >= 0
  $redis_with_cluster_support = versioncmp($::redis::install::redis_version,'3.0') >= 0

  # redis conf file
  $conf_file_name = "redis_${redis_name}.conf"
  $conf_file = "/etc/${conf_file_name}"
  file { $conf_file:
      ensure  => file,
      content => template('redis/etc/redis.conf.erb'),
      require => Class['redis::install'];
  }

  # startup script
  if ($::osfamily == 'RedHat' and versioncmp($::operatingsystemmajrelease, '7') >=0 and $::operatingsystem != 'Amazon') {
    $service_file = "/usr/lib/systemd/system/redis-server_${redis_name}.service"
    exec { "systemd_service_${redis_name}_preset":
      command     => "/bin/systemctl preset redis-server_${redis_name}.service",
      notify      => Service["redis-server_${redis_name}"],
      refreshonly => true,
    }

    file { $service_file:
      ensure  => file,
      mode    => '0644',
      content => template('redis/systemd/redis.service.erb'),
      require => [
        File[$conf_file],
        File["${redis_dir}/redis_${redis_name}"]
      ],
      notify  => Exec["systemd_service_${redis_name}_preset"],
    }
  } else {
    $service_file = "/etc/init.d/redis-server_${redis_name}"
    file { $service_file:
      ensure  => file,
      mode    => '0755',
      content => template($redis_init_script),
      require => [
        File[$conf_file],
        File["${redis_dir}/redis_${redis_name}"]
      ],
      notify  => Service["redis-server_${redis_name}"],
    }
  }

  # path for persistent data
  # If we specify a directory that's not default we need to pass it as hash
  # and ensure that we do not have duplicate warning, when we have multiple
  # redis Instances on one host
  if ! defined(File[$redis_dir]) {
    file { $redis_dir:
      ensure  => directory,
      require => Class['redis::install'],
    }
  }

  file { "${redis_dir}/redis_${redis_name}":
    ensure  => directory,
    require => Class['redis::install'],
    owner   => $redis_user,
    group   => $redis_group,
  }

  if ($manage_logrotate == true){
    # install and configure logrotate
    if ! defined(Package['logrotate']) {
      package { 'logrotate': ensure => installed; }
    }

    file { "/etc/logrotate.d/redis-server_${redis_name}":
      ensure  => file,
      content => template('redis/redis_logrotate.conf.erb'),
      require => [
        Package['logrotate'],
        File[$conf_file],
      ]
    }
  }

  # manage redis service
  service { "redis-server_${redis_name}":
    ensure     => $running,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => File[$service_file],
    subscribe  => File[$conf_file],
  }
}
