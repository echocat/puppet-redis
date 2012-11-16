class redis {}

class redis::server(
		$redis_version = "2.6.4",
		$redis_memory = 100,
		$redis_ip = "127.0.0.1",
		$redis_port = 6379,
		$redis_mempolicy = "allkeys-lru",
		$redis_timeout = 0,
		$redis_nr_dbs = 1,
		$redis_dir = "/var/lib/redis",
		$redis_loglevel = "notice",
		$running = "true",
		$enabled = "true") inherits redis {


	# install redis

	package { "redis make tools":
		name => ["make", "gcc"],
		ensure => installed 
	}

	exec {
		"Download and untar redis $redis_version":
			command => "wget -O - http://redis.googlecode.com/files/redis-${redis_version}.tar.gz | tar xz",
			creates => "/opt/redis-${redis_version}",
			cwd => "/opt";
		"Compile redis $redis_version":
			command => "make",
			creates => "/opt/redis-${redis_version}/src/redis-server",
			cwd => "/opt/redis-${redis_version}/",
			require => [Package["redis make tools"],Exec["Download and untar redis $redis_version"]];
	}

	file {
		"/opt/redis":
			ensure => link,
			target => "/opt/redis-${redis_version}/src/",
			require => Exec["Compile redis $redis_version"];
		"/etc/redis.conf":
			ensure => present,
			content => template("redis/etc/redis.conf.erb"),
			require => File["/opt/redis"];
		"/etc/init.d/redis-server":
			ensure => present,
			mode => 755,
			content => template("redis/etc/init.d/redis-server.erb"),
			require => File["/etc/redis.conf"],
			notify => Service["redis-server"];
		"${redis_dir}":
			ensure => directory,
			require => Exec["Compile redis $redis_version"];
	}

	service {
		"redis-server":
			ensure => $running,
			enable => $enabled,
			hasstatus => true,
			hasrestart => true,
			require => File["/etc/init.d/redis-server"];
	}

}

