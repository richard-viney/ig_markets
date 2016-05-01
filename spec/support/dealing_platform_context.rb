RSpec.shared_context 'dealing_platform' do
  let(:session) { IGMarkets::Session.new }

  let(:dealing_platform) do
    IGMarkets::DealingPlatform.new.tap do |dealing_platform|
      dealing_platform.instance_variable_set :@session, session
    end
  end

  def with_dealing_platform(model)
    model.instance_variable_set :@dealing_platform, dealing_platform

    model
  end
end
