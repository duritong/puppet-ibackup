# Setup for basic ibackup stuff
class ibackup::simpledisks {
  include securefile

  group{'ibackup':
    ensure  => present,
    gid     => 9998,
  }

  file{
    '/e/backup':
      ensure  => directory,
      require => File['/e/.issecure'],
      owner   => root,
      group   => ibackup,
      mode    => '0750';
    [ '/e/backup/bin', '/e/backup/keys' ]:
      ensure  => directory,
      owner   => root,
      group   => 0,
      mode    => '0700';
    '/e/backup/data':
      ensure  => directory,
      owner   => root,
      group   => ibackup,
      mode    => '0750';
  }
}
