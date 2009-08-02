# user_password: a password for the user,
#                so users can directly login.
define ibackup::target(
    $sshkey,
    $sshkey_type = 'ssh-rsa',
    $user_password,
    $user_password_crypted = true,
    $target
){
    include ibackup::host

    user::managed{"$name":
        groups => 'backup',
        require => Group['backup'],
        password => $user_password,
        password_crypted => $user_password_crypted,
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
