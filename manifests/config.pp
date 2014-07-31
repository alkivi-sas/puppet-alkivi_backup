class alkivi_backup::config (
    $encryption        = $alkivi_backup::encryption,
    $passphrase        = $alkivi_backup::passphrase,
    $root              = $alkivi_backup::root,
    $dest              = $alkivi_backup::dest,
    $include_dir       = $alkivi_backup::include_dir,
    $exclude_dir       = $alkivi_backup::exclude_dir,
    $static_options    = $alkivi_backup::static_options,
    $clean_up_type     = $alkivi_backup::clean_up_type,
    $clean_up_variable = $alkivi_backup::clean_up_variable,
    $logdir            = $alkivi_backup::logdir,
    $log_file          = $alkivi_backup::log_file,
    $log_owner         = $alkivi_backup::log_owner,
    $verbosity         = $alkivi_backup::verbosity,
    $email             = $alkivi_backup::email,
    $email_from        = $alkivi_backup::email_from,
    $email_subject     = $alkivi_backup::email_subject,
    $mail_command      = $alkivi_backup::mail_command,
) {
  File {
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
  }


  file { '/root/alkivi-scripts/alkivi-backup':
    source  => 'puppet:///modules/alkivi_backup/alkivi-backup',
    require => File['/root/alkivi-scripts/'],
  }

  file { '/etc/alkivi.conf.d/backup.conf':
    content => template('alkivi_backup/backup.conf.erb'),
    require =>  File['/etc/alkivi.conf.d/'],
    mode    => '0640',
  }

  cron { 'daily-backup':
    command => '/root/alkivi-scripts/alkivi-backup --backup',
    user    => root,
    hour    => 2,
    minute  => 42,
    weekday => ['1-5'],
  }

  cron { 'weekly-backup':
    command => '/root/alkivi-scripts/alkivi-backup --full',
    user    => root,
    hour    => 2,
    minute  => 42,
    weekday => 6,
  }

}
