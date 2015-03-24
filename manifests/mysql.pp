class alkivi_backup::mysql(
  $server,
  $user               = 'root',
  $password           = undef,
  $host               = 'localhost',
  $backup_dir         = '/home/backup-mysql',
  $db_exclude         = ['information_schema', 'performance_schema', 'mysql' ],
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
  file { '/root/alkivi-scripts/alkivi-backup-mysql':
    mode    => '0750',
    source  => 'puppet:///modules/alkivi_backup/alkivi-backup-mysql',
    require => File['/root/alkivi-scripts/'],
  }

  file { $backup_dir:
    ensure => directory,
    mode   => '0750',
  }

  # Backup conf
  file { '/etc/alkivi.conf.d/backup-mysql.conf':
    mode    => '0400',
    content => template('alkivi_backup/backup-mysql.conf.erb'),
    require => File['/etc/alkivi.conf.d/'],
  }

  # Crontab
  cron { 'mysql-backup':
    command => '/root/alkivi-scripts/alkivi-backup-mysql 1>/dev/null',
    user    => root,
    hour    => 0,
    minute  => 42,
  }
}
