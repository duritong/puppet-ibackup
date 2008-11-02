# manifests/simpledisks.pp

class ibackup::simpledisks {
    include securefile
    file{ [ '/e/backup', '/e/backup/bin', '/e/backup/data', '/e/backup/keys' ]:
        ensure => directory,
        require => File['/e/.issecure'],
        owner => root, group => 0, mode => 0700;
    }
}
