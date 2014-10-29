# == Class: redis::params
#
class redis::params {
  $redis_version         = 'stable'
  $redis_build_dir       = '/opt'
  $redis_install_dir     = '/usr/bin'
  $redis_install_package = false
}
