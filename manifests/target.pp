# user_password: a password for the user,
#                so users can directly login.
#                Mandatory if ensure is present.
# sshkey: the ssh key for the user, is mandatory if
#         ensure is present.
# target: On which directory the backup user has access.
#         Required.
define ibackup::target(
  $target,
  $ensure                 = 'present',
  $sshkey                 = 'absent',
  $user_password          = 'absent',
  $user_password_crypted  = true,
  $directory_mode         = '0600',
){

  if ($ensure=='present') and
    (($sshkey=='absent') or ($user_password=='absent')) {
    fail("You must set \$sshkey & \$user_password on Ibackup::Target[${name}]!")
  }

  $password = $user_password ? {
    'trocla'  => trocla("ibackup_${name}",'sha512crypt'),
    default   => $user_password
  }
  user::managed{$name:
    ensure           => $ensure,
    groups           => 'backup',
    require          => Group['backup'],
    password         => $password,
    password_crypted => $user_password_crypted,
    purge_ssh_keys   => true,
  }

  $ensure_target = $ensure ? {
    'present' => directory,
    default   => absent
  }
  file{$target:
      ensure => $ensure_target,
  }

  if ($ensure != 'present'){
    exec{"remove_${target}":
      command => "rm -rf ${target}",
      onlyif  => "test -d ${target}",
      before  => File[$target],
    }
    File[$target]{
      purge   => true,
      force   => true,
      backup  => false,
      recurse => true,
      before  => User[$name],
    }
  } else {
    File[$target]{
      require => User[$name],
      owner   => $name,
      group   => 0,
      mode    => $directory_mode,
    }
    sshd::authorized_key{"backupkey_${name}":
      ensure  => $ensure,
      key     => $sshkey,
      user    => $name,
      options => ["command=\"/usr/local/bin/rrsync ${target}\"",
        'no-pty','no-X11-forwarding','no-agent-forwarding',
        'no-port-forwarding'],
      require => File[$target],
    }
  }
}
