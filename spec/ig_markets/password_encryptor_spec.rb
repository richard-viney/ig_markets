describe IGMarkets::PasswordEncryptor do
  let(:rsa_key_pair) { OpenSSL::PKey::RSA.new 2048 }
  let(:time_stamp) { '1000' }
  let(:encryptor) do
    IGMarkets::PasswordEncryptor.new.tap do |e|
      e.encoded_public_key = Base64.strict_encode64 rsa_key_pair.to_pem
      e.time_stamp = time_stamp
    end
  end

  it 'encrypts a password' do
    password = 'test'

    encoded_encrypted_password = encryptor.encrypt password

    decoded_encrypted_password = Base64.strict_decode64 encoded_encrypted_password
    encoded_decrypted_password = rsa_key_pair.private_decrypt decoded_encrypted_password
    decoded_decrypted_password = Base64.strict_decode64 encoded_decrypted_password

    expect(decoded_decrypted_password).to eq("#{password}|#{time_stamp}")
  end
end
