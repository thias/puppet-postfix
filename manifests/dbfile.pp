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
#  $type:
#    The dbfile type file. Default: none (Use: hash, pcre, cdb, dbm, btree)
#  $ensure:
#    The dbfile's presence. Use 'absent' to remove it. Default: present
#
# Sample Usage :
#   postfix::dbfile { 'virtual':
#     source => 'puppet:///modules/mymodule/postfix/virtual',
#   }
#
define postfix::dbfile (
  $postfixdir = '/etc/postfix',
  $owner      = 'root',
  $group      = 'root',
  $mode       = '0644',
  $content    = undef,
  $source     = undef,
  $type       = undef,
  $ensure     = undef,
  $postmap    = $::postfix::params::postmap
) {

  $extension = $type ? {
    'cdb'           => 'cdb',
    'pcre'          => 'pcre',
    'dbm'           => 'pag',
    /(btree|hash)/  => 'db',
    default         => 'db',
  }

  

  file { "${postfixdir}/${title}":
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => $content,
    source  => $source,
    ensure  => $ensure,
  }

  if $ensure == 'absent' {

    file { "${postfixdir}/${title}.${$extension}": ensure => absent }

  } else {

    exec { "${postmap} ${type}:${title}":
      cwd         => $postfixdir,
      subscribe   => File["${postfixdir}/${title}"],
      refreshonly => true,
      # No need to notify the service, since it detects changed files
    }

  }

}

