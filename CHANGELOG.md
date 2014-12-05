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

