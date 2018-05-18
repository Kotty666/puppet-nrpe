require 'spec_helper'

describe 'nrpe' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          plugindir: '/usr/lib/nagios/plugins',
          include_dir: '/etc/nagios/nrpe.d/',
          nrpe_cfg: '/etc/nagios/nrpe.cfg',
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_service('nrpe_service') }
      it { is_expected.to contain_file('/etc/nagios/nrpe.cfg') }
    end
  end
end
