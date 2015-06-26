# == Defined Type: redis::sentinel
# Function to configure an redis sentinel server.
#
# === Parameters
#
# [*sentinel_name*]
#   Name of Sentinel instance. Default: call name of the function.
# [*sentinel_port*]
#   Listen port of Redis. Default: 26379
# [*sentinel_log_dir*]
#   Path for log. Full log path is <sentinel_log_dir>/redis-sentinel_<redis_name>.log. Default: /var/log
# [*sentinel_pid_dir*]
#   Path for pid file. Full pid path is <sentinel_pid_dir>/redis-sentinel_<redis_name>.pid. Default: /var/run
# [*monitors*]
#   Default is
# {
#   'mymaster' => {
#     master_host             => '127.0.0.1',
#     master_port             => 6379,
#     quorum                  => 2,
#     down_after_milliseconds => 30000,
#     parallel-syncs          => 1,
#     failover_timeout        => 180000,
#     ## optional
#     auth-pass => 'secret_Password',
#     notification-script => '/var/redis/notify.sh',
#     client-reconfig-script => '/var/redis/reconfig.sh'
#   },
# }
#   All information for one or more sentinel monitors in a Hashmap.
# [*running*]
#   Configure if Sentinel should be running or not. Default: true
# [*enabled*]
#   Configure if Sentinel is started at boot. Default: true
# [*force_rewrite*]
#
#   Boolean. Default: `false`
#
#   Configure if the sentinels config is overwritten by puppet followed by a
#   sentinel restart. Since sentinels automatically rewrite their config since
#   version 2.8 setting this to `true` will trigger a sentinel restart on each puppet
#   run with redis 2.8 or later.
#
define redis::sentinel (
  $ensure           = 'present',
  $sentinel_name    = $name,
  $sentinel_port    = 26379,
  $sentinel_log_dir = '/var/log',
  $sentinel_pid_dir = '/var/run',
  $monitors         = {
    'mymaster' => {
      master_host             => '127.0.0.1',
      master_port             => 6379,
      quorum                  => 2,
      down_after_milliseconds => 30000,
      parallel-syncs          => 1,
      failover_timeout        => 180000,
# optional
# auth-pass => 'secret_Password',
# notification-script => '/var/redis/notify.sh',
# client-reconfig-script => '/var/redis/reconfig.sh',
    }
  },
  $running          = true,
  $enabled          = true,
  $force_rewrite    = false,
) {

  # validate parameters
  validate_bool($force_rewrite)
  
  $redis_install_dir = $::redis::install::redis_install_dir
  $sentinel_init_script = $::operatingsystem ? {
    /(Debian|Ubuntu)/                                          => 'redis/etc/init.d/debian_redis-sentinel.erb',
    /(Fedora|RedHat|CentOS|OEL|OracleLinux|Amazon|Scientific)/ => 'redis/etc/init.d/redhat_redis-sentinel.erb',
    default                                                    => UNDEF,
  }

  # redis conf file
  file {
    "/etc/redis-sentinel_${sentinel_name}.conf":
      ensure  => file,
      content => template('redis/etc/sentinel.conf.erb'),
      replace => $force_rewrite,
      require => Class['redis::install'];
      
  }->

  # startup script
  file { "/etc/init.d/redis-sentinel_${sentinel_name}":
    ensure  => file,
    mode    => '0755',
    content => template($sentinel_init_script),
  }~>

  # manage sentinel service
  service { "redis-sentinel_${sentinel_name}":
    ensure     => $running,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
  }

  # install and configure logrotate
  if ! defined(Package['logrotate']) {
    package { 'logrotate': ensure => installed; }
  }

  file { "/etc/logrotate.d/redis-sentinel_${sentinel_name}":
    ensure  => file,
    content => template('redis/sentinel_logrotate.conf.erb'),
    require => [
      Package['logrotate'],
      File["/etc/redis-sentinel_${sentinel_name}.conf"],
    ]
  }

}
