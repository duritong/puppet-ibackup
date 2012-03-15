define ibackup::sftpuser(
  $ensure = 'present',
  $uid = 'iuid',
  $password = 'trocla'
){
  $base_path = hiera('ibackup_sftpuser_base_path','/srv/backup')
  $user_name = "sb_$name"
  user::sftp_only{$user_name:
    ensure => $ensure,
    uid => $uid ? {
      'iuid' => iuid($user_name,'sftp_backup'),
      default => $uid
    },
    gid => 'uid',
    password => $password ? {
      'trocla' => trocla("sftp_backup_${user_name}",'sha512crypt'),
      default => $password
    },
    homedir_mode => 0700,
    homedir => "${base_path}/${user_name}"
  }

  file{"${base_path}/${user_name}/backup":
    ensure => directory,
    owner => $user_name, group => $user_name, mode => 0700;
  }
}
