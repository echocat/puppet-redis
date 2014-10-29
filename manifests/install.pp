# == Class: redis::install
#
# Installs redis from source (http://redis.googlecode.com).
# Has to be includes before the redis::server functions are called.
#
# === Parameters
#
# [*redis_version*]
#   The redis version to be installed. By default, the latest stable build will be installed.
#
# [*redis_build_dir*]
#   The dir to store redis source code.
#
# [*redis_install_dir*]
#   The dir to which the newly built redis binaries are copied. Default value is '/usr/bin'.
#
# [*redis_package*]
#   Determines should we use a precompiled package or build from source. On CentOS depends on Remi repo for redis and EPEL repo for jmalloc packages.
#
class redis::install (
  $redis_version     = $::redis::params::redis_version,
  $redis_build_dir   = $::redis::params::redis_build_dir,
  $redis_install_dir = $::redis::params::redis_install_dir,
  $redis_package     = $::redis::params::redis_install_package
) inherits redis {
  # If we are installing redis from packages
  if ( $redis_package == true ) {
    case $::operatingsystem {
      'Fedora', 'RedHat', 'CentOS', 'OEL', 'OracleLinux', 'Amazon': {
        # Determine which version are we running and install EPEL/remi repos.
        #[epel]
        #name=Extra Packages for Enterprise Linux 6 - $basearch
        ##baseurl=http://download.fedoraproject.org/pub/epel/6/$basearch
        #mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=$basearch
        #failovermethod=priority
        #enabled=1
        #gpgcheck=1
        #gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

        yumrepo { 'epel':
          mirrorlist     => "http://mirrors.fedoraproject.org/metalink?repo=epel-${::operatingsystemmajrelease}&arch=\$basearch",
          enabled        => 1,
          gpgcheck       => 0,
        }

        yumrepo { 'remi':
          mirrorlist => "http://rpms.famillecollet.com/enterprise/${::operatingsystemmajrelease}/remi/mirror",
          enabled    => 1,
          gpgcheck   => 0,
          require    => Yumrepo['epel'],
        }
        if ( $redis_version ) {
          package { 'redis':
            ensure  => $redis_version,
            require => Yumrepo['remi'],
          }
        } else {
          package { 'redis':
            ensure  => installed,
            require => Yumrepo['remi']
          }
        }
      }
      default: {
        fail('This module does not support package based installation on this OS, please use source based method')
      }
    }

  } else {

    # install necessary packages for build.
    case $::operatingsystem {
      'Debian', 'Ubuntu': {
        package { 'build-essential':
          ensure => installed,
          before => Anchor['redis::prepare_build']
        }
      }

      'Fedora', 'RedHat', 'CentOS', 'OEL', 'OracleLinux', 'Amazon': {
        package { 'make':
          ensure => installed,
          before => Anchor['redis::prepare_build']
        }

        package { 'gcc':
          ensure => installed,
          before => Anchor['redis::prepare_build']
        }

        package { 'glibc-devel':
          ensure => installed,
          before => Anchor['redis::prepare_build']
        }
      }
      default: {
        fail('The module does not support this OS.')
      }
    }

    exec { "Make dir ${redis_build_dir}":
      command => "mkdir -p ${redis_build_dir}",
      creates => $redis_build_dir,
      path    => $::path,
      cwd     => '/',
      user    => 'root',
      group   => 'root',
      before  => File[$redis_build_dir]
    }

    file { $redis_build_dir:
      ensure => directory,
    }

    if $redis_version == $::redis::params::redis_version {
      $redis_download_url = 'http://download.redis.io/redis-stable.tar.gz'
    } else {
      $redis_download_url = "http://download.redis.io/releases/redis-${redis_version}.tar.gz"
    }

    exec { "Download and untar redis ${redis_version}":
      require => File[$redis_build_dir],
      before  => Anchor['redis::prepare_build'],
      command => "wget -O - ${redis_download_url} | tar xz",
      creates => "${redis_build_dir}/redis-${::redis::install::redis_version}",
      path    => $::path,
      cwd     => $redis_build_dir,
      user    => 'root',
      group   => 'root',
    }

    anchor { 'redis::prepare_build':
      before => Exec['redis::compile'],
    }

    # if this fails, then a 'make distclean' can help
    exec { 'redis::compile':
      command => 'make',
      creates => "${redis_build_dir}/redis-${redis_version}/src/redis-server",
      cwd     => "${redis_build_dir}/redis-${::redis::install::redis_version}/",
      path    => $::path,
      user    => 'root',
      group   => 'root',
    }

    file { "${redis_build_dir}/redis":
      ensure  => link,
      target  => "${redis_build_dir}/redis-${::redis::install::redis_version}/src/",
      require => Exec['redis::compile']
    }

    anchor { 'redis::install':
      require => File["${redis_build_dir}/redis"],
    }

    $redis_binaries = [
      'redis-benchmark',
      'redis-check-aof',
      'redis-check-dump',
      'redis-cli',
      'redis-sentinel',
      'redis-server'
    ]

    redis::installbinary { $redis_binaries:
      require           => Anchor['redis::install'],
      redis_build_dir   => $redis_build_dir,
      redis_install_dir => $redis_install_dir,
    }
  }
}
