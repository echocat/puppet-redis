require 'spec_helper'

describe 'redis::install' do

  context 'Unsupported OS' do
    let(:facts) {{ :osfamily => 'unsupported' }}
    it { expect { should contain_class('redis::install')}.to raise_error(Puppet::Error, /The module does not support this OS/ )}
  end

  context 'with defaults for all parameters on RedHat' do
    let(:facts) {{ :osfamily => 'RedHat' }}
    it { should contain_class('redis::installbinary') }
  end

  context 'with defaults for all parameters on Debian' do
    let(:facts) {{ :osfamily => 'Debian', :lsbdistid => 'ubuntu' }}
    it { should contain_class('redis::installbinary') }
  end

end
