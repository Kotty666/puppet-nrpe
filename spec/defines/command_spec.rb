require 'spec_helper'

describe 'nrpe::command' do
  let(:title) { 'check_auto_cpu' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          cmd: 'check_cpu.sh -w 75 -c 90 -iw 101 -ic 102',
          cmdname: 'check_auto_cpu',
          run_as: 'root',
        }
      end
      let(:pre_condition) { ['class {"::nrpe": include_dir => "/etc/nagios/nrpe.d" }', 'class {"::sudo": config_dir => "/tmp", purge => false }'] }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_file('/etc/nagios/nrpe.d/check_auto_cpu.cfg') }
      it { is_expected.to contain_file('/tmp/50_puppet_nrpe_check_auto_cpu') }
    end
  end
end
