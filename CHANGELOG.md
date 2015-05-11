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

