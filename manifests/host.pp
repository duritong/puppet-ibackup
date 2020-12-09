# a backup host
class ibackup::host {
  include rsync::rrsync

  group{'backup':
    ensure => present,
  }

  Ibackup::Target<<| tag == $facts['fqdn'] |>>
}
