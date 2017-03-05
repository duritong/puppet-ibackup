# some disks deps
class ibackup::disks {
  file{'/data':
    ensure  => directory,
    owner   => root,
    group   => 0,
    seltype => 'default_t',
    mode    => '0755';
  }
}
