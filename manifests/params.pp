class postfix::params {
  if $::osfamily == 'Debian' {
    $daemon_directory = '/usr/lib/postfix'
  } else {
    $daemon_directory = '/usr/libexec/postfix'
  }
}