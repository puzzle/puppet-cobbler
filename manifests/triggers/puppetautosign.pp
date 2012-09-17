# manifests/puppetautosign.pp

class cobbler::triggers::puppetautosign {
    file{'/var/lib/cobbler/triggers/install/pre/puppetautosign_pre.py':
        source => [ "puppet:///modules/site_cobbler/triggers/install/pre/${fqdn}/puppetautosign_pre.py",
                    "puppet:///modules/site_cobbler/triggers/install/pre/puppetautosign_pre.py",
                    "puppet:///modules/cobbler/triggers/install/pre/puppetautosign_pre.py" ],
        require => Package['cobbler'],
        owner => root, group => 0, mode => 0755;
    }
    file{'/var/lib/cobbler/triggers/install/post/puppetautosign_post.py':
        source => [ "puppet:///modules/site_cobbler/triggers/install/post/${fqdn}/puppetautosign_post.py",
                    "puppet:///modules/site_cobbler/triggers/install/post/puppetautosign_post.py",
                    "puppet:///modules/cobbler/triggers/install/post/puppetautosign_post.py" ],
        require => Package['cobbler'],
        owner => root, group => 0, mode => 0755;
    }

    file{'/etc/puppet/autosign.conf':
        ensure => present,
        replace => false,
        owner => root, group => 0, mode => 0644;
    }
}
