## 2018-02-01 - 2.1.0 (Feature/Bugfix release)

#### Features:

- Add `redis_disable_commands` parameter to redis::server

#### Bugfixes:

- Fix systemd Ubuntu
- Systemd: fix permission issue with `redis_run_dir` / `sentinel_run_dir`
- Some more fixes for init.d

## 2016-11-15 - 2.0.0 (Feature/Bugfix release)

#### Bugfixes:

- Fix broken systemd part for Debian
- Fix cluster coverage error in redis.conf template
- Add required update-rc.d headers to debian init.d scripts
- Fix ensure_packages expects an array

#### Features:

- Redis, Sentinel: allow turning off protected mode
- Server: Added option to redis.conf: client-output-buffer-limit, as a hash
- Server: Added  option to redis.conf: repl_backlog_size, a simple value
- Server: add include parameter for config
- allows for compatibility with Amazon Linux
- Add cluster params documentation + enable cluster support
- Add redis_disable_commands

## 2016-06-24 - 1.9.0 (Feature/Bugfix release)

#### Bugfixes:

- (734defe) redis-check-dump was renamed to redis-check-rdb in redis version 3.2

#### Features:

- (123f474) Add initial cluster support to redis::server

## 2016-04-08 - 1.8.1 (Bugfix release)

#### Bugfixes:

- (318d2cb) RedHat 7: fix systemd scripts for Server and Sentinel 

## 2016-04-05 - 1.8.0 (Feature/Bugfix release)

#### Features:

- (e37283e) Add the possibility to exclude logrotate
- (316f492) RedHat 7: add systemd support
- (316f492) Sentinel: add parameter `sentinel_ip` for binding address
- (3fdbca0) Server::install: add parameter `download_base` at install class to specify download url of source tar.gz
- (e47fc28) Gentoo: add support for Gentoo

#### Bugfixes:

- (6dea873) fix source entry for forge api in metadata.json

## 2015-12-02 - 1.7.0 (Feature/Bugfix release)

#### Features:

- (3236f41) #33 add Scientific Linux support
- (ad5d3c1) #37 Server: add parameters `redis_usesocket` `redis_socket` `redis_socketperm` `redis_memsamples`
- (edf870b) #31 Server: add parameters `force_rewrite`
- (e1c2011) #53 Server: add parameters `hash_max_ziplist_entries` and `hash_max_ziplist_value`
- (f1006e2) #48 Server: add parameters `redis_user` and `redis_group`
- (42bb23f) #44 Sentinel: explititly define sentinel pidfile

#### Bugfixes:

- (3e920e3) #35 Server: correct usage of `redis_timeout` in servers
- (f8e44b2) #39 avoid conflicts build-essential
- (75cffe8) #51 prevent default redis-server from automatically start


## 2015-05-11 - 1.6.0 (Feature/Bugfix release)

#### Features:

- Issue #22 Sentinel: add `force_rewrite` parameter for sentinel.conf
- Issue #22 Sentinel: add parameter `sentinel_pid_dir`

#### Bugfixes:

- Fixes #22 fix sentinel pid and log locations in init script
- Fixes #23 RedHat: fix stop in initscript (remove signal -QUIT)

## 2015-04-21 - 1.5.0 (Feature release)

#### Features:

- Issue #20 use curl instead of wget for download

## 2015-04-14 - 1.4.0 (Feature release)

#### Features:

- Issue #18 add support for SLES
- Issue #17 better support for old redis 2.4.x

## 2015-02-26 - 1.3.0 (Feature/Bugfix release)

#### Features:

- Issue #16 add ability to set save db values

#### Bugfixes:

- fix duplication directory error, if multiple redis are on the same node

## 2015-02-11 - 1.2.4 (Bugfix release)

#### Bugfixes:

- remove Modulefile
- add basic rspec tests
- fix license
- add support for non default redis directory creation

## 2014-12-05 - 1.2.3 (Bugfix release)

#### Bugfixes:

- Debian: fix package name to redis-server

## 2014-12-03 - 1.2.2 (Bugfix release)

#### Bugfixes:

- use ensure_packages to avoid redeclares
- update stdlib version requirement, because of ensure_packages
- small fix in README examples

## 2014-11-28 - 1.2.1 (Bugfix release)

#### Bugfixes:

- add missing dependency for puppetlabs/stdlib
- some puppet linting

## 2014-11-08 - 1.2.0 (Feature release)

#### Features:

- support install via REPO instead of compile from source
- new examples in README
- lots of new parameters for master/slave
- lots of new parameters for aof and co

## 2014-04-11 - 1.1.0 (Feature release)

#### Features:

- add support for sentinel. See `redis::sentinel`

## 2014-04-09 - 1.0.0

#### Features:

- download, compile, install redis
- install multiple redis instances

