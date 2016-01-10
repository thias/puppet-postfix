# Class postfix::spamassassin
#
# Installs spamassasin

class postfix::spamassassin (
    # Spamassassin
    $spamassassin         = false,
    $sa_required_hits     = '5',
    $sa_report_safe       = '0',
    $sa_rewrite_header    = [],
    $sa_trusted_networks  = '10/8 172.16/12 192.168/16',
    $sa_skip_rbl_checks   = '1',
    $sa_loadplugin        = [ 'Mail::SpamAssassin::Plugin::SPF' ],
    $sa_score             = [ 'FH_DATE_PAST_20XX 0' ],
    $spampd_port          = '10026',
    $spampd_relayport     = '10027',
    $spampd_children      = '20',
    $spampd_maxsize       = '512',

    $spamassassin_package = $::postfix::params::spamassassin_package,
    $spampd_package       = $::postfix::params::spampd_package,
    $spampd_config        = $::postfix::params::spampd_config,
    $spampd_template      = $::postfix::params::spampd_template,
){

    # Optional Spamassassin setup (using spampd)
     if $spamassassin {
        # Main packages and service they provide
        package { [ $spamassassin_package, $spampd_package ]: ensure => installed }

        # Note that we don't want the normal spamassassin (spamd) service
        service { 'spampd':
            require   => Package[$spampd_package],
            enable    => true,
            ensure    => running,
            hasstatus => true,
        }

        # Override the options passed to spampd
        file { $spampd_config:
            content => template($spampd_template),
            notify  => Service['spampd'],
        }

        # Change the spamassassin options
        file { '/etc/mail/spamassassin/local.cf':
            require => Package[$spamassassin_package],
            content => template('postfix/spamassassin-local.cf.erb'),
            notify  => Service['spampd'],
        }
    }

}
