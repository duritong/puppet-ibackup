# manifests/defines.pp

define ibackup::backup_target(
    $sshkey,
    $sshkey_tape = 'ssh-rsa',
    $target
){
    include ibackup::host

    user::define_user{"$name":
            groups => 'backup',
            require => Group['backup'],
    }

    file{"$target":
        ensure => directory,
        require => User["$name"],
        owner => $name, group => 0, mode => 0700;
    }

    sshd::ssh_authorized_key{"backupkey_${name}":
        type => $sshkey_type,
        user => $name,
        key => $sshkey,    
        options => ["command=\"/usr/local/bin/rrsync ${target}\"",'no-pty','no-X11-forwarding','no-agent-forwarding','no-port-forwarding'],
        require => File["$target"],
    }
}

define ibackup::backup_disk(
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
