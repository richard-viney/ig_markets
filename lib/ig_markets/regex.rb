module IGMarkets
  # Contains regex's for validating specific types of strings.
  module Regex
    # Regex used to validate an ISO currency code.
    CURRENCY = /\A[A-Z]{3}\Z/

    # Regex used to validate an EPIC.
    EPIC = /\A[A-Z,a-z,0-9,.,_]{6,30}\Z/
  end
end
