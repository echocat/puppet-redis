# == Class: redis::params
#
class redis::params {
  $redis_version = '2.8.3'
  $redis_build_dir = '/opt'
  $redis_install_dir = '/usr/bin'
}