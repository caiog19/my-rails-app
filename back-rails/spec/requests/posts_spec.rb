require 'swagger_helper'

RSpec.describe 'Posts API', type: :request do
  path '/posts' do
    post('Criar post') do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          content: { type: :string },
          tag_ids: { type: :array, items: { type: :integer } }
        },
        required: %w[title content]
      }

      response(201, 'Post criado com sucesso') do
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: user.id)}" }
        let(:headers) { { 'Authorization' => Authorization } }
        let(:post) do
          {
            title: 'Novo Post',
            content: 'Conteúdo do Post',
            tag_ids: []
          }
        end

        run_test! do |response|
          expect(response.status).to eq(201)
        end
      end
    end
  end
end