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
    expect(session).to receive(:sign_in).and_return({})
    expect(platform.sign_in('username', 'password', 'api_key', :production)).to eq({})
    expect(session.username).to eq('username')
    expect(session.password).to eq('password')
    expect(session.api_key).to eq('api_key')
    expect(session.platform).to eq(:production)
  end

  it 'can sign out' do
    expect(session).to receive(:sign_out).and_return(nil)
    expect(platform.sign_out).to eq(nil)
  end

  it 'can retrieve a deal confirmation' do
    deal_confirmation = build :deal_confirmation

    expect(session).to receive(:get).with('confirms/deal_id', IGMarkets::API_V1).and_return(deal_confirmation)
    expect(platform.deal_confirmation(deal_confirmation.deal_id)).to eq(deal_confirmation)
  end

  it 'can retrieve the current applications' do
    applications = [build(:application)]

    expect(session).to receive(:get).with('operations/application', IGMarkets::API_V1).and_return(applications)
    expect(platform.applications).to eq(applications)
  end
end
