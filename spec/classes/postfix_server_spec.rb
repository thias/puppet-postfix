require 'spec_helper'

describe 'postfix::server', :type => :class do

  context 'default' do
    it { should contain_package('postfix') }
    it { should contain_service('postfix') }
    it { should contain_file('/etc/postfix/master.cf') }
    it { should contain_file('/etc/postfix/main.cf') }
    it { should_not contain_package('spamassassin') }
    it { should_not contain_package('spampd') }
    it { should_not contain_service('spampd') }
    it { should_not contain_file('/etc/sysconfig/spampd') }
    it { should_not contain_file('/etc/mail/spamassassin/local.cf') }
    it { should_not contain_package('postgrey') }
    it { should_not contain_service('postgrey') }
    it { should_not include_class('clamav::smtp') }
    it { should contain_postfix__file('header_checks') }
    it { should contain_postfix__file('body_checks') }
  end

  context 'rhel6 based' do
    let(:facts) { { :operatingsystem => 'RedHat', :operatingsystemrelease => 6 } }
    let(:params) { { :submission => true } }

    it { should contain_file('/etc/postfix/master.cf').with_content(/smtpd_tls_security_level/) }
    it { should contain_file('/etc/postfix/main.cf').with_content(/ddd/) }
  end

  context 'non-rhel6 based' do
    let(:facts) { { :operatingsystem => 'RedHat', :operatingsystemrelease => 5 } }
    let(:params) { { :submission => true } }

    it { should contain_file('/etc/postfix/master.cf').with_content(/smtpd_enforce_tls/) }
    it { should contain_file('/etc/postfix/main.cf').with_content(/xxgdb/) }
  end

  context 'debian' do
    let(:facts) { { :osfamily => 'Debian' } }

    it { should contain_service('postfix').with_restart('/usr/sbin/service postfix reload') }
  end

  context 'with mysql' do
    let(:params) { { :mysql => true } }

    it { should contain_package('postfix-mysql').with_alias('postfix') }
  end

  context 'with spamassassin' do
    let(:params) { { :spamassassin => true } }

    it { should contain_package('spamassassin') }
    it { should contain_package('spampd') }
    it { should contain_service('spampd') }
    it { should contain_file('/etc/sysconfig/spampd') }
    it { should contain_file('/etc/mail/spamassassin/local.cf') }
  end

  context 'postgrey' do
    let(:params) { { :postgrey => true } }

    it { should contain_package('postgrey') }
    it { should contain_service('postgrey') }
  end

  context 'clamav' do
    let(:params) { { :clamav => true } }
    # Fails spec tests - unknown module
#    it { should include_class('clamav::smtp') }
  end

end
