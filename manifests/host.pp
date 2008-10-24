# manifests/host.pp

class ibackup::host {
    group{'backup':
        ensure => present,
    }
}
