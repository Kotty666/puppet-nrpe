require 'spec_helper'

describe 'nrpe::command_disks' do
  let(:title) { 'namevar' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { ' include ::nrpe ' }

      it { is_expected.to compile.with_all_deps }
    end
  end
end
