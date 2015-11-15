# a simple disk aka. mountpoint
define ibackup::disk(
  $device,
  $fstype  = 'ext4',
  $options = 'noatime,nodev,noexec'
){
  include ::ibackup::disks

  file{"/data/backup_${name}":
    ensure => directory,
    owner  => root,
    group  => 0,
    mode   => '0755';
  }

  mount{"/data/backup_${name}":
    ensure  => mounted,
    device  => $device,
    fstype  => $fstype,
    options => $options,
    require => File["/data/backup_${name}"],
  }
}
