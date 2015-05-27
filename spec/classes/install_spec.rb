require 'spec_helper'

describe 'redis::install' do

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported' }}
    it { expect { should contain_class('redis::install')}.to raise_error(Puppet::Error, /The module does not support this OS/ )}
  end

  context 'with defaults for all parameters on RedHat' do
    let(:facts) {{ :operatingsystem => 'RedHat' }}
    it do
      should have_redis__installbinary_resource_count(6) 
      should contain_file('/opt').with({
        'ensure'  => 'directory',
      })
    end
  end

  context 'with defaults for all parameters on Debian' do
    let(:facts) {{ :operatingsystem => 'Debian' }}
    it do
      should have_redis__installbinary_resource_count(6)
      should contain_file('/opt').with({
        'ensure'  => 'directory',
      })
    end
  end

  describe 'when manage_repo is enabled on Ubuntu trusty without redis_package' do
    let(:facts) {{
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu',
      :lsbdistid       => 'Ubuntu',
      :lsbdistcodename => 'trusty',
    }}
    let(:params) { { :manage_repo => true, } }
    it do
      expect {
        should_not contain_class('redis::repo::ubuntu')
      }.to raise_error(Puppet::Error, /manage_repo requires redis_package/ )
    end
  end

  describe 'when manage_repo and redis_package is enabled on Ubuntu trusty' do
    let(:facts) {{
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu',
      :lsbdistid       => 'Ubuntu',
      :lsbdistcodename => 'trusty',
    }}
    let(:params) { { :manage_repo => true, :redis_package => true } }
    it {
      should contain_class('redis::repo::ubuntu')
    }
  end
end
