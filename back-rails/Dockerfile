# syntax=docker/dockerfile:1

# Base para produção
ARG RUBY_VERSION=3.3.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives aqui
WORKDIR /rails

# Instalar pacotes base
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips sqlite3 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configurar o ambiente de produção
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Estágio de build para reduzir o tamanho da imagem final
FROM base AS build

# Instalar pacotes necessários para compilar gems e dependências do Node.js
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config libpq-dev nodejs npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Instalar gems do projeto
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copiar o código da aplicação
COPY . .


# Ajustar os scripts binários para ambiente Linux
RUN chmod +x bin/* && \
    sed -i 's/ruby.exe/ruby/' bin/* && \
    sed -i "s/\r$//g" bin/*

# Instalar dependências do Vite
RUN npm install --prefix ./ && npm run build --prefix ./

# Pré-compilar os assets para produção
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Estágio final para a imagem da aplicação
FROM base

# Copiar artefatos: gems e aplicação
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Criar usuário não-root para segurança
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Configurar entrypoint
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expor porta 80
EXPOSE 80

# Comando padrão para iniciar o servidor
CMD ["./bin/thrust", "./bin/rails", "server"]
