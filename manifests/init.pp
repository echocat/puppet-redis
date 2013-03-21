# == Class: redis
#
# Empty pseudo class, Not used.
#
# === Parameters
#
# None.
#
class redis {}

# == Class: redis::install
#
# Installs redis from source (http://redis.googlecode.com).
# Has to be includes before the redis::server functions are called.
#
# === Parameters
#
# [*redis_version*]
#   The redis version to be installed.
#
class redis::install (
	$redis_version = "2.6.11"
) inherits redis {

	if ! defined(Package['make']) { package { 'make': ensure => installed; } }
	if ! defined(Package['gcc']) { package { 'gcc': ensure => installed; } }
	if ! defined(Package['glibc-devel']) { package { 'glibc-devel': ensure => installed; } }

	exec {
		"Download and untar redis ${::redis::install::redis_version}":
			command => "wget -O - http://redis.googlecode.com/files/redis-${::redis::install::redis_version}.tar.gz | tar xz",
			creates => "/opt/redis-${::redis::install::redis_version}",
			cwd => "/opt";
	}

	# if this fails, then a 'make distclean' can help
	exec {
		"Compile redis":
			command => 'make',
			creates => "/opt/redis-${redis_version}/src/redis-server",
			cwd => "/opt/redis-${::redis::install::redis_version}/",
			require => [
				Package['make'],
				Package['gcc'],
				Package['glibc-devel'],
				Exec["Download and untar redis ${::redis::install::redis_version}"]
			];
	}

	file {
		"/opt/redis":
			ensure => link,
			target => "/opt/redis-${::redis::install::redis_version}/src/",
			require => Exec["Compile redis"];
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
# [*redis_dir*]
#   Path for persistent data. Path is <redis_dir>_<redis_name>
# [*redis_loglevel*]
#   Loglevel of Redis. Default: notice
# [*running*]
#   Configure if Redis should be running or not. Default: true
# [*enabled*]
#   Configure if Redis is started at boot. Default: true
#
define redis::server (
		$redis_name      = $name,
		$redis_memory    = "100mb",
		$redis_ip        = "127.0.0.1",
		$redis_port      = 6379,
		$redis_mempolicy = "allkeys-lru",
		$redis_timeout   = 0,
		$redis_nr_dbs    = 1,
		$redis_dir       = "/var/lib/redis",
		$redis_loglevel  = "notice",
		$running         = "true",
		$enabled         = "true"
) {

	# redis conf file
	file {
		"/etc/redis_${redis_name}.conf":
			ensure  => file,
			content => template("redis/etc/redis.conf.erb"),
			require => Class['redis::install'];
	}

	# startup script
	file {
		"/etc/init.d/redis-server_${redis_name}":
			ensure  => file,
			mode    => 0755,
			content => template("redis/etc/init.d/redis-server.erb"),
			require => [
				File["/etc/redis_${redis_name}.conf"],
				File["${redis_dir}_${redis_name}"]
			],
			notify  => Service["redis-server_${redis_name}"];
	}

	# path for persistent data
	file {
		"${redis_dir}_${redis_name}":
			ensure => directory,
			require => Class['redis::install'];
	}

	# install and configure logrotate
	if ! defined(Package['logrotate']) { package { 'logrotate': ensure => installed; } }

	file {
		'/etc/logrotate.d/redis-server_${redis_name}':
			content => template('redis/logrotate.conf.erb'),
			require => [
				Package['logrotate'],
				File['/etc/redis_${redis_name}.conf'],
			]
	}

	# manage redis service
	service {
		"redis-server_${redis_name}":
			ensure     => $running,
			enable     => $enabled,
			hasstatus  => true,
			hasrestart => true,
			require    => File["/etc/init.d/redis-server_${redis_name}"];
	}
}
