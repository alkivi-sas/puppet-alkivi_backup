define alkivi_backup::pfsense::target(
  $server,
  $password,
  $backup_dir = '/home/alkivi/backup-pfsense',
  $username = 'admin',
  $port = '443',
  $gzip = '/bin/gzip',
  $find = '/usr/bin/find',
  $backup_days = '30',
) {

  validate_string($password)
  validate_string($server)
  validate_string($backup_dir)
  validate_string($username)
  validate_string($port)
  validate_string($gzip)
  validate_string($find)
  validate_string($backup_days)


  # Backup conf
  file { "/etc/alkivi.conf.d/backup-pfense-${title}.conf":
    mode    => '0640',
    content => template('alkivi_backup/backup-pfsense.conf.erb'),
    require => [File['/etc/alkivi.conf.d/'], Class['Alkivi_backup::Pfsense']],
  }

  # Crontab
  cron { "pfsense-backup-${title}":
    command => "/root/alkivi-scripts/alkivi-backup-pfsense -c /etc/alkivi.conf.d/backup-pfense-${title}.conf 1>/dev/null",
    user    => root,
    hour    => 2,
    minute  => 17,
  }
}
