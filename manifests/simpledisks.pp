# manifests/simpledisks.pp

class ibackup::simpledisks {
    include securefile

    group{'ibackup':
        ensure => present,
    }

    file{'/e/backup':
        ensure => directory,
        require => [ File['/e/.issecure'], Group['ibackup'] ],
        owner => root, group => ibackup, mode => 0750;
    }
    file{ [ '/e/backup/bin', '/e/backup/keys' ]:
        ensure => directory,
        owner => root, group => 0, mode => 0700;
    }
    file{'/e/backup/data':
        ensure => directory,
        require => Group['ibackup'],
        owner => root, group => ibackup, mode => 0750;
    }
}
