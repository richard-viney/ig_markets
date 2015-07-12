module IGMarkets
  class PasswordEncryptor
    attr_accessor :public_key
    attr_accessor :time_stamp

    def encoded_public_key=(encoded_public_key)
      self.public_key = OpenSSL::PKey::RSA.new Base64.strict_decode64 encoded_public_key
    end

    def encrypt(password)
      encoded_password = Base64.strict_encode64 "#{password}|#{time_stamp}"

      encrypted_password = public_key.public_encrypt encoded_password

      Base64.strict_encode64 encrypted_password
    end
  end
end
