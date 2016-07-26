module IGMarkets
  # Base class for all errors raised by this gem.
  class IGMarketsError < StandardError
  end

  # This error is raised when the specified account is invalid.
  class InvalidClientAccountError < IGMarketsError
  end

  # This error is raised when the API key can't be used for this endpoint.
  class APIKeyRejectedError < IGMarketsError
  end

  # This error is raised when a specified deal can't be found.
  class DealNotFoundError < IGMarketsError
  end

  # This error is raised when an invalid date range is specified.
  class InvalidDateRangeError < IGMarketsError
  end

  # This error is raised when an invalid watchlist name is specified.
  class InvalidWatchlistError < IGMarketsError
  end

  # This error is raised when a malformed date is specified.
  class MalformedDateError < IGMarketsError
  end

  # This error is raised when a specified position can't be found.
  class PositionNotFoundError < IGMarketsError
  end

  # This error is raised when a generic position error occurs.
  class PositionError < IGMarketsError
  end

  # This error is raised when a specified EPIC can't be found.
  class EPICNotFoundError < IGMarketsError
  end

  # This error is raised when the account's traffic allowance is exceeded.
  class ExceededAccountAllowanceError < IGMarketsError
  end

  # This error is raised when the account's historical data allowance is exceeded.
  class ExceededAccountHistoricalDataAllowanceError < IGMarketsError
  end

  # This error is raised when the account's trading allowance is exceeded.
  class ExceededAccountTradingAllowanceError < IGMarketsError
  end

  # This error is raised when the API key's allowance is exceeded.
  class ExceededAPIKeyAllowanceError < IGMarketsError
  end

  # This error is raised when trying to login with an unencrypted password to a server that requires encryption.
  class EncryptionRequiredError < IGMarketsError
  end

  # This error is raised when required KYC (Know Your Client) authorization for this account is incomplete.
  class KYCRequiredForAccountError < IGMarketsError
  end

  # This error is raised when relevant credentials are not supplied.
  class MissingCredentialsError < IGMarketsError
  end

  # This error is raised when the account has pending agreements that must be agreed to before using the account.
  class PendingAgreementsError < IGMarketsError
  end

  # This error is raised when the preferred account is disabled.
  class PreferredAccountDisabledError < IGMarketsError
  end

  # This error is raised when the preferred account is not set.
  class PreferredAccountNotSetError < IGMarketsError
  end

  # This error is raised when stockbroking is not supported.
  class StockbrokingNotSupportedError < IGMarketsError
  end

  # This error is raised when too many EPICs are specified for a request.
  class TooManyEPICSError < IGMarketsError
  end

  # This error is raised when the account has been denied login privileges.
  class AccountAccessDeniedError < IGMarketsError
  end

  # This error is raised when the account has been migrated to the client-account model and should be authenticated
  # with the relevant client credentials.
  class AccountMigratedError < IGMarketsError
  end

  # This error is raised when the account has not yet been activated.
  class AccountNotYetActivatedError < IGMarketsError
  end

  # This error is raised when the the account has been suspended.
  class AccountSuspendedError < IGMarketsError
  end

  # This error is raised when the service requires an account token but the one given was invalid.
  class AccountTokenInvalidError < IGMarketsError
  end

  # This error is raised when the service requires an account token but none was specified.
  class AccountTokenMissingError < IGMarketsError
  end

  # This error is raised when all accounts are in the 'pending' state.
  class AllAccountsPendingError < IGMarketsError
  end

  # This error is raised when all accounts are in the 'suspended' state.
  class AllAccountsSuspendedError < IGMarketsError
  end

  # This error is raised when the specified API key is not enabled.
  class APIKeyDisabledError < IGMarketsError
  end

  # This error is raised when the specified API key is invalid.
  class APIKeyInvalidError < IGMarketsError
  end

  # This error is raised when no API key was specified.
  class APIKeyMissingError < IGMarketsError
  end

  # This error is raised when the specified API key is not valid for the requested account.
  class APIKeyRestrictedError < IGMarketsError
  end

  # This error is raised when the specified API key has been revoked.
  class APIKeyRevokedError < IGMarketsError
  end

  # This error is raised when the client has been suspended from using the platform.
  class ClientSuspendedError < IGMarketsError
  end

  # This error is raised when the specified client token is invalid.
  class ClientTokenInvalidError < IGMarketsError
  end

  # This error is raised when no client token was specified.
  class ClientTokenMissingError < IGMarketsError
  end

  # This error is raised when there is a generic security error.
  class SecurityError < IGMarketsError
  end

  # This error is raised when the provided user agent string is not valid.
  class InvalidApplicationError < IGMarketsError
  end

  # This error is raised when the specified user credentials are not valid.
  class InvalidCredentialsError < IGMarketsError
  end

  # This error is raised when the requested site is not accessible through the API.
  class InvalidWebsiteError < IGMarketsError
  end

  # This error is raised when there have been too many failed login attempts.
  class TooManyFailedLoginAttemptsError < IGMarketsError
  end

  # This error is raised when an invalid EPIC was used when interacting with a watchlist.
  class WatchlistInvalidEPICError < IGMarketsError
  end

  # This error is raised when trying to set the current account to the current account.
  class AccountAlreadyCurrentError < IGMarketsError
  end

  # This error is raised when setting the default account is not allowed.
  class CannotSetDefaultAccountError < IGMarketsError
  end

  # This error is raised when an invalid account ID was specified.
  class InvalidAccountIDError < IGMarketsError
  end

  # This error is raised when an unsupported EPIC was specified.
  class UnsupportedEPICError < IGMarketsError
  end

  # This error is raised when trying to delete a watchlist that can't be deleted.
  class CannotDeleteWatchlistError < IGMarketsError
  end

  # This error is raised when trying to set two watchlists to have the same name.
  class DuplicateWatchlistNameError < IGMarketsError
  end

  # This error is raised when a generic watchlist error occurs.
  class WatchlistError < IGMarketsError
  end

  # This error is raised when the specified watchlist could not be found.
  class WatchlistNotFoundError < IGMarketsError
  end

  # This error is raised when invalid input was supplied.
  class InvalidInputError < IGMarketsError
  end

  # This error is raised when an invalid URL was specified.
  class InvalidURLError < IGMarketsError
  end

  # This error is raised when a generic system error occurs.
  class SystemError < IGMarketsError
  end

  # This error is raised when trying attempting unauthorised access to an equity.
  class UnauthorisedAccessToEquityError < IGMarketsError
  end

  # This error is raised when the specified API key is not valid for the client.
  class InvalidAPIKeyForClientError < IGMarketsError
  end

  # This error is raised when invalid JSON is returned by the IG Markets API.
  class InvalidJSONError < IGMarketsError
  end

  # This error is raised when an HTTP connection error occurs.
  class ConnectionError < IGMarketsError
  end

  # Base class for all errors raised by this gem.
  class IGMarketsError
    # Takes an IG Markets error code and returns an instance of the relevant error class that should be raised in
    # response to the error.
    #
    # @param [String] error_code The error code.
    #
    # @return [LightstreamerError]
    #
    # @private
    def self.build(error_code)
      if API_ERROR_CODE_TO_CLASS.key? error_code
        API_ERROR_CODE_TO_CLASS[error_code].new ''
      else
        new error_code
      end
    end

    API_ERROR_CODE_TO_CLASS = {
      'authentication.failure.not-a-client-account' => InvalidClientAccountError,
      'endpoint.unavailable.for.api-key' => APIKeyRejectedError,
      'error.confirms.deal-not-found' => DealNotFoundError,
      'error.invalid.daterange' => InvalidDateRangeError,
      'error.invalid.watchlist' => InvalidWatchlistError,
      'error.malformed.date' => MalformedDateError,
      'error.position.notfound' => PositionNotFoundError,
      'error.positions.generic' => PositionError,
      'error.public-api.epic-not-found' => EPICNotFoundError,
      'error.public-api.exceeded-account-allowance' => ExceededAccountAllowanceError,
      'error.public-api.exceeded-account-historical-data-allowance' => ExceededAccountHistoricalDataAllowanceError,
      'error.public-api.exceeded-account-trading-allowance' => ExceededAccountTradingAllowanceError,
      'error.public-api.exceeded-api-key-allowance' => ExceededAPIKeyAllowanceError,
      'error.public-api.failure.encryption.required' => EncryptionRequiredError,
      'error.public-api.failure.kyc.required' => KYCRequiredForAccountError,
      'error.public-api.failure.missing.credentials' => MissingCredentialsError,
      'error.public-api.failure.pending.agreements.required' => PendingAgreementsError,
      'error.public-api.failure.preferred.account.disabled' => PreferredAccountDisabledError,
      'error.public-api.failure.preferred.account.not.set' => PreferredAccountNotSetError,
      'error.public-api.failure.stockbroking-not-supported' => StockbrokingNotSupportedError,
      'error.public-api.too-many-epics' => TooManyEPICSError,
      'error.security.account-access-denied' => AccountAccessDeniedError,
      'error.security.account-migrated' => AccountMigratedError,
      'error.security.account-not-yet-activated' => AccountNotYetActivatedError,
      'error.security.account-suspended' => AccountSuspendedError,
      'error.security.account-token-invalid' => AccountTokenInvalidError,
      'error.security.account-token-missing' => AccountTokenMissingError,
      'error.security.all-accounts-pending' => AllAccountsPendingError,
      'error.security.all-accounts-suspended' => AllAccountsSuspendedError,
      'error.security.api-key-disabled' => APIKeyDisabledError,
      'error.security.api-key-invalid' => APIKeyInvalidError,
      'error.security.api-key-missing' => APIKeyMissingError,
      'error.security.api-key-restricted' => APIKeyRestrictedError,
      'error.security.api-key-revoked' => APIKeyRevokedError,
      'error.security.client-suspended' => ClientSuspendedError,
      'error.security.client-token-invalid' => ClientTokenInvalidError,
      'error.security.client-token-missing' => ClientTokenMissingError,
      'error.security.generic' => SecurityError,
      'error.security.invalid-application' => InvalidApplicationError,
      'error.security.invalid-details' => InvalidCredentialsError,
      'error.security.invalid-website' => InvalidWebsiteError,
      'error.security.too-many-failed-attempts' => TooManyFailedLoginAttemptsError,
      'error.service.watchlists.add-instrument.invalid-epic' => WatchlistInvalidEPICError,
      'error.switch.accountId-must-be-different' => AccountAlreadyCurrentError,
      'error.switch.cannot-set-default-account' => CannotSetDefaultAccountError,
      'error.switch.invalid-accountId' => InvalidAccountIDError,
      'error.unsupported.epic' => UnsupportedEPICError,
      'error.watchlists.management.cannot-delete-watchlist' => CannotDeleteWatchlistError,
      'error.watchlists.management.duplicate-name' => DuplicateWatchlistNameError,
      'error.watchlists.management.error' => WatchlistError,
      'error.watchlists.management.watchlist-not-found' => WatchlistNotFoundError,
      'invalid.input' => InvalidInputError,
      'invalid.url' => InvalidURLError,
      'system.error' => SystemError,
      'unauthorised.access.to.equity.exception' => UnauthorisedAccessToEquityError,
      'unauthorised.api-key.revoked' => APIKeyRevokedError,
      'unauthorised.clientId.api-key.mismatch' => InvalidAPIKeyForClientError
    }.freeze

    private_constant :API_ERROR_CODE_TO_CLASS
  end
end
