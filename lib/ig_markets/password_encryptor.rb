module IGMarkets
  # Encrypts account passwords in the manner required for authentication with the IG Markets API.
  class PasswordEncryptor
    # @return [OpenSSL::PKey::RSA] The public key used by {#encrypt}, usually set using {#encoded_public_key=}.
    attr_accessor :public_key

    # @return [String] The timestamp used by {#encrypt}.
    attr_accessor :time_stamp

    # Takes an encoded public key and sets this encryptor's `public_key` attribute with the decoded key.
    #
    # @param [String] encoded_public_key The public key encoded in Base64.
    #
    # @return [void]
    def encoded_public_key=(encoded_public_key)
      self.public_key = OpenSSL::PKey::RSA.new Base64.strict_decode64 encoded_public_key
    end

    # Encrypts a password using this encryptor's public key and time stamp. Both of these must have been
    # set prior to calling this method.
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
