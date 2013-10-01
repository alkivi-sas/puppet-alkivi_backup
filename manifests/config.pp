class alkivi_backup::config () {
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
