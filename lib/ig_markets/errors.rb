module IGMarkets
  # Base class for all errors raised by this gem.
  class IGMarketsError < StandardError
  end

  # This module contains all the error classes for this gem. They all subclass {IGMarketsError}.
  module Errors
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

    # This error is raised when too many markets are specified for a request.
    class TooManyMarketsError < IGMarketsError
    end

    # This error is raised when an invalid page size is specified.
    class InvalidPageSizeError < IGMarketsError
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

    # This error is raised when a timeout occurs during authentication.
    class AuthenticationTimeoutError < IGMarketsError
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

    # This error is raised when an invalid OAuth access token is encountered.
    class OAuthTokenInvalidError < IGMarketsError
    end

    # This error is raised when there have been too many failed login attempts.
    class TooManyFailedLoginAttemptsError < IGMarketsError
    end

    # This error is raised when an invalid EPIC was used when interacting with a watchlist.
    class WatchlistInvalidEPICError < IGMarketsError
    end

    # This error is raised when the expiry period of the sprint market position is invalid.
    class SprintMarketPositionInvalidExpiryError < IGMarketsError
    end

    # This error is raised when an unspecified error occurs trying to create a sprint market position.
    class SprintMarketPositionCreateError < IGMarketsError
    end

    # This error is raised when the expiry time of a sprint market falls outside market trading hours.
    class SprintMarketClosedError < IGMarketsError
    end

    # This error is raised when a sprint market position's order size is invalid.
    class SprintMarketInvalidOrderSizeError < IGMarketsError
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

    # This error is raised when a specified instrument is not found.
    class InstrumentNotFoundError < IGMarketsError
    end

    # This error is raised when market orders are not supported.
    class MarketOrdersNotSupported < IGMarketsError
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
  end

  # Base class for all errors raised by this gem.
  class IGMarketsError
    # Takes an IG Markets error code and returns an instance of the relevant error class that should be raised in
    # response to the error.
    #
    # @param [String] error_code The error code.
    #
    # @return [IGMarketsError]
    #
    # @private
    def self.build(error_code)
      if API_ERROR_CODE_TO_CLASS.key? error_code
        API_ERROR_CODE_TO_CLASS[error_code].new ''
      else
        @reported_unrecognized_error_codes ||= []

        unless @reported_unrecognized_error_codes.include? error_code
          @reported_unrecognized_error_codes << error_code
          warn "ig_markets: unrecognized error code #{error_code}"
        end

        new error_code
      end
    end

    API_ERROR_CODE_TO_CLASS = {
      'authentication.failure.not-a-client-account' => Errors::InvalidClientAccountError,
      'endpoint.unavailable.for.api-key' => Errors::APIKeyRejectedError,
      'error.confirms.deal-not-found' => Errors::DealNotFoundError,
      'error.invalid.daterange' => Errors::InvalidDateRangeError,
      'error.invalid.watchlist' => Errors::InvalidWatchlistError,
      'error.malformed.date' => Errors::MalformedDateError,
      'error.position.notfound' => Errors::PositionNotFoundError,
      'error.positions.generic' => Errors::PositionError,
      'error.public-api.epic-not-found' => Errors::EPICNotFoundError,
      'error.public-api.exceeded-account-allowance' => Errors::ExceededAccountAllowanceError,
      'error.public-api.exceeded-account-historical-data-allowance' =>
        Errors::ExceededAccountHistoricalDataAllowanceError,
      'error.public-api.exceeded-account-trading-allowance' => Errors::ExceededAccountTradingAllowanceError,
      'error.public-api.exceeded-api-key-allowance' => Errors::ExceededAPIKeyAllowanceError,
      'error.public-api.failure.encryption.required' => Errors::EncryptionRequiredError,
      'error.public-api.failure.kyc.required' => Errors::KYCRequiredForAccountError,
      'error.public-api.failure.missing.credentials' => Errors::MissingCredentialsError,
      'error.public-api.failure.pending.agreements.required' => Errors::PendingAgreementsError,
      'error.public-api.failure.preferred.account.disabled' => Errors::PreferredAccountDisabledError,
      'error.public-api.failure.preferred.account.not.set' => Errors::PreferredAccountNotSetError,
      'error.public-api.failure.stockbroking-not-supported' => Errors::StockbrokingNotSupportedError,
      'error.public-api.too-many-epics' => Errors::TooManyEPICSError,
      'error.request.invalid.date-range' => Errors::InvalidDateRangeError,
      'error.request.invalid.page-size' => Errors::InvalidPageSizeError,
      'error.security.account-access-denied' => Errors::AccountAccessDeniedError,
      'error.security.account-migrated' => Errors::AccountMigratedError,
      'error.security.account-not-yet-activated' => Errors::AccountNotYetActivatedError,
      'error.security.account-suspended' => Errors::AccountSuspendedError,
      'error.security.account-token-invalid' => Errors::AccountTokenInvalidError,
      'error.security.account-token-missing' => Errors::AccountTokenMissingError,
      'error.security.all-accounts-pending' => Errors::AllAccountsPendingError,
      'error.security.all-accounts-suspended' => Errors::AllAccountsSuspendedError,
      'error.security.api-key-disabled' => Errors::APIKeyDisabledError,
      'error.security.api-key-invalid' => Errors::APIKeyInvalidError,
      'error.security.api-key-missing' => Errors::APIKeyMissingError,
      'error.security.api-key-restricted' => Errors::APIKeyRestrictedError,
      'error.security.api-key-revoked' => Errors::APIKeyRevokedError,
      'error.security.authentication.timeout' => Errors::AuthenticationTimeoutError,
      'error.security.client-suspended' => Errors::ClientSuspendedError,
      'error.security.client-token-invalid' => Errors::ClientTokenInvalidError,
      'error.security.client-token-missing' => Errors::ClientTokenMissingError,
      'error.security.generic' => Errors::SecurityError,
      'error.security.invalid-application' => Errors::InvalidApplicationError,
      'error.security.invalid-details' => Errors::InvalidCredentialsError,
      'error.security.invalid-website' => Errors::InvalidWebsiteError,
      'error.security.oauth-token-invalid' => Errors::OAuthTokenInvalidError,
      'error.security.too-many-failed-attempts' => Errors::TooManyFailedLoginAttemptsError,
      'error.service.watchlists.add-instrument.invalid-epic' => Errors::WatchlistInvalidEPICError,
      'error.sprintmarket.create-position.expiry.outside-valid-range' => Errors::SprintMarketPositionInvalidExpiryError,
      'error.sprintmarket.create-position.failure' => Errors::SprintMarketPositionCreateError,
      'error.sprintmarket.create-position.market-closed' => Errors::SprintMarketPositionInvalidExpiryError,
      'error.sprintmarket.create-position.order-size.invalid' => Errors::SprintMarketInvalidOrderSizeError,
      'error.switch.accountId-must-be-different' => Errors::AccountAlreadyCurrentError,
      'error.switch.cannot-set-default-account' => Errors::CannotSetDefaultAccountError,
      'error.switch.invalid-accountId' => Errors::InvalidAccountIDError,
      'error.trading.otc.instrument-not-found' => Errors::InstrumentNotFoundError,
      'error.trading.otc.market-orders.not-supported' => Errors::MarketOrdersNotSupported,
      'error.unsupported.epic' => Errors::UnsupportedEPICError,
      'error.watchlists.management.cannot-delete-watchlist' => Errors::CannotDeleteWatchlistError,
      'error.watchlists.management.duplicate-name' => Errors::DuplicateWatchlistNameError,
      'error.watchlists.management.error' => Errors::WatchlistError,
      'error.watchlists.management.watchlist-not-found' => Errors::WatchlistNotFoundError,
      'invalid.input' => Errors::InvalidInputError,
      'invalid.input.too.many.markets' => Errors::TooManyMarketsError,
      'invalid.url' => Errors::InvalidURLError,
      'system.error' => Errors::SystemError,
      'unauthorised.access.to.equity.exception' => Errors::UnauthorisedAccessToEquityError,
      'unauthorised.api-key.revoked' => Errors::APIKeyRevokedError,
      'unauthorised.clientId.api-key.mismatch' => Errors::InvalidAPIKeyForClientError
    }.freeze

    private_constant :API_ERROR_CODE_TO_CLASS
  end
end
