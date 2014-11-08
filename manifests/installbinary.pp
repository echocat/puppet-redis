# Helper define for installing redis binary.
define redis::installbinary (
  $redis_build_dir,
  $redis_install_dir,
  $redis_binary = $name
) {

  file { "${redis_install_dir}/${redis_binary}":
    ensure  => file,
    source  => "${redis_build_dir}/redis/${redis_binary}",
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Anchor['redis::install']
  }

}
