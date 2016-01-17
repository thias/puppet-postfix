# Define postfix::instances::enable
#
# Executes postmulti enable if needed
#

define postfix::instances::enable (
    $instance = $title,
) {

    if ($instance != 'postfix') {
        exec { "enable-instance-${instance}":
            command => "postmulti -i ${instance} -e enable",
#        unless  => "grep -q 'multi_instance_enable = yes' ${config_dir}/main.cf",
#            require => Exec["init-instance-${instance}"]
        }
    }

}