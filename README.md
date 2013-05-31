# puppet-postfix

## Overview

This module is meant for Red Hat Enterprise Linux and clones. It still requires
some major clean up, but is currently fully functional.

* `postfix::dbfile` : Manage Postfix DB configuration files
* `postfix::file` : Manage flat text Postfix configuration files
* `postfix::server` : Manage the main Postfix instance

## Examples

    class { 'postfix::server':
      myhostname              => 'mx1.example.com',
      mydomain                => 'example.comt',
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
      clamav                => true,
      spamassassin          => true,
      sa_skip_rbl_checks    => '0',
      spampd_children       => '4',
      # Send all emails to ClamSMTP, which sends to spampd on 10026
      smtp_content_filter   => 'smtp:127.0.0.1:10025',
      # This is where we get emails back from spampd
      master_services       => [ '127.0.0.1:10027 inet n  -       n       -      20       smtpd'],
    }

