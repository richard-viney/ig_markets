describe IGMarkets::DealingPlatform do
  let(:session) { IGMarkets::Session.new }
  let(:platform) do
    IGMarkets::DealingPlatform.new.tap do |platform|
      platform.instance_variable_set :@session, session
    end
  end

  it 'has a valid session' do
    expect(IGMarkets::DealingPlatform.new.session).to be_an_instance_of(IGMarkets::Session)
  end

  it 'can sign in' do
    client_account_summary = IGMarkets::ClientAccountSummary.new client_id: 'id'

    expect(session).to receive(:sign_in).and_return(client_id: 'id')
    expect(platform.sign_in('username', 'password', 'api_key', :production)).to eq(client_account_summary)
    expect(session.username).to eq('username')
    expect(session.password).to eq('password')
    expect(session.api_key).to eq('api_key')
    expect(session.platform).to eq(:production)
  end

  it 'can sign out' do
    expect(session).to receive(:sign_out).and_return(nil)
    expect(platform.sign_out).to be_nil
  end

  it 'can retrieve a deal confirmation' do
    deal_confirmation = build :deal_confirmation

    expect(session).to receive(:get).with('confirms/DEAL').and_return(deal_confirmation)
    expect(platform.deal_confirmation(deal_confirmation.deal_id)).to eq(deal_confirmation)
  end

  it 'can retrieve the current applications' do
    applications = [build(:application)]

    expect(session).to receive(:get).with('operations/application').and_return(applications)
    expect(platform.applications).to eq(applications)
  end

  it 'can instantiate models from existing instances' do
    account = IGMarkets::Account.new account_name: 'test'

    expect(platform.instantiate_models(IGMarkets::Account, nil)).to be_nil
    expect(platform.instantiate_models(IGMarkets::Account, account)).to eq(account)
    expect(platform.instantiate_models(IGMarkets::Account, [account])).to eq([account])
  end

  it 'can instantiate models from an attributes hash' do
    class TestModel3 < IGMarkets::Model
      attribute :test

      deprecated_attribute :deprecated

      def self.adjusted_api_attributes(attributes)
        attributes.fetch :parent
      end
    end

    result = platform.instantiate_models(TestModel3, parent: { test: 'value', deprecated: '' })

    expect(result).to eq(TestModel3.new(test: 'value'))
  end

  it 'raises an error when trying to instantiate from an unsupported type' do
    expect { platform.instantiate_models IGMarkets::Model, 100 }.to raise_error(ArgumentError)
  end
end
