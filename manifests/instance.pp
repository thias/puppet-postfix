# Define: postfix::instance
#
# The title is used for the 'myhostname' parameter.
#
# When setting 'postgrey' to true, you might want to install a custom
# file as /etc/postfix/postgrey_whitelist_clients.local too.
#
# Sample Usage :
#
define postfix::instance (
  # See the main.cf comments for help on these options
  $myhostname = $::fqdn,
  $mydomain = false,
  $myorigin = '$myhostname',
  $inet_interfaces = 'localhost',
  $inet_protocols = 'all',
  $master_service_disable = false,
  $proxy_interfaces = false,
  $mydestination = '$myhostname, localhost.$mydomain, localhost',
  $local_recipient_maps = false,
  $luser_relay = false,
  $unknown_local_recipient_reject_code = '550',
  $mynetworks_style = false,
  $mynetworks = false,
  $relay_domains = false,
  $relayhost = false,
  $relay_recipient_maps = false,
  $transport_maps = false,
  $in_flow_delay = '1s',
  $alias_maps = 'hash:/etc/aliases',
  $alias_database = 'hash:/etc/aliases',
  $recipient_delimiter = false,
  $home_mailbox = false,
  $mail_spool_directory = false,
  $mailbox_command = false,
  $smtpd_banner = '$myhostname ESMTP $mail_name',
  $setgid_group = $::postfix::params::setgid_group,
  $mailbox_size_limit = undef,
  $message_size_limit = false,
  $mail_name = false,
  $virtual_alias_domains = false,
  $virtual_alias_maps = false,
  $virtual_mailbox_domains = false,
  $virtual_mailbox_maps = false,
  $virtual_mailbox_base = false,
  $virtual_uid_maps = false,
  $virtual_gid_maps = false,
  $virtual_transport = false,
  $dovecot_destination = '${recipient}',
  $masquerade_classes = false,
  $masquerade_domains = false,
  $smtpd_helo_required = false,
  $smtpd_client_restrictions = [],
  $smtpd_helo_restrictions = [],
  $smtpd_sender_restrictions = [],
  $smtpd_recipient_restrictions = [],
  $smtpd_data_restrictions = [],
  $smtpd_end_of_data_restrictions = [],
  $smtpd_delay_reject = false,
  $ssl = false,
  $smtpd_tls_key_file = undef,
  $smtpd_tls_cert_file = undef,
  $smtpd_tls_CAfile = undef,
  $smtpd_sasl_auth = false,
  $smtpd_sasl_type = 'dovecot',
  $smtpd_sasl_path = 'private/auth',
  $smtp_sasl_auth = false,
  $smtp_sasl_password_maps = undef,
  $smtp_sasl_security_options = undef,
  $smtp_tls_CAfile = undef,
  $smtp_tls_CApath = undef,
  $smtp_tls_key_file = undef,
  $smtp_tls_cert_file = undef,
  $smtp_tls_security_level = undef,
  $smtp_tls_secure_cert_match = undef,
  $smtp_tls_note_starttls_offer = false,
  $smtp_tls_mandatory_ciphers = undef,
  $smtpd_tls_ask_ccert = false,
  $tls_append_default_CA = false,
  $smtp_sasl_tls = false,
  $smtp_use_tls = false,
  $canonical_maps = false,
  $sender_canonical_maps = false,
  $smtp_generic_maps = false,
  $relocated_maps = false,
  $extra_main_parameters = {},
  # master.cf
  $smtp_content_filter = [],
  $smtps_content_filter = [],
  $submission = false,
  # EL5
  $submission_smtpd_enforce_tls = 'yes',
  # EL6
  $submission_smtpd_tls_security_level = 'encrypt',
  $submission_smtpd_sasl_auth_enable = 'yes',
  $smtps_smtpd_sasl_auth_enable = 'yes',
  # submission should only be used for authenticated delivery, so explicitly
  # reject everything else.
  $submission_smtpd_client_restrictions = 'permit_sasl_authenticated,reject',
  # smtps should allow unauthenticated delivery (for local or relay_domains for
  # example) so no explicit reject. smtps port 465 is non-standards compliant 
  # anyway so no one true answer. 
  $smtps_smtpd_client_restrictions = 'permit_sasl_authenticated',
  $master_services = [],
  # Other files
  $header_checks = [],
  $body_checks = [],
  # Postscreen - available in Postfix 2.8 and later
  $postscreen                  = false,
  $postscreen_access_list      = ['permit_mynetworks'],
  $postscreen_blacklist_action = 'enforce',
  $postscreen_cache_map        = 'btree:$data_directory/postscreen_cache',
  $postscreen_greet_wait       = '${stress?2}${stress:6}s',
  $postscreen_greet_banner     = '$smtpd_banner',
  $postscreen_greet_action     = 'enforce',
  $postscreen_dnsbl_sites      = [],
  $postscreen_dnsbl_reply_map  = undef,
  $postscreen_dnsbl_threshold  = 1,
  $postscreen_dnsbl_action     = 'enforce',
  # Other filters
  $postgrey                = false,
  $postgrey_policy_service = undef,
  $clamav                  = false,
  # Parameters
  $command_directory      = $::postfix::params::command_directory,
  $config_directory       = $::postfix::params::config_directory,
  $daemon_directory       = $::postfix::params::daemon_directory,
  $data_directory         = $::postfix::params::data_directory,
  $manpage_directory      = $::postfix::params::manpage_directory,
  $readme_directory       = $::postfix::params::readme_directory,
  $sample_directory       = $::postfix::params::sample_directory,
  $postfix_package        = $::postfix::params::postfix_package,
  $postfix_package_ensure = $::postfix::params::postfix_package_ensure,
  $postgrey_package       = $::postfix::params::postgrey_package,
  $service_restart        = $::postfix::params::service_restart,
  $root_group             = $::postfix::params::root_group,
  $mailq_path             = $::postfix::params::mailq_path,
  $newaliases_path        = $::postfix::params::newaliases_path,
  $sendmail_path          = $::postfix::params::sendmail_path,
  $queue_directory        = $::postfix::params::queue_directory,
  $mastercf               = undef,
) {

    $instance = $title ? {
        'default' => 'postfix',
        default => "postfix-${title}"
    }
    $postfixdir = "${config_directory}/${instance}"

    # Create instance

    postfix::instances::create { $instance: }

    # Default has el5 files, for el6 a few defaults have changed

    if ( $::operatingsystem =~ /RedHat|CentOS/ and versioncmp($::operatingsystemrelease, '6') < 0 ) {
        $filesuffix = '-el5'
    } else {
        $filesuffix = ''
    }

    # Instance directories

    $queue_directory_instance = "${queue_directory}/${instance}"
    $data_directory_instance = "${data_directory}/${instance}"

    # Dynamic maps - symlink to default postfix instance

    if ($title != 'default') {
        file { "${postfixdir}/dynamicmaps.cf":
            ensure => link,
            target => "${config_directory}/postfix/dynamicmaps.cf",
            require => Postfix::Instances::Create[$instance],
        }
    }

    # Master config

    if ($mastercf == undef) {
        file { "${postfixdir}/master.cf":
            content => template("postfix/master.cf${filesuffix}.erb"),
            notify  => Service['postfix'],
            require => Postfix::Instances::Create[$instance],
        }
    } else {
        file { "${postfixdir}/master.cf":
            content => template('postfix/master.cf-new.erb'),
            notify  => Service['postfix'],
            require => Postfix::Instances::Create[$instance],
        }
    }

    # Main config

    file { "${postfixdir}/main.cf":
        content => template("postfix/main.cf${filesuffix}.erb"),
        notify  => Service['postfix'],
        require => Postfix::Instances::Create[$instance],
    }

#  # Optional Postgrey setup
#  if $postgrey {
#    # Main package and service it provides
#    package { $postgrey_package: ensure => installed }
#    service { 'postgrey':
#      require   => Package[$postgrey_package],
#      enable    => true,
#      ensure    => running,
#      # When stopped, status returns zero with 1.31-1.el5
#      hasstatus => false,
#    }
#  }
#
#  # Optional ClamAV setup (using clamsmtp)
#  # Defaults to listen on 10025 and re-send on 10026
#  if $clamav {
#    include '::clamav::smtp'
#  }
#

    # Regex header_checks
    postfix::file { "${instance}-header_checks":
        filename   => 'header_checks',
        content    => template('postfix/header_checks.erb'),
        group      => $root_group,
        postfixdir => "${postfixdir}",
    }

    # Regex body_checks
    postfix::file { "${instance}-body_checks":
        filename   => 'body_checks',
        content    => template('postfix/body_checks.erb'),
        group      => $root_group,
        postfixdir => "${postfixdir}",
    }

}
