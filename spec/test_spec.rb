require 'serverspec'
require 'spec_helper'


context ENV['KITCHEN_INSTANCE'] || host_inventory['hostname'] do
  describe 'TEST ROLE' do
    describe file('/tmp/distrib') do
      it { should exist }
      it { should be_owned_by 'vagrant' }
      it { should be_grouped_into 'vagrant' }
      it { should be_mode 644 }
    end

      describe file('/tmp/conditional') do
        it { should exist }
        it { should be_owned_by 'vagrant' }
        it { should be_grouped_into 'vagrant' }
        it { should be_mode 644 }
        its(:content) { should match(property['playbook_var']) }
    end
  end
end
