# Module redis

This module installs and makes basic configs for multiple redis instances on the same node.
It installs redis from source. (http://redis.googlecode.com)

# Tested on
RHEL/CentOS/Scientific 6+

# Sample usage:

### Running two redis instances on port 6379 and 6380
<pre>
node "redis.my.domain" {

	include redis::install

	redis::server {
		"instance1":
			redis_memory    => "1g",
			redis_ip        => "0.0.0.0",
			redis_port      => 6379,
			redis_mempolicy => "allkeys-lru",
			redis_timeout   => 0,
			redis_nr_dbs    => 16,
			redis_loglevel  => "notice",
			running         => "true",
			enabled         => "true",
	}

	redis::server {
		"secondRedis":
			redis_memory    => "112m",
			redis_ip        => "0.0.0.0",
			redis_port      => 6380,
			redis_mempolicy => "allkeys-lru",
			redis_timeout   => 0,
			redis_nr_dbs    => 2,
			redis_loglevel  => "info",
			running         => "true",
			enabled         => "true",
	}
}
</pre>


