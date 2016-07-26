describe IGMarkets::IGMarketsError do
  it 'builds the correct error type based on the error code' do
    {
      'authentication.failure.not-a-client-account' => IGMarkets::InvalidClientAccountError,
      'endpoint.unavailable.for.api-key' => IGMarkets::APIKeyRejectedError,
      'error.confirms.deal-not-found' => IGMarkets::DealNotFoundError,
      'error.invalid.daterange' => IGMarkets::InvalidDateRangeError,
      'error.invalid.watchlist' => IGMarkets::InvalidWatchlistError,
      'error.malformed.date' => IGMarkets::MalformedDateError,
      'error.position.notfound' => IGMarkets::PositionNotFoundError,
      'error.positions.generic' => IGMarkets::PositionError,
      'error.public-api.epic-not-found' => IGMarkets::EPICNotFoundError,
      'error.public-api.exceeded-account-allowance' => IGMarkets::ExceededAccountAllowanceError,
      'error.public-api.exceeded-account-historical-data-allowance' =>
        IGMarkets::ExceededAccountHistoricalDataAllowanceError,
      'error.public-api.exceeded-account-trading-allowance' => IGMarkets::ExceededAccountTradingAllowanceError,
      'error.public-api.exceeded-api-key-allowance' => IGMarkets::ExceededAPIKeyAllowanceError,
      'error.public-api.failure.encryption.required' => IGMarkets::EncryptionRequiredError,
      'error.public-api.failure.kyc.required' => IGMarkets::KYCRequiredForAccountError,
      'error.public-api.failure.missing.credentials' => IGMarkets::MissingCredentialsError,
      'error.public-api.failure.pending.agreements.required' => IGMarkets::PendingAgreementsError,
      'error.public-api.failure.preferred.account.disabled' => IGMarkets::PreferredAccountDisabledError,
      'error.public-api.failure.preferred.account.not.set' => IGMarkets::PreferredAccountNotSetError,
      'error.public-api.failure.stockbroking-not-supported' => IGMarkets::StockbrokingNotSupportedError,
      'error.public-api.too-many-epics' => IGMarkets::TooManyEPICSError,
      'error.security.account-access-denied' => IGMarkets::AccountAccessDeniedError,
      'error.security.account-migrated' => IGMarkets::AccountMigratedError,
      'error.security.account-not-yet-activated' => IGMarkets::AccountNotYetActivatedError,
      'error.security.account-suspended' => IGMarkets::AccountSuspendedError,
      'error.security.account-token-invalid' => IGMarkets::AccountTokenInvalidError,
      'error.security.account-token-missing' => IGMarkets::AccountTokenMissingError,
      'error.security.all-accounts-pending' => IGMarkets::AllAccountsPendingError,
      'error.security.all-accounts-suspended' => IGMarkets::AllAccountsSuspendedError,
      'error.security.api-key-disabled' => IGMarkets::APIKeyDisabledError,
      'error.security.api-key-invalid' => IGMarkets::APIKeyInvalidError,
      'error.security.api-key-missing' => IGMarkets::APIKeyMissingError,
      'error.security.api-key-restricted' => IGMarkets::APIKeyRestrictedError,
      'error.security.api-key-revoked' => IGMarkets::APIKeyRevokedError,
      'error.security.client-suspended' => IGMarkets::ClientSuspendedError,
      'error.security.client-token-invalid' => IGMarkets::ClientTokenInvalidError,
      'error.security.client-token-missing' => IGMarkets::ClientTokenMissingError,
      'error.security.generic' => IGMarkets::SecurityError,
      'error.security.invalid-application' => IGMarkets::InvalidApplicationError,
      'error.security.invalid-details' => IGMarkets::InvalidCredentialsError,
      'error.security.invalid-website' => IGMarkets::InvalidWebsiteError,
      'error.security.too-many-failed-attempts' => IGMarkets::TooManyFailedLoginAttemptsError,
      'error.service.watchlists.add-instrument.invalid-epic' => IGMarkets::WatchlistInvalidEPICError,
      'error.switch.accountId-must-be-different' => IGMarkets::AccountAlreadyCurrentError,
      'error.switch.cannot-set-default-account' => IGMarkets::CannotSetDefaultAccountError,
      'error.switch.invalid-accountId' => IGMarkets::InvalidAccountIDError,
      'error.unsupported.epic' => IGMarkets::UnsupportedEPICError,
      'error.watchlists.management.cannot-delete-watchlist' => IGMarkets::CannotDeleteWatchlistError,
      'error.watchlists.management.duplicate-name' => IGMarkets::DuplicateWatchlistNameError,
      'error.watchlists.management.error' => IGMarkets::WatchlistError,
      'error.watchlists.management.watchlist-not-found' => IGMarkets::WatchlistNotFoundError,
      'invalid.input' => IGMarkets::InvalidInputError,
      'invalid.url' => IGMarkets::InvalidURLError,
      'system.error' => IGMarkets::SystemError,
      'unauthorised.access.to.equity.exception' => IGMarkets::UnauthorisedAccessToEquityError,
      'unauthorised.api-key.revoked' => IGMarkets::APIKeyRevokedError,
      'unauthorised.clientId.api-key.mismatch' => IGMarkets::InvalidAPIKeyForClientError
    }.each do |error_code, error_class|
      expect(IGMarkets::IGMarketsError.build(error_code)).to be_a(error_class)
    end
  end

  it 'builds a base error when the error code is unknown' do
    expect(IGMarkets::IGMarketsError).to receive(:new).with('error.unknown')

    IGMarkets::IGMarketsError.build 'error.unknown'
  end
end
