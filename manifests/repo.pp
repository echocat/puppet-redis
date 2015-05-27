# Configure package repository
#
class redis::repo {
  $msg_no_repo = "No repo available for ${::osfamily}/${::operatingsystem}"

  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Ubuntu': {
          include ::redis::repo::ubuntu
        }
        default: {
          fail($msg_no_repo)
        }
      }
    }
    default: {
      fail($msg_no_repo)
    }
  }
}
