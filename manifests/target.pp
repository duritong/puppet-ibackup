# user_password: a password for the user,
#                so users can directly login.
define ibackup::target(
    $ensure = 'present',
    $sshkey,
    $sshkey_type = 'ssh-rsa',
    $user_password,
    $user_password_crypted = true,
    $target
){
    include ibackup::host

    user::managed{"$name":
        ensure => $ensure,
        groups => 'backup',
        require => Group['backup'],
        password => $user_password,
        password_crypted => $user_password_crypted,
    }

    file{"$target":
        ensure => $ensure ? {
          'present' => directory,
          default => absent
        },
        require => User["$name"],
        owner => $name, group => 0, mode => 0600;
    }

    if ($ensure!='present'){
      File["$target"]{
        purge => true,
        force => true,
        backup => false,
        recurse => true,
      }
    }

    sshd::ssh_authorized_key{"backupkey_${name}":
        ensure => $ensure,
        type => $sshkey_type,
        user => $name,
        key => $sshkey,
        options => ["command=\"/usr/local/bin/rrsync ${target}\"",'no-pty','no-X11-forwarding','no-agent-forwarding','no-port-forwarding'],
        require => File["$target"],
    }
}
