define ibackup::disk(
    $device,
    $fstype = 'ext3'
){
    include ibackup::disks

    file{"/data/backup_${name}":
        ensure => directory,
        owner => root, group => 0, mode => 0755;
    }

    mount{"/data/backup_${name}":
        device => $device,
        ensure => mounted,
        fstype => $fstype,
        options => 'nodev,noexec',
        require => File["/data/backup_${name}"],
    }
}
