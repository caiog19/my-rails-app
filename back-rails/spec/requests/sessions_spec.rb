require 'swagger_helper'

RSpec.describe 'Sessions API', type: :request do

  path '/login' do

    post('Realiza login de usuário') do
      tags 'Autenticação'       
      consumes 'application/json'
      produces 'application/json'

      parameter name: :login_data, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }

      response(200, 'Sucesso') do
        let(:user) { User.create!(email: 'teste@example.com', password: 'Pass@123', password_confirmation: 'Pass@123', full_name: 'Test User') }
        let(:login_data) do
          {
            email: user.email,
            password: 'Pass@123'
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Login realizado com sucesso!')
          expect(data['token']).to be_present
        end
      end

      response(401, 'Não autorizado (credenciais inválidas)') do
        let(:login_data) { { email: 'naoexiste@example.com', password: 'invalido' } }
        run_test!
      end
    end
  end
end
