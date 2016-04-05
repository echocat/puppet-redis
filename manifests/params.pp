# == Class: redis::params
#
class redis::params {
  $redis_version         = 'stable'
  $redis_build_dir       = '/opt'
  $redis_install_dir     = '/usr/bin'
  $redis_install_package = false
  $download_tool         = 'curl -s -L'
  $redis_user            = undef
  $redis_group           = undef
  $download_base         = 'http://download.redis.io/releases'
}
