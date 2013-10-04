# Class: postfix::params
#
class postfix::params {
  if $::osfamily == 'Debian' {
    $daemon_directory = '/usr/lib/postfix'
    $service_restart = '/usr/sbin/service postfix reload'
    $dovecot_directory = '/usr/lib/dovecot'
  } else {
    $daemon_directory = '/usr/libexec/postfix'
    $service_restart = '/sbin/service postfix reload'
    $dovecot_directory = '/usr/libexec/dovecot'
  }
}

