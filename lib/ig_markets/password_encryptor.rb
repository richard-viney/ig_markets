module IGMarkets
  class PasswordEncryptor
    def initialize(encryption_key, time_stamp)
      @public_key = OpenSSL::PKey::RSA.new Base64.strict_decode64 encryption_key
      @time_stamp = time_stamp
    end

    def encrypt(password)
      encoded_password = Base64.strict_encode64 "#{password}|#{@time_stamp}"

      encrypted_password = @public_key.public_encrypt encoded_password

      Base64.strict_encode64 encrypted_password
    end
  end
end
