# manifests/disks.pp

class ibackup::disks {
  file{'/data':
    ensure => directory,
    owner  => root,
    group  => 0,
    mode   => '0755';
  }
}
