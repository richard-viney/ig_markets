describe IGMarkets::DealingPlatform, :dealing_platform do
  it 'has a valid session' do
    expect(IGMarkets::DealingPlatform.new.session).to be_an_instance_of(IGMarkets::Session)
  end

  it 'can sign in' do
    client_account_summary = IGMarkets::ClientAccountSummary.new client_id: 'id'

    expect(session).to receive(:sign_in).and_return(client_id: 'id')
    expect(dealing_platform.sign_in('username', 'password', 'api_key', :live)).to eq(client_account_summary)
    expect(dealing_platform.client_account_summary).to eq(client_account_summary)
    expect(session.username).to eq('username')
    expect(session.password).to eq('password')
    expect(session.api_key).to eq('api_key')
    expect(session.platform).to eq(:live)
  end

  it 'can sign out' do
    expect(session).to receive(:sign_out).and_return(nil)
    expect(dealing_platform.sign_out).to be_nil
  end

  it 'can retrieve a deal confirmation' do
    deal_confirmation = build :deal_confirmation

    expect(session).to receive(:get).with('confirms/DEAL').and_return(deal_confirmation)
    expect(dealing_platform.deal_confirmation(deal_confirmation.deal_id)).to eq(deal_confirmation)
  end

  it 'can retrieve the current applications' do
    applications = [build(:application)]

    expect(session).to receive(:get).with('operations/application').and_return(applications)
    expect(dealing_platform.applications).to eq(applications)
  end

  it 'can disable the API key' do
    application = build :application

    expect(session).to receive(:put).with('operations/application/disable').and_return(application)
    expect(dealing_platform.disable_api_key).to eq(application)
  end

  it 'can instantiate models from existing instances' do
    account = IGMarkets::Account.new account_name: 'test'

    expect(dealing_platform.instantiate_models(IGMarkets::Account, nil)).to be_nil
    expect(dealing_platform.instantiate_models(IGMarkets::Account, account)).to eq(account)
    expect(dealing_platform.instantiate_models(IGMarkets::Account, [account])).to eq([account])
  end

  it 'can instantiate models from an attributes hash' do
    class TestModel3 < IGMarkets::Model
      attribute :test

      deprecated_attribute :deprecated

      def self.adjusted_api_attributes(attributes)
        attributes.keys == [:parent] ? attributes[:parent] : attributes
      end
    end

    result = dealing_platform.instantiate_models(TestModel3, parent: [{ test: 'value', deprecated: '' }])

    expect(result).to eq([TestModel3.new(test: 'value')])
  end

  it 'raises an error when trying to instantiate from an unsupported type' do
    expect { dealing_platform.instantiate_models IGMarkets::Model, 100 }.to raise_error(ArgumentError)
  end
end
