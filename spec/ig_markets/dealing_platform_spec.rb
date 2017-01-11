describe IGMarkets::DealingPlatform, :dealing_platform do
  it 'signs in' do
    client_account_summary = build :client_account_summary, client_id: 'id'

    expect(session).to receive(:sign_in).and_return(client_account_summary.attributes)
    expect(dealing_platform.sign_in('username', 'password', 'api_key', :live)).to eq(client_account_summary)
    expect(dealing_platform.client_account_summary).to eq(client_account_summary)
    expect(session.username).to eq('username')
    expect(session.password).to eq('password')
    expect(session.api_key).to eq('api_key')
    expect(session.platform).to eq(:live)
  end

  it 'signs out' do
    expect(dealing_platform.streaming).to receive(:disconnect)
    expect(session).to receive(:sign_out).and_return(nil)
    expect(dealing_platform.sign_out).to be nil
  end

  it 'retrieves a deal confirmation' do
    deal_confirmation = build :deal_confirmation

    expect(session).to receive(:get).with('confirms/DEAL').and_return(deal_confirmation)
    expect(dealing_platform.deal_confirmation(deal_confirmation.deal_id)).to eq(deal_confirmation)
  end

  it 'retrieves the current applications' do
    applications = [build(:application)]

    expect(session).to receive(:get).with('operations/application').and_return(applications)
    expect(dealing_platform.applications).to eq(applications)
  end

  it 'disables the API key' do
    application = build :application

    expect(session).to receive(:put).with('operations/application/disable').and_return(application)
    expect(dealing_platform.disable_api_key).to eq(application)
  end

  it 'instantiates models from existing instances' do
    account = IGMarkets::Account.new account_name: 'test'

    expect(dealing_platform.instantiate_models(IGMarkets::Account, nil)).to be nil
    expect(dealing_platform.instantiate_models(IGMarkets::Account, account)).to eq(account)
    expect(dealing_platform.instantiate_models(IGMarkets::Account, [account])).to eq([account])
  end

  class DealingPlatformSpecModel < IGMarkets::Model
    attribute :test
    attribute :test2, Symbol, allowed_values: [:one, :two, :three]

    deprecated_attribute :deprecated

    def self.adjusted_api_attributes(attributes)
      attributes.keys == [:parent] ? attributes[:parent] : attributes
    end
  end

  it 'instantiates models from an attributes hash' do
    result = dealing_platform.instantiate_models(DealingPlatformSpecModel, parent: [{ test: 'value', deprecated: '' }])
    expect(result).to eq([DealingPlatformSpecModel.new(test: 'value')])
  end

  it 'reports unrecognized values when instantiating models exactly once and sets their value to nil' do
    expect do
      result = dealing_platform.instantiate_models(DealingPlatformSpecModel, test: 'value', test2: 'FOUR')
      expect(result).to eq(DealingPlatformSpecModel.new(test: 'value', test2: nil))
    end.to output("ig_markets: received unrecognized value for DealingPlatformSpecModel#test2: four\n").to_stderr

    expect do
      dealing_platform.instantiate_models(DealingPlatformSpecModel, test: 'value', test2: 'FOUR')
    end.to output('').to_stderr
  end

  it 'raises an error when trying to instantiate a model from an unsupported type' do
    expect { dealing_platform.instantiate_models IGMarkets::Model, 100 }
      .to raise_error(ArgumentError, "IGMarkets::Model: can't instantiate from a source of type Fixnum")
  end

  it 'instantiates models from raw JSON' do
    model = dealing_platform.instantiate_models_from_json DealingPlatformSpecModel, { test2: 'ONE' }.to_json
    expect(model.attributes).to eq(test: nil, test2: :one)
  end
end
