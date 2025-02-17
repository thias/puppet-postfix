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
  $postfixdir = '/etc/postfix',
  $owner      = 'root',
  $group      = 'root',
  $mode       = '0644',
  $content    = undef,
  $source     = undef,
  $ensure     = undef,
  $postmap    = $::postfix::params::postmap
) {

  file { "${postfixdir}/${title}":
    owner     => $owner,
    group     => $group,
    mode      => $mode,
    content   => $content,
    source    => $source,
    ensure    => $ensure,
    show_diff => false,
    backup    => false,
  }

  if $ensure == 'absent' {

    file { "${postfixdir}/${title}.db": ensure => absent }

  } else {

    exec { "${postmap} ${title}":
      cwd       => $postfixdir,
      subscribe => File["${postfixdir}/${title}"],
      creates   => "${postfixdir}/${title}.db",
      # No need to notify the service, since it detects changed files
    }

  }

}

