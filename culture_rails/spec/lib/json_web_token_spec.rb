require 'rails_helper'

RSpec.describe JsonWebToken do
  let(:user) { create(:user) }
  let(:test_payload) { { user_id: 123, custom_data: 'test' } }

  describe '.encode' do
    it 'ペイロードからJWTトークンを生成する' do
      token = JsonWebToken.encode(test_payload)

      expect(token).to be_present
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT format: header.payload.signature
    end

    it 'expとiatが自動的に設定される' do
      freeze_time = Time.current
      allow(Time).to receive(:current).and_return(freeze_time)

      token = JsonWebToken.encode(test_payload)
      decoded = JsonWebToken.decode(token)

      expect(decoded[:user_id]).to eq(123)
      expect(decoded[:custom_data]).to eq('test')
      expect(decoded[:iat]).to eq(freeze_time.to_i)
      expect(decoded[:exp]).to be > freeze_time.to_i
    end

    it 'カスタム有効期限を設定できる' do
      custom_exp = 1.hour.from_now
      token = JsonWebToken.encode(test_payload, custom_exp)
      decoded = JsonWebToken.decode(token)

      expect(decoded[:exp]).to eq(custom_exp.to_i)
    end
  end

  describe '.encode_for_user' do
    it 'ユーザーからJWTトークンを生成する' do
      token = JsonWebToken.encode_for_user(user)

      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it 'ユーザーIDがトークンに含まれる' do
      token = JsonWebToken.encode_for_user(user)
      decoded = JsonWebToken.decode(token)

      expect(decoded[:user_id]).to eq(user.id)
      expect(decoded[:iat]).to be_present
      expect(decoded[:exp]).to be_present
    end

    it 'カスタム有効期限を設定できる' do
      custom_exp = 2.hours.from_now
      token = JsonWebToken.encode_for_user(user, custom_exp)
      decoded = JsonWebToken.decode(token)

      expect(decoded[:user_id]).to eq(user.id)
      expect(decoded[:exp]).to eq(custom_exp.to_i)
    end
  end

  describe '.decode' do
    it '有効なトークンをデコードする' do
      token = JsonWebToken.encode(test_payload)
      decoded = JsonWebToken.decode(token)

      expect(decoded).to be_a(HashWithIndifferentAccess)
      expect(decoded[:user_id]).to eq(123)
      expect(decoded[:custom_data]).to eq('test')
    end

    it '無効なトークンではnilを返す' do
      invalid_token = 'invalid.jwt.token'

      expect(Rails.logger).to receive(:error).with(/JWT Decode Error/)
      result = JsonWebToken.decode(invalid_token)

      expect(result).to be_nil
    end

    it '空文字列ではnilを返す' do
      expect(Rails.logger).to receive(:error).with(/JWT Decode Error/)
      result = JsonWebToken.decode('')

      expect(result).to be_nil
    end

    it '期限切れトークンではnilを返す' do
      expired_time = 1.hour.ago
      token = JsonWebToken.encode(test_payload, expired_time)

      expect(Rails.logger).to receive(:error).with(/JWT Decode Error/)
      result = JsonWebToken.decode(token)

      expect(result).to be_nil
    end
  end

  describe '.user_id_from_token' do
    it '有効なトークンからuser_idを抽出する' do
      token = JsonWebToken.encode_for_user(user)
      extracted_user_id = JsonWebToken.user_id_from_token(token)

      expect(extracted_user_id).to eq(user.id)
    end

    it '無効なトークンではnilを返す' do
      invalid_token = 'invalid.jwt.token'

      expect(Rails.logger).to receive(:error).with(/JWT Decode Error/)
      result = JsonWebToken.user_id_from_token(invalid_token)

      expect(result).to be_nil
    end

    it 'user_idが含まれていないトークンではnilを返す' do
      token = JsonWebToken.encode({ other_data: 'test' })
      result = JsonWebToken.user_id_from_token(token)

      expect(result).to be_nil
    end
  end
end
