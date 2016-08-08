# a class to manage a set of ibackup users
class ibackup::sftp(
  $users     = {},
){
  create_resources('ibackup::sftpuser',$users)
}

