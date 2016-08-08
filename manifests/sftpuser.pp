# manage a simple user that can be used
# as an sftp target to push backups to.
# "backup space for users"
define ibackup::sftpuser(
  $ensure = 'present',
  $uid = 'iuid',
  $password = 'trocla',
){
  include ::ibackup::sftpuser::base
  $path = "${ibackup::sftpuser::base::path}/${user_name}"
  $user_name = "sb_${name}"
  $real_password = $password ? {
    'trocla' => trocla("sftp_backup_${user_name}",'sha512crypt'),
    default => $password
  }
  $real_uid = $uid ? {
    'iuid'  => iuid($user_name,'sftp_backup'),
    default => $uid
  }
  user::sftp_only{$user_name:
    ensure       => $ensure,
    uid          => $real_uid,
    gid          => 'uid',
    password     => $real_password,
    homedir_mode => '0700',
    homedir      => $path,
  }

  file{
    $path:
      ensure => directory,
      owner  => root,
      group  => $user_name,
      mode   => '0750';
    "${path}/backup":
      ensure => directory,
      owner  => $user_name,
      group  => $user_name,
      mode   => '0700';
  }
}
