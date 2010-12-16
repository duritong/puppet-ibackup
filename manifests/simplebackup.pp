
# this class deploys a basic backup script
# on the host. The script is either choosen by
# the fqdn of the host or by a variable $type.
class ibackup::simplebackup(
  $backup_host,
  $type,
  $ssh_key_basepath = "/etc/puppet/modules/site-securefile/files",
  $disk_target = "/srv/backups"
) {
    include ibackup::simpledisks

    include rsync::client
    if $use_shorewall {
        include shorewall::rules::out::ibackup
    }

    file{'/e/backup/bin/ext_backup':
        source => [ "puppet:///modules/site-ibackup/scripts/${fqdn}/ext_backup",
                    "puppet:///modules/site-ibackup/scripts/${type}/ext_backup" ],
        owner => root, group => 0, mode => 0700;
    }
    file{'/e/backup/bin/ext_backup.sh':
      ensure => absent,
    }

    file{'/e/backup/bin/ext_backup.config':
        source => [ "puppet:///modules/site-ibackup/scripts/${fqdn}/ext_backup.config",
                    "puppet:///modules/site-ibackup/scripts/${type}/ext_backup.config" ],
        owner => root, group => 0, mode => 0600;
    }

    # this will generate the source for the deply and the public key for the disk
    $ssh_keys = ssh_keygen("${$ssh_key_basepath}/backup/keys/${fqdn}/${backup_host}")

    securefile::deploy { "${backup_host}_ssh_key":
        source  => "backup/keys/${fqdn}/${backup_host}",
        path    => "backup/keys/${backup_host}",
        require => File['/e/backup/keys'],
        owner => root, group => 0, mode => 0600;
    }

    @@ibackup::disk{$fqdn:
      sshkey => $ssh_keys[1],
      target => "$disk_target/${$fqdn}",
      tag => $backup_host,
    }

    case $kernel {
        default: {
            file{'/etc/cron.daily/ext_backup':
                ensure => '/e/backup/bin/ext_backup',
                require => [ Securefile::Deploy["${backup_host}_ssh_key"], File['/e/backup/bin/ext_backup'] ],
            }
            file{'/etc/cron.daily/ext_backup.sh':
              ensure => absent,
            }
        }
        openbsd: {
            cron { 'ibackup_job':
                command => '/e/backup/bin/ext_backup',
                minute => '15',
                hour => '2',
                require => [ Securefile::Deploy["${backup_host}_ssh_key"], File['/e/backup/bin/ext_backup'] ],
            }  
        }
    }
}
