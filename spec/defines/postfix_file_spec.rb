

require 'spec_helper'

describe 'postfix::file', :type => :define do
  let(:title) { 'myfile' }

  context 'default' do
    it { should contain_file('/etc/postfix/myfile').with(
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0644'
    ) }
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
  end

end
