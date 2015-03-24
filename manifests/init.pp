class alkivi_backup (
  $hostname,

  $include_dir,
  $exclude_dir,

  $encryption        = 'yes',
  $root              = '/',
  $backup_method     = 'ssh',
  $ssh_user          = 'alkivi-backup',
  $ssh_host          = 'admin.alkivi.fr',
  $ssh_port          = '2202',
  $ssh_dir           = '',
  $file_dir          = '',

  $static_options    = ['--full-if-older-than 14D',  '--s3-use-new-style',  '--archive-dir=/home/alkivi/.duplicity-cache'],
  $clean_up_type     = 'remove-all-but-n-full',
  $clean_up_variable = '2',

  $logdir            = '/home/alkivi/logs/backup/',
  $log_file          = 'backup-`date +%Y-%m-%d`.txt',
  $log_owner         = 'alkivi:alkivi',
  $verbosity         = '-v3',

  $email             = 'monitoring@alkivi.fr',
  $email_from        = '',
  $email_subject     = 'Backup',

  $mail_command      = 'sendmail',

  $swift_username    = undef,
  $swift_password    = undef,
  $swift_authurl     = undef,
  $swift_authversion = undef,
  $swift_tenantname  = undef,
  $swift_region      = undef,
  $swift_container   = undef,

) {

  validate_string($encryption)
  validate_string($root)
  validate_array($include_dir)
  validate_array($exclude_dir)
  validate_array($static_options)


  if($backup_method == 'ssh')
  {
    validate_string($ssh_user)
    validate_string($ssh_host)
    validate_string($ssh_port)
    #validate_string($ssh_dir)
    if($ssh_dir != '')
    {
      $dest = "ssh://${ssh_user}@${ssh_host}:${ssh_port}/${ssh_dir}"
    }
    else
    {
      $dest = "ssh://${ssh_user}@${ssh_host}:${ssh_port}"
    }
  }
  elsif($backup_method == 'file')
  {
    $dest = "file://${file_dir}"
  }
  elsif($backup_method == 'swift')
  {
    validate_string($swift_username)
    validate_string($swift_password)
    validate_string($swift_authurl)
    validate_string($swift_authversion)
    validate_string($swift_tenantname)
    validate_string($swift_region)
    $dest = "swift://${swift_container}"

  }
  else
  {
    fail("Backup method ${backup_method} is not currently supported")
  }

  if($encryption == 'yes')
  {
    $passphrase = generate('/usr/bin/sudo', '/root/alkivi-scripts/genpwd', '--save', $hostname, '--savedir', '/root/.passwd/alkivi-backup', '--print', '--length', '45')
  }
  elsif($encryption == 'no')
  {
  }
  else
  {
    fail("Wrong parameter encryption ${encryption}")
  }

  # declare all parameterized classes
  class { 'alkivi_backup::params': }
  class { 'alkivi_backup::install': }
  class { 'alkivi_backup::config': }
  class { 'alkivi_backup::service': }

  # declare relationships
  Class['alkivi_base'] ->
  Class['alkivi_backup::params'] ->
  Class['alkivi_backup::install'] ->
  Class['alkivi_backup::config'] ->
  Class['alkivi_backup::service']
}

