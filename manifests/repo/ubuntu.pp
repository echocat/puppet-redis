# Configure ubuntu ppa
#
# === Parameters
#
class redis::repo::ubuntu () {
  include '::apt'

  ::apt::ppa { 'ppa:chris-lea/redis-server': }
}
