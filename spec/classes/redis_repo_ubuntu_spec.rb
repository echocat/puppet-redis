require 'spec_helper'

describe 'redis::repo::ubuntu', :type => 'class' do
  describe 'when called with no parameters on Ubuntu trusty' do
    let(:facts) {{
      :osfamily        => 'Debian',
      :lsbdistid       => 'Ubuntu',
      :lsbdistcodename => 'trusty',
    }}

    it {
      should contain_exec('add-apt-repository-ppa:chris-lea/redis-server')
    }
  end
end
