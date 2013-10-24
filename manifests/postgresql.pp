class alkivi_backup::postgresql(
  $server             = 'localhost',
  $db_exclude         = [],
  $do_monthly         = '02',
  $do_weekly          = '6',
  $rotation_daily     = '7',
  $rotation_weekly    = '35',
  $rotation_monthly   = '150',
  $mailcontent        = 'quiet',
  $mail_address       = 'backup@alkivi.fr',
  $single_transaction = 'yes',
) {


  validate_string($server)

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
  }

  # Backup script
  file { '/root/alkivi-scripts/alkivi-backup-pgsql':
    mode    => '0750',
    source  => 'puppet:///modules/alkivi_backup/alkivi-backup-pgsql',
    require => File['/root/alkivi-scripts/'],
  }

  file { '/root/backup-pgsql':
    ensure => directory,
    mode   => '0750',
  }

  # Backup conf
  file { '/etc/alkivi.conf.d/backup-pgsql.conf':
    mode    => '0640',
    content => template('alkivi_backup/backup-pgsql.conf.erb'),
    require => File['/etc/alkivi.conf.d/'],
  }

  # Crontab
  cron { 'pgsql-backup':
    command => '/root/alkivi-scripts/alkivi-backup-pgsql 1>/dev/null',
    user    => root,
    hour    => 1,
    minute  => 42,
  }
}
