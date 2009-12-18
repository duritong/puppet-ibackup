# user_password: a password for the user,
#                so users can directly login.
#                Mandatory if ensure is present.
# sshkey: the ssh key for the user, is mandatory if
#         ensure is present.
# target: On which directory the backup user has access.
#         Required.
define ibackup::target(
    $ensure = 'present',
    $sshkey = 'absent',
    $sshkey_type = 'ssh-rsa',
    $user_password = 'absent',
    $user_password_crypted = true,
    $target
){

    if ($ensure=='present'){
      if ($sshkey=='absent') or ($user_password=='absent'){
        fail("You must set \$sshkey and \$user_password on Ibackup::Target[${name}]!")
      }
    }

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
    }

    sshd::ssh_authorized_key{"backupkey_${name}":
        ensure => $ensure,
        type => $sshkey_type,
        user => $name,
        options => ["command=\"/usr/local/bin/rrsync ${target}\"",'no-pty','no-X11-forwarding','no-agent-forwarding','no-port-forwarding'],
    }

    if ($ensure!='present'){
      File["$target"]{
        purge => true,
        force => true,
        backup => false,
        recurse => true,
        before => User["$name"],
      }
      Sshd::Ssh_authorized_key["backupkey_${name}"]{
        before => User["$name"],
      }
    } else {
      File["$target"]{
        require => User["$name"],
        owner => $name, group => 0, mode => 0600,
      }
      Sshd::Ssh_authorized_key["backupkey_${name}"]{
        key => $sshkey,
        require => File["$target"],
      }
    }
}
