class alkivi_backup::install () {
  # We want to install lots of defaut packages
  Package { ensure => installed }

  $alkivi_backup_packages = [ 'duplicity', 'python-paramiko' ]

  package { $alkivi_backup_packages: }
}
