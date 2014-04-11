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
# [*redis_mempolicy*]
#   Algorithm used to manage keys. See Redis docs for possible values. Default: allkeys-lru
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
#
define redis::server (
  $redis_name       = $name,
  $redis_memory     = '100mb',
  $redis_ip         = '127.0.0.1',
  $redis_port       = 6379,
  $redis_mempolicy  = 'allkeys-lru',
  $redis_timeout    = 0,
  $redis_nr_dbs     = 1,
  $redis_dbfilename = 'dump.rdb',
  $redis_dir        = '/var/lib',
  $redis_log_dir    = '/var/log',
  $redis_loglevel   = 'notice',
  $redis_appedfsync = 'everysec',
  $running          = true,
  $enabled          = true
) {

  $redis_install_dir = $::redis::install::redis_install_dir
  $redis_init_script = $::operatingsystem ? {
    /(Debian|Ubuntu)/                               => 'redis/etc/init.d/debian_redis-server.erb',
    /(Fedora|RedHat|CentOS|OEL|OracleLinux|Amazon)/ => 'redis/etc/init.d/redhat_redis-server.erb',
    default                                         => UNDEF,
  }

  # redis conf file
  file {
    "/etc/redis_${redis_name}.conf":
      ensure  => file,
      content => template('redis/etc/redis.conf.erb'),
      require => Class['redis::install'];
  }

  # startup script
  file { "/etc/init.d/redis-server_${redis_name}":
    ensure  => file,
    mode    => '0755',
    content => template($redis_init_script),
    require => [
      File["/etc/redis_${redis_name}.conf"],
      File["${redis_dir}/redis_${redis_name}"]
    ],
    notify  => Service["redis-server_${redis_name}"],
  }

  # path for persistent data
  file { "${redis_dir}/redis_${redis_name}":
    ensure  => directory,
    require => Class['redis::install'],
  }

  # install and configure logrotate
  if ! defined(Package['logrotate']) {
    package { 'logrotate': ensure => installed; }
  }

  file { "/etc/logrotate.d/redis-server_${redis_name}":
    ensure  => file,
    content => template('redis/redis_logrotate.conf.erb'),
    require => [
      Package['logrotate'],
      File["/etc/redis_${redis_name}.conf"],
    ]
  }

  # manage redis service
  service { "redis-server_${redis_name}":
    ensure     => $running,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => File["/etc/init.d/redis-server_${redis_name}"]
  }
}
