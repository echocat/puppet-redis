# == Class: redis
#
# Empty pseudo class, Not used.
#
# === Parameters
#
# None.
#
class redis inherits redis::params {}

# == Class: redis::install
#
# Installs redis from source (http://redis.googlecode.com).
# Has to be includes before the redis::server functions are called.
#
# === Parameters
#
# [*redis_version*]
#   The redis version to be installed. By default, the latest stable build will be installed.
#
# [*redis_build_dir*]
#   The dir to store redis source code.
#
# [*redis_install_dir*]
#   The dir to which the newly built redis binaries are copied. Default value is '/usr/bin'.
#
class redis::install (
	$redis_version     = $redis::params::redis_version,
	$redis_build_dir   = $redis::params::redis_build_dir,
	$redis_install_dir = $redis::params::redis_install_dir,
) inherits redis {

	# install necessary packages for build.
	case $::operatingsystem {
		'Debian', 'Ubuntu': {
			package { 'build-essential':
				before => Anchor['redis::prepare_build'],
				ensure => installed,
			}
		}

		'Fedora', 'RedHat', 'CentOS', 'OEL', 'OracleLinux', 'Amazon': {
			package { 'make':
				before => Anchor['redis::prepare_build'],
				ensure => installed,
			}

			package { 'gcc':
				before => Anchor['redis::prepare_build'],
				ensure => installed,
			}

			package { 'glibc-devel':
				before => Anchor['redis::prepare_build'],
				ensure => installed,
			}
		}
	}

	exec { "Make dir ${redis_build_dir}":
		before => File["${redis_build_dir}"],

		command => "mkdir -p ${redis_build_dir}",
		creates => "${redis_build_dir}",
		path => "${::path}",
		cwd => '/',
		user => 'root',
		group => 'root',
	}

	file { "${redis_build_dir}":
		ensure => directory,
	}

    if $redis_version == $::redis::params::redis_version {
        $redis_download_url = "http://download.redis.io/redis-stable.tar.gz"
    } else {
        $redis_download_url = "http://download.redis.io/releases/redis-${redis_version}.tar.gz"
    }

	exec { "Download and untar redis ${redis_version}":
		require => File["${redis_build_dir}"],
		before => Anchor['redis::prepare_build'],

		command => "wget -O - ${redis_download_url} | tar xz",
		creates => "${redis_build_dir}/redis-${::redis::install::redis_version}",
		path => "${::path}",
		cwd => "${redis_build_dir}",
		user => 'root',
		group => 'root',
	}

	anchor { 'redis::prepare_build':
		before => Exec['redis::compile'],
	}

	# if this fails, then a 'make distclean' can help
	exec { 'redis::compile':
		command => 'make',
		creates => "${redis_build_dir}/redis-${redis_version}/src/redis-server",
		cwd => "${redis_build_dir}/redis-${::redis::install::redis_version}/",
		path => "${::path}",
		user => 'root',
		group => 'root',
	}

	file { "${redis_build_dir}/redis":
		require => Exec["redis::compile"],

		ensure => link,
		target => "${redis_build_dir}/redis-${::redis::install::redis_version}/src/",
	}

	anchor { 'redis::install':
		require => File["${redis_build_dir}/redis"],
	}

	# install redis to system path.
	file { "${redis_install_dir}/redis-benchmark":
		require => Anchor['redis::install'],

		ensure => file,
		source => "${redis_build_dir}/redis/redis-benchmark",
		mode => 0755,
		owner => 'root',
		group => 'root',
	}

	file { "${redis_install_dir}/redis-check-aof":
		require => Anchor['redis::install'],

		ensure => file,
		source => "${redis_build_dir}/redis/redis-check-aof",
		mode => 0755,
		owner => 'root',
		group => 'root',
	}

	file { "${redis_install_dir}/redis-check-dump":
		require => Anchor['redis::install'],

		ensure => file,
		source => "${redis_build_dir}/redis/redis-check-dump",
		mode => 0755,
		owner => 'root',
		group => 'root',
	}

	file { "${redis_install_dir}/redis-cli":
		require => Anchor['redis::install'],

		ensure => file,
		source => "${redis_build_dir}/redis/redis-cli",
		mode => 0755,
		owner => 'root',
		group => 'root',
	}

	file { "${redis_install_dir}/redis-sentinel":
		require => Anchor['redis::install'],

		ensure => file,
		source => "${redis_build_dir}/redis/redis-sentinel",
		mode => 0755,
		owner => 'root',
		group => 'root',
	}

	file { "${redis_install_dir}/redis-server":
		require => Anchor['redis::install'],

		ensure => file,
		source => "${redis_build_dir}/redis/redis-server",
		mode => 0755,
		owner => 'root',
		group => 'root',
	}
}

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
		$redis_memory     = "100mb",
		$redis_ip         = "127.0.0.1",
		$redis_port       = 6379,
		$redis_mempolicy  = "allkeys-lru",
		$redis_timeout    = 0,
		$redis_nr_dbs     = 1,
		$redis_dbfilename = "dump.rdb",
		$redis_dir        = "/var/lib",
		$redis_log_dir    = "/var/log",
		$redis_loglevel   = "notice",
		$redis_appedfsync = "everysec",
		$running          = "true",
		$enabled          = "true",
) {
	$redis_install_dir = $::redis::install::redis_install_dir
	$redis_init_script = $::operatingsystem ? {
		/(Debian|Ubuntu)/                               => "redis/etc/init.d/debian_redis-server.erb",
		/(Fedora|RedHat|CentOS|OEL|OracleLinux|Amazon)/ => "redis/etc/init.d/redhat_redis-server.erb",
		default                                         => UNDEF,
	}

	# redis conf file
	file {
		"/etc/redis_${redis_name}.conf":
			ensure  => file,
			content => template("redis/etc/redis.conf.erb"),
			require => Class['redis::install'];
	}

	# startup script
	file { "/etc/init.d/redis-server_${redis_name}":
		ensure  => file,
		mode    => 0755,
		content => template("$redis_init_script"),
		require => [
			File["/etc/redis_${redis_name}.conf"],
			File["${redis_dir}/redis_${redis_name}"]
		],
		notify  => Service["redis-server_${redis_name}"],
	}

	# path for persistent data
	file { "${redis_dir}/redis_${redis_name}":
		ensure => directory,
		require => Class['redis::install'],
	}

	# install and configure logrotate
	if ! defined(Package['logrotate']) { package { 'logrotate': ensure => installed; } }

	file { "/etc/logrotate.d/redis-server_${redis_name}":
		content => template('redis/logrotate.conf.erb'),
		require => [
			Package['logrotate'],
			File["/etc/redis_${redis_name}.conf"],
		],
	}

	# manage redis service
	service { "redis-server_${redis_name}":
		ensure     => $running,
		enable     => $enabled,
		hasstatus  => true,
		hasrestart => true,
		require    => File["/etc/init.d/redis-server_${redis_name}"],
	}
}
