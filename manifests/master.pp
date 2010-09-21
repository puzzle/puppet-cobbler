# Use this on a cobbler master
# This class will additionally deploy
# sync scripts for the repositories
class cobbler::master {
  include cobbler

  file{'/opt/bin/reposync.sh':
    source => [ "puppet:///modules/site-cobbler/scripts/${fqdn}/reposync.sh",
                "puppet:///modules/site-cobbler/scripts/reposync.sh",
                "puppet:///modules/cobbler/scripts/reposync.sh" ],
    require => Package['yum-utils'],
    owner => root, group => 0, mode => 0700;
  }
  file{'/etc/cron.d/cobbler_reposync':
    content => "30 0 * * * root /opt/bin/reposync.sh\n",
    require => File['/opt/bin/reposync.sh'],
    owner => root, group => 0, mode => 0644;
  }
}
