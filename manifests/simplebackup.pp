
# this class deploys a basic backup script
# on the host. The script is either choosen by
# the fqdn of the host or by a variable $ibackup_type.
class ibackup::simplebackup {
    include ibackup::simpledisks

    include rsync::client
    if $use_shorewall {
        include shorewall::rules::out::ibackup
    }

    file{'/e/backup/bin/ext_backup.sh':
        source => [ "puppet://$server/modules/site-ibackup/scripts/${fqdn}/ext_backup.sh",
                    "puppet://$server/modules/site-ibackup/scripts/${ibackup_type}/ext_backup.sh" ],
        require => File['/e/backup/bin'],
        owner => root, group => 0, mode => 0700;
    }

    file{'/e/backup/bin/ext_backup.config':
        source => "puppet://$server/modules/site-ibackup/scripts/${fqdn}/ext_backup.config",
        require => File['/e/backup/bin'],
        owner => root, group => 0, mode => 0600;
    }

    securefile::deploy { 'backup1.glei.ch_ssh_key':
        source  => "backup/keys/${fqdn}/backup1.glei.ch",
        path    => 'backup/keys/backup1.glei.ch',
        require => File['/e/backup/keys'],
        owner => root, group => 0, mode => 0600;
    }

    case $kernel {
        default: {
            file{'/etc/cron.daily/ext_backup.sh':
                ensure => '/e/backup/bin/ext_backup.sh',
                require => [ Securefile::Deploy['backup1.glei.ch_ssh_key'], File['/e/backup/bin/ext_backup.sh'] ],
            }
        }
        openbsd: {
            cron { 'ibackup_job':
                command => '/e/backup/bin/ext_backup.sh',
                minute => '15',
                hour => '2',
                require => [ Securefile::Deploy['backup1.glei.ch_ssh_key'], File['/e/backup/bin/ext_backup.sh'] ],
            }  
        }
    }
}
