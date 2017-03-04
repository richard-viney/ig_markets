describe IGMarkets::PasswordEncryptor do
  let(:encryptor) { described_class.new }
  let(:rsa_key_pair) { OpenSSL::PKey::RSA.new 2048 }

  it 'sets its public key from an encoded public key' do
    encryptor.encoded_public_key = Base64.strict_encode64 rsa_key_pair.to_pem
    expect(encryptor.public_key.to_pem).to eq(rsa_key_pair.to_pem)
  end

  it 'encrypts a password' do
    password = 'test'

    encryptor.time_stamp = '1000'
    encryptor.public_key = rsa_key_pair

    encoded_encrypted_password = encryptor.encrypt password

    decoded_encrypted_password = Base64.strict_decode64 encoded_encrypted_password
    encoded_decrypted_password = rsa_key_pair.private_decrypt decoded_encrypted_password
    decoded_decrypted_password = Base64.strict_decode64 encoded_decrypted_password

    expect(decoded_decrypted_password).to eq("#{password}|#{encryptor.time_stamp}")
  end
end
