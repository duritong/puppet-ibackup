# manifests/host.pp

class ibackup::host(
  $backup_domain
) {
  include rsync::rrsync

  group{'backup':
    ensure => present,
  }

  Ibackup::Target<<| tag == $backup_domain |>>

  @@sshkey{$backup_domain:
    type => 'ssh-rsa'',
    key => $sshrsakey,
    ensure => present,
    tag => $backup_domain,
  }
}
