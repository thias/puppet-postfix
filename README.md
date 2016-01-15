# puppet-postfix

## Initial though

Feel free to send me a pull request or just open an issue if you need to update anything.

## Goal

Manage multiple postfix instances.

This plusing is extended version of https://github.com/thias/puppet-postfix. It is backwards compatible!

## Original plugin usage example

* `postfix::dbfile` : Manage Postfix DB configuration files
* `postfix::file` : Manage flat text Postfix configuration files
* `postfix::server` : Manage the main Postfix instance

```puppet
class { '::postfix::server':
  myhostname              => 'mx1.example.com',
  mydomain                => 'example.com',
  mydestination           => "\$myhostname, localhost.\$mydomain, localhost, $fqdn",
  inet_interfaces         => 'all',
  message_size_limit      => '15360000', # 15MB
  mail_name               => 'example mail daemon',
  virtual_mailbox_domains => [
    'proxy:mysql:/etc/postfix/mysql_virtual_domains_maps.cf',
  ],
  virtual_alias_maps      => [
    'proxy:mysql:/etc/postfix/mysql_virtual_alias_maps.cf',
    'proxy:mysql:/etc/postfix/mysql_virtual_alias_domain_maps.cf',
    'proxy:mysql:/etc/postfix/mysql_virtual_alias_domain_catchall_maps.cf',
  ],
  virtual_transport         => 'dovecot',
  # if you want dovecot to deliver user+foo@example.org to user@example.org,
  # uncomment this: (c.f. http://wiki2.dovecot.org/LDA/Postfix#Virtual_users)
  # dovecot_destination     => '${user}@${nexthop}',
  smtpd_sender_restrictions => [
    'permit_mynetworks',
    'reject_unknown_sender_domain',
  ],
  smtpd_recipient_restrictions => [
    'permit_sasl_authenticated',
    'permit_mynetworks',
    'reject_unauth_destination',
  ],
  smtpd_sasl_auth       => true,
  sender_canonical_maps => 'regexp:/etc/postfix/sender_canonical',
  ssl                   => 'wildcard.example.com',
  submission            => true,
  header_checks         => [
    '# Remove LAN (Webmail) headers',
    '/^Received: from .*\.example\.ici/ IGNORE',
    '# Sh*tlist',
    '/^From: .*@(example\.com|example\.net)/ REJECT Spam, go away',
    '/^From: .*@(lcfnl\.com|.*\.cson4\.com|.*\.idep4\.com|.*\.gagc4\.com)/ REJECT user unknown',
  ],
  postgrey              => true,
  spamassassin          => true,
  sa_skip_rbl_checks    => '0',
  spampd_children       => '4',
  # Send all emails to spampd on 10026
  smtp_content_filter   => 'smtp:127.0.0.1:10026',
  # This is where we get emails back from spampd
  master_services       => [ '127.0.0.1:10027 inet n  -       n       -      20       smtpd'],
}
```

The most common parameters are supported as parameters to the `postfix::server`
class, but any other ones may be added using the `$extra_main_parameters` hash
parameter, to which keys are `main.cf` parameter names and values can be either
a value string or array of strings.

Example :
```puppet
class { '::postfix::server':
  extra_main_parameters => {
    'virtual_mailbox_lock' => [
      'fcntl',
      'dotlock',
    ],
    virtual_minimum_uid => '1000',
  },
}
```

## Mutli-instance example

```
include ::postfix::params

class { '::postfix::install':
    mysql => true,
}

# Default instance as a null-client

postfix::instance { 'default':
    myhostname             => $fqdn,
    mydomain               => $fqdn,
    myorigin               => $fqdn,
    mydestination          => "$fqdn, localhost",
    message_size_limit     => '15360000',
    master_service_disable => 'inet',
    # default_database_type = cdb
    # indexed = ${default_database_type}:${config_directory}/
}

# Relay server using dovecot as a backend

postfix::instance { 'out':
    myhostname                   => $fqdn,
    mydestination                => 'localhost',
    message_size_limit           => '15360000',
    smtpd_banner                 => '$myhostname ESMTP $mail_name (Debian/GNU)',
    inet_interfaces              => 'all',
    relayhost                    => '',
    mynetworks                   => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128',
    myorigin                     => $fqdn,
    smtpd_sasl_type              => 'dovecot',
    smtpd_sasl_path              => 'inet:127.0.0.1:10002',
    smtpd_client_restrictions    => [ 'permit_sasl_authenticated', 'reject' ],
    smtpd_recipient_restrictions => [ 'permit_sasl_authenticated', 'permit_mynetworks', 'reject_unauth_destination' ],
    readme_directory             => 'no',
    mailbox_size_limit           => '0',
    recipient_delimiter          => '+',
    extra_main_parameters        => {
        biff                            => 'no',
        broken_sasl_auth_clients        => 'yes',
        smtpd_sasl_auth_enable          => 'yes',
        smtpd_sasl_authenticated_header => 'yes',
        smtpd_sasl_security_options     => 'noanonymous',
        smtpd_sasl_local_domain         => '$myhostname',
        append_dot_mydomain             => 'no',
        master_service_disable          => '',
        authorized_submit_users         => '',
    }
}
```

## Limitations

* The service will only be reloaded on configuration change, meaning that
  changes requiring a full restart won't be applied, such as changes to
  listening interfaces.

