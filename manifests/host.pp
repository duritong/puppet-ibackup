# manifests/host.pp

class ibackup::host {
    include rsync::rrsync

    group{'backup':
        ensure => present,
    }
}
