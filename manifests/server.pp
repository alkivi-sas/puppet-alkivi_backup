class alkivi_backup::server (
  $customers = {},
  $extra     = {},
) {
  validate_hash($customers)
  validate_hash($extra)

  $customers.each { |$name, $dataHash|
    if($dataHash['remote_backup'])
    {
      validate_string($dataHash['local_user'])

      user { $dataHash['local_user']:
        ensure => present,
        home   => "/home/alkivi-backup/$name",
      }

      file { "/home/alkivi-backup/$name":
        ensure => directory,
        owner  => $dataHash['local_user'],
        group  => $dataHash['local_user'],
        mode   => '0770',
      }

      file { "/home/alkivi-backup/$name/.ssh":
        ensure  => directory,
        owner   => $dataHash['local_user'],
        group   => $dataHash['local_user'],
        mode    => '0700',
        require => File["/home/alkivi-backup/$name"],
      }

      file { "/home/alkivi-backup/$name/.ssh/authorized_keys":
        ensure  => present,
        owner   => $dataHash['local_user'],
        group   => $dataHash['local_user'],
        mode    => '0644',
        require => File["/home/alkivi-backup/$name/.ssh"],
      }
    }
  }

  $extra.each { |$name, $login|
    user { $login:
      ensure => present,
      home   => "/home/alkivi-backup/$name",
    }

    file { "/home/alkivi-backup/$name":
      ensure => directory,
      owner  => $login,
      group  => $login,
      mode   => '0770',
    }

    file { "/home/alkivi-backup/$name/.ssh":
      ensure  => directory,
      owner   => $login,
      group   => $login,
      mode    => '0700',
      require => File["/home/alkivi-backup/$name"],
    }

    file { "/home/alkivi-backup/$name/.ssh/authorized_keys":
      ensure  => present,
      owner   => $login,
      group   => $login,
      mode    => '0644',
      require => File["/home/alkivi-backup/$name/.ssh"],
    }
  }
}

