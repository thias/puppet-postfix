# define: postfix::dbfile
#
# Parameters:
#  $postfixdir:
#    Directory where to manage the dbfile. Default: /etc/postfix
#  $owner:
#    The dbfile owner. Default: root
#  $group:
#    The dbfile group. Default: root
#  $mode:
#    The dbfile mode. Default: 0644
#  $content:
#    The dbfile content, typically from a template. Default: none
#  $source:
#    The dbfile source file. Default: none
#  $ensure:
#    The dbfile's presence. Use 'absent' to remove it. Default: present
#
# Sample Usage :
#   postfix::dbfile { 'virtual':
#     source => 'puppet:///modules/mymodule/postfix/virtual',
#   }
#
define postfix::dbfile (
  $postfixdir            = '/etc/postfix',
  $owner                 = 'root',
  $group                 = 'root',
  $mode                  = '0644',
  $content               = undef,
  $source                = undef,
  $ensure                = undef,
  $postmap               = $::postfix::params::postmap,
  $default_database_type = $::postfix::params::default_database_type,
) {

  file { "${postfixdir}/${title}":
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => $content,
    source  => $source,
    ensure  => $ensure,
  }

  if $ensure == 'absent' {

    file { [
      # All possible files we might have created with supported file_type
      "${postfixdir}/${title}.db",
      "${postfixdir}/${title}.lmdb",
    ]:
      ensure => 'absent',
    }

  } else {

    exec { "${postmap} ${default_database_type}:${title}":
      cwd         => $postfixdir,
      subscribe   => File["${postfixdir}/${title}"],
      refreshonly => true,
      # No need to notify the service, since it detects changed files
    }

  }

}

