describe IGMarkets::Account, :dealing_platform do
  it 'reloads its attributes' do
    account = dealing_platform_model build(:account)

    expect(dealing_platform.account).to receive(:all).twice.and_return([account])

    account_copy = dealing_platform.account.all.first.dup
    account_copy.account_type = nil
    account_copy.reload

    expect(account_copy.account_type).to eq(:cfd)
  end
end
