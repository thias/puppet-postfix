# Define postfix::instances::create
#
# Executes postmulti create if needed
#

define postfix::instances::create (
    $instance = $title,
) {

    if ($instance != 'postfix') {
        exec { "init-instance-${instance}":
            command => "/usr/sbin/postmulti -I ${instance} -e create",
            unless  => "/usr/sbin/postmulti -l | /bin/grep '^${instance} '",
        }
    }

}