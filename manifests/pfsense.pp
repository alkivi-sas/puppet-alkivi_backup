class alkivi_backup::pfsense(
) {


  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
  }

  # Backup script
  file { '/root/alkivi-scripts/alkivi-backup-pfsense':
    mode    => '0750',
    source  => 'puppet:///modules/alkivi_backup/alkivi-backup-pfsense',
    require => File['/root/alkivi-scripts/'],
  }
}
