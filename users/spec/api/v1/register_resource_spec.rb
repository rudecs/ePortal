require 'rails_helper'

RSpec.describe API::V1::RegisterResource do
  describe 'POST /api/v1/register.json' do
    let(:uri) { '/api/v1/register.json' }
    let(:request_params) { {} }
    let(:headers_params) { {} }

    context 'email with password' do
      let (:request_params) do
        {
          user: {
            email: Faker::Internet.email,
            password: '123123',
          }
        }
      end

      before { post uri, params: request_params }

      it 'should responde with status 201' do
        expect(response.status).to eq(201)
      end

      it 'should responde with user data' do
        expect(JSON.parse(response.body)['user']['id']).to be > 0
        expect(JSON.parse(response.body)['user']['state']).to eq('active')
        expect(JSON.parse(response.body)['user']['email']).to eq(request_params[:user][:email])
        expect(JSON.parse(response.body)['user']['phone']).to eq(nil)
      end

      it 'should responde with session data' do
        expect(JSON.parse(response.body)['session']['token']).to be_instance_of(String)
      end

      it 'should responde with clients data' do
        expect(JSON.parse(response.body)['clients'].count).to eql(1)
        expect(JSON.parse(response.body)['clients'][0]['id']).to be > 0
        expect(JSON.parse(response.body)['clients'][0]['state']).to eq('active')
      end
    end

    context 'phone number with password' do
      let (:request_params) do
        {
          user: {
            phone: Faker::Base.numerify('7916#######'),
            password: '123123',
          }
        }
      end

      before { post uri, params: request_params }

      it 'should responde with status 201' do
        expect(response.status).to eq(201)
      end

      it 'should responde with user data' do
        expect(JSON.parse(response.body)['user']['id']).to be > 0
        expect(JSON.parse(response.body)['user']['state']).to eq('active')
        expect(JSON.parse(response.body)['user']['email']).to eq(nil)
        expect(JSON.parse(response.body)['user']['phone']).to eq(request_params[:user][:phone])
      end

      it 'should responde with session data' do
        expect(JSON.parse(response.body)['session']['token']).to be_instance_of(String)
      end

      it 'should responde with clients data' do
        expect(JSON.parse(response.body)['clients'].count).to eql(1)
        expect(JSON.parse(response.body)['clients'][0]['id']).to be > 0
        expect(JSON.parse(response.body)['clients'][0]['state']).to eq('active')
      end
    end
  end
end
