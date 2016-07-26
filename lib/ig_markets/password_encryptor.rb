module IGMarkets
  # Encrypts account passwords in the manner required for authentication with the IG Markets API.
  #
  # @private
  class PasswordEncryptor
    # The public key used by {#encrypt}, can also be set using {#encoded_public_key=}.
    #
    # @return [OpenSSL::PKey::RSA]
    attr_accessor :public_key

    # The time stamp used by {#encrypt}.
    #
    # @return [String]
    attr_accessor :time_stamp

    # Initializes this password encryptor with the specified encoded public key and timestamp.
    #
    # @param [String] encoded_public_key
    # @param [String] time_stamp
    def initialize(encoded_public_key = nil, time_stamp = nil)
      self.encoded_public_key = encoded_public_key if encoded_public_key
      self.time_stamp = time_stamp
    end

    # Takes an encoded public key and calls {#public_key=} with the decoded key.
    #
    # @param [String] encoded_public_key The public key encoded in Base64.
    def encoded_public_key=(encoded_public_key)
      self.public_key = OpenSSL::PKey::RSA.new Base64.strict_decode64 encoded_public_key
    end

    # Encrypts a password using this encryptor's public key and time stamp, which must have been set prior to calling
    # this method.
    #
    # @param [String] password The password to encrypt.
    #
    # @return [String] The encrypted password encoded in Base64.
    def encrypt(password)
      encoded_password = Base64.strict_encode64 "#{password}|#{time_stamp}"

      encrypted_password = public_key.public_encrypt encoded_password

      Base64.strict_encode64 encrypted_password
    end
  end
end
