# Dockerfile

# syntax=docker/dockerfile:1

# Base para produção
ARG RUBY_VERSION=3.3.6
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives aqui
WORKDIR /rails

# Instalar pacotes base
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 libpq5 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configurar o ambiente de produção
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Estágio de build
FROM base AS build

# Definir argumentos de build para variáveis de ambiente
ARG CORS_ORIGINS="http://localhost:8080,https://my-rails-app.vercel.app"

# Definir as variáveis de ambiente
ENV CORS_ORIGINS=${CORS_ORIGINS}

# Instalar pacotes necessários para compilar gems e dependências do Node.js
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config libpq-dev nodejs npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copiar arquivos para instalar gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copiar o código da aplicação
COPY . .

# Ajustar permissões para scripts binários
RUN chmod +x bin/* && \
    sed -i 's/ruby.exe/ruby/' bin/* && \
    sed -i "s/\r$//g" bin/*

# Instalar dependências do Vite
RUN npm install && npm run build

# Pré-compilar os assets para produção
RUN test "$SKIP_ASSETS" = "true" || SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Estágio final
FROM base

# Copiar artefatos: gems e aplicação
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Configurar usuário não-root
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Expor porta 3000
EXPOSE 3000

# Comando padrão para executar migrações e iniciar o servidor
CMD ["sh", "-c", "bin/rails db:migrate && bin/rails server -b 0.0.0.0"]
