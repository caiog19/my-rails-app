require 'swagger_helper'

RSpec.describe 'Users API', type: :request do

  path '/signup' do

    post('Cria novo usuário') do
      tags 'Usuários'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'teste@example.com' },
              password: { type: :string, example: 'Pass@123' },
              password_confirmation: { type: :string, example: 'Pass@123' },
              full_name: { type: :string, example: 'Teste da Silva' }
            },
            required: %w[email password password_confirmation full_name]
          }
        }
      }

      response(201, 'Usuário criado com sucesso') do
        let(:user) do
          {
            user: {
              email: 'teste@example.com',
              password: 'Pass@123',
              password_confirmation: 'Pass@123',
              full_name: 'Teste da Silva'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Usuário cadastrado com sucesso!')
          expect(data['token']).to be_present
        end
      end

      response(422, 'Erros de validação') do
        let(:user) { { user: { email: '', password: '' } } }
        run_test!
      end
    end
  end
end
