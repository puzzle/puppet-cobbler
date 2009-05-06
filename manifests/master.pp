# Use this on a cobbler master
# This class will additionally deploy
# sync scripts for the repositories
class cobbler::master {
    include cobbler

    file{'/opt/bin/reposync.sh':
        source => [ "puppet://$server/files/cobbler/scripts/${fqdn}/reposync.sh",
                    "puppet://$server/files/cobbler/scripts/reposync.sh",
                    "puppet://$server/cobbler/scripts/reposync.sh" ],
        require => Package['yum-utils'],
        owner => root, group => 0, mode => 0700;
    }
    file{'/etc/cron.d/cobbler_reposync':
        source => [ "puppet://$server/files/cobbler/cron/${fqdn}/cobbler_reposync",
                    "puppet://$server/files/cobbler/cron/cobbler_reposync",
                    "puppet://$server/cobbler/cron/cobbler_reposync" ],
        require => File['/opt/bin/reposync.sh'],
        owner => root, group => 0, mode => 0744;
    }
}
