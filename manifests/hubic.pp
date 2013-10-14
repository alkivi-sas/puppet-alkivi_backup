class alkivi_backup::hubic (
  $hostname,

  $include_dir,
  $exclude_dir,

  $hubic_client_id,
  $hubic_client_secret,
  $hubic_refresh_token,

  $encryption        = 'yes',
  $root              = '/',

  $static_options    = '--full-if-older-than 14D --s3-use-new-style',
  $clean_up_type     = 'remove-all-but-n-full',
  $clean_up_variable = '2',

  $logdir            = '/home/alkivi/logs/',
  $log_file          = 'backup-`date +%Y-%m-%d_%H-%M`.txt',
  $log_owner         = 'alkivi:alkivi',
  $verbosity         = '-v3',

  $email             = 'monitoring@alkivi.fr',
  $email_from        = '',
  $email_subject     = 'Backup',

  $mail_command      = 'sendmail',
  $container         = 'default',


) {

  validate_string($encryption)
  validate_string($hubic_client_id)
  validate_string($hubic_client_secret)
  validate_string($hubic_refresh_token)
  validate_string($root)
  validate_array($include_dir)
  validate_array($exclude_dir)
  validate_string($static_options)


  $dest = "hubic://${container}"

  if($encryption == 'yes')
  {
  
    $passphrase = generate('/usr/bin/sudo', '/root/alkivi-scripts/genpwd', '--save', "hubic-${hostname}", '--savedir', '/root/.passwd/alkivi-backup', '--print', '--length', '45')
  }
  elsif($encryption == 'no')
  {
  }
  else
  {
    fail("Wrong parameter encryption ${encryption}")
  }

  if(!defined(Class['alkivi_backup::install']))
  {
    class { 'alkivi_backup::install': }
  }

  # declare relationships
  Class['alkivi_base'] ->
  Class['alkivi_backup::install'] ->
  Class['alkivi_backup::hubic']

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # Add file to the right places
  file { '/usr/share/pyshared/duplicity/backends/hubicbackend.py':
    source => 'puppet:///modules/alkivi_backup/hubic/hubicbackend.py',
  }

  file { '/usr/lib/python2.7/dist-packages/duplicity/backends/hubicbackend.py':
    ensure => link,
    target => '/usr/share/pyshared/duplicity/backends/hubicbackend.py',
  }

  if(!defined(File['/root/alkivi-scripts/alkivi-backup']))
  {
    file { '/root/alkivi-scripts/alkivi-backup':
      source  => 'puppet:///modules/alkivi_backup/alkivi-backup',
      require => File['/root/alkivi-scripts/'],
    }
  }

  file { '/etc/alkivi.conf.d/hubic-backup.conf':
    content => template('alkivi_backup/backup.conf.erb'),
    require =>  File['/etc/alkivi.conf.d/'],
    mode    => '0640',
  }

  cron { 'hubic-backup':
    command => '/root/alkivi-scripts/alkivi-backup --backup -c /etc/alkivi.conf.d/hubic-backup.conf',
    user    => root,
    hour    => 20,
    minute  => 42,
    weekday => ['5'],
  }


  package { 'python-swift':
    ensure => installed
  }


}

