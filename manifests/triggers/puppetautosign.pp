# manifests/puppetautosign.pp

class cobbler::triggers::puppetautosign {
    file{'/var/lib/cobbler/triggers/add/system/post/puppetautosign.py':
        source => [ "puppet://$server/files/cobbler/triggers/add/system/post/${fqdn}/puppetautosign.py",
                    "puppet://$server/files/cobbler/triggers/add/system/post/puppetautosign.py",
                    "puppet://$server/cobbler/triggers/add/system/post/puppetautosign.py" ],
        owner => root, group => 0, mode => 0755;
    }

    file{'/etc/puppet/autosign.conf':
        ensure => present,
        replace => false,
        owner => root, group => 0, mode => 0644;
    }
}
