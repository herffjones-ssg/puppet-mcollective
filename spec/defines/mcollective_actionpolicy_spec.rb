require 'spec_helper'

describe 'mcollective::actionpolicy' do
  let (:title) { 'cert=user@foo' }
  let (:facts) { {
    :osfamily        => 'Debian',
    :operatingsystem => 'Debian'
  } }

  context 'when rpccaller contains spaces' do
    let (:params) { {
      :rpccaller => 'foo bar'
    } }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
      }.to raise_error(Puppet::Error, /\$rpccaller must be.* got 'foo bar'/)
    end
  end

  context 'when agent is empty' do
    let (:title) { 'cert=user' }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user')
      }.to raise_error(Puppet::Error, /Wrong value for \$agent ''/)
    end
  end

  context 'when agent contains spaces' do
    let (:params) { {
      :agent => 'foo bar'
    } }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
      }.to raise_error(Puppet::Error, /Wrong value for \$agent 'foo bar'/)
    end
  end

  context 'when agent is not declared' do
    let (:title) { 'cert=user@bar' }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@bar')
      }.to raise_error(Puppet::Error, /You must declare an mcollective::actionpolicy::base for agent 'bar'/)
    end
  end

  context 'when auth has a wrong value' do
    let (:params) { {
      :auth => 'update'
    } }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
      }.to raise_error(Puppet::Error, /\$auth must be either 'allow' or 'deny', got 'update'/)
    end
  end

  context 'when actions is not an array' do
    let (:params) { {
      :actions => 'myaction'
    } }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
      }.to raise_error(Puppet::Error, /"myaction" is not an Array/)
    end
  end

  context 'when facts is not an array' do
    let (:params) { {
      :facts => 'myfact'
    } }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
      }.to raise_error(Puppet::Error, /"myfact" is not an Array/)
    end
  end

  context 'when classes is not an array' do
    let (:params) { {
      :classes => 'myclass'
    } }

    it 'should fail' do
      expect { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo')
      }.to raise_error(Puppet::Error, /"myclass" is not an Array/)
    end
  end

  context 'when using defaults' do
    it { should contain_concat__fragment('mcollective.actionpolicy.cert=user@foo').with(
      :ensure  => :present,
      :order   => '50',
      :target  => '/etc/mcollective/policies/foo.policy',
      :content => "allow\tcert=user\t*\t*\t*\n",
    ) }
  end

  context 'when overriding parameters' do
    let (:title) { 'My beautiful action policy' }
    let (:params) { {
      :agent     => 'foo',
      :rpccaller => 'uid=1001',
      :auth      => 'deny',
      :actions   => ['status', 'restart'],
      :facts     => ['operatingsystem="Debian"'],
      :classes   => ['mysite::myclass', 'mysite::myotherclass'],
      :order     => '99',
    } }
    it { should contain_concat__fragment('mcollective.actionpolicy.My beautiful action policy').with(
      :ensure  => :present,
      :order   => '99',
      :target  => '/etc/mcollective/policies/foo.policy',
      :content => "deny\tuid=1001\tstatus restart\toperatingsystem=\"Debian\"\tmysite::myclass mysite::myotherclass\n",
    ) }
  end
end