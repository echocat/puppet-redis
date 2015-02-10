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

end
