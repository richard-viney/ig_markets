describe IGMarkets::PasswordEncryptor do
  let(:rsa_key_pair) { OpenSSL::PKey::RSA.new 2048 }
  let(:encryptor) { IGMarkets::PasswordEncryptor.new Base64.strict_encode64(rsa_key_pair.to_pem), '1000' }

  it 'encrypts a password correctly' do
    encoded_encrypted_password = encryptor.encrypt 'test'

    decoded_encrypted_password = Base64.strict_decode64 encoded_encrypted_password
    encoded_decrypted_password = rsa_key_pair.private_decrypt decoded_encrypted_password
    decoded_decrypted_password = Base64.strict_decode64 encoded_decrypted_password

    expect(decoded_decrypted_password).to eq('test|1000')
  end
end
