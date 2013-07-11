require 'spec_helper'

describe 'postfix::dbfile', :type => :define do
  let(:title) { 'myfile' }

  context 'default' do
    it { should contain_file('/etc/postfix/myfile').with(
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0644'
    ) }

    it { should_not contain_file('/etc/postfix/myfile.db').with_ensure('absent') }
    it { should contain_exec('/usr/sbin/postmap myfile') }
  end

  context 'specify source' do
    let(:params) { { :source => 'puppet:///blah' } }

    it { should contain_file('/etc/postfix/myfile').with_source('puppet:///blah') }
  end

  context 'specify content' do
    let(:params) { { :content => 'stuff' } }

    it { should contain_file('/etc/postfix/myfile').with_content('stuff') }
  end

  context 'absent' do
    let(:params) { { :ensure => 'absent' } }

    it { should contain_file('/etc/postfix/myfile').with_ensure('absent') }
    it { should contain_file('/etc/postfix/myfile.db').with_ensure('absent') }
  end

end
