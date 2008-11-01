# manifests/simplebackup.pp

class ibackup::simplebackup {
    include securefile
    include rsync::client
    if $use_shorewall {
        include shorewall::backup
    }

    file{ [ '/e/backup', '/e/backup/bin', '/e/backup/data', '/e/backup/keys' ]:
        ensure => directory,
        require => File['/e/.issecure'],
        owner => root, group => 0, mode => 0700;
    }

    file{'/e/backup/bin/ext_backup.sh':
        source => "puppet://$server/files/backup/scripts/${fqdn}/ext_backup.sh",
        require => File['/e/backup/bin'],
        owner => root, group => 0, mode => 0700;
    }

    securefile::deploy { 'backup1.glei.ch_ssh_key':
        source  => "backup/keys/${fqdn}/backup1.glei.ch",
        path    => 'backup/keys/backup1.glei.ch',
        require => File['/e/backup/keys'],
        owner => root, group => 0, mode => 0600;
    }

    file{'/etc/cron.daily/ext_backup.sh':
        ensure => '/e/backup/bin/ext_backup.sh',
        require => [ Securefile::Deploy['backup1.glei.ch_ssh_key'], File['/e/backup/bin/ext_backup.sh'] ],
    }
}
