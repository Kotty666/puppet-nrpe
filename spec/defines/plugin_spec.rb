require 'spec_helper'

describe 'nrpe::plugin' do
  let(:title) { 'check_cpu.sh' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          plugindir: '/tmp',
        }
      end
      let(:pre_condition) { 'class {"::nrpe": plugindir => "/tmp" }' }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/tmp/check_cpu.sh') }
    end
  end
end
