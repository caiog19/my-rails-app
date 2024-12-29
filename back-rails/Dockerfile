# syntax=docker/dockerfile:1

# -------------------------------
# Base para produção
# -------------------------------
    ARG RUBY_VERSION=3.2.0
    FROM ruby:$RUBY_VERSION-slim AS base
    
    WORKDIR /rails
    
    # Instalar pacotes base
    RUN apt-get update -qq && \
        apt-get install --no-install-recommends -y \
          curl \
          libjemalloc2 \
          libvips \
          sqlite3 \
          libpq5 \
          ca-certificates \
          gnupg && \
        rm -rf /var/lib/apt/lists /var/cache/apt/archives
    
    # Configurar o ambiente de produção
    ENV RAILS_ENV="production" \
        BUNDLE_DEPLOYMENT="1" \
        BUNDLE_PATH="/usr/local/bundle" \
        BUNDLE_WITHOUT="development"
    
    # -------------------------------
    # Estágio de build
    # -------------------------------
    FROM base AS build
    
    # Definir argumentos de build para variáveis de ambiente
    ARG CORS_ORIGINS="http://localhost:8080,https://my-rails-app.vercel.app"
    
    # Definir as variáveis de ambiente
    ENV CORS_ORIGINS=${CORS_ORIGINS} \
        NODE_VERSION=18.x
    
    # Instalar pacotes necessários para compilar gems e dependências do Node.js + dos2unix
    RUN apt-get update -qq && \
        apt-get install --no-install-recommends -y \
          build-essential \
          git \
          pkg-config \
          libpq-dev \
          curl \
          gnupg \
          dos2unix && \
        rm -rf /var/lib/apt/lists /var/cache/apt/archives
    
    # Instalar Node.js 18.x via NodeSource
    RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
        apt-get install -y nodejs && \
        rm -rf /var/lib/apt/lists /var/cache/apt/archives
    
    # Verificar versões instaladas (opcional)
    RUN node -v
    RUN npm -v
    
    # Copiar arquivos para instalar gems
    COPY Gemfile Gemfile.lock ./
    RUN bundle install && \
        rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
        bundle exec bootsnap precompile --gemfile
    
    # Copiar todo o código da aplicação
    COPY . .
    
    # Converter scripts em bin/* de CRLF → LF e remover "ruby.exe"
    RUN dos2unix bin/* && \
        chmod +x bin/* && \
        sed -i 's/ruby.exe/ruby/' bin/*
    
    # Instalar dependências do Vite e construir os assets
    RUN npm install && npm run build
    
    # (Opcional) Corrigir vulnerabilidades do npm
    RUN npm audit fix || true
    
    # Pré-compilar os assets para produção
    RUN test "$SKIP_ASSETS" = "true" || SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile
    
    
#     RUN BUNDLE_WITHOUT="development" RAILS_ENV=test ./bin/rails db:create db:migrate && \
   #      ./bin/rails rswag:specs:swaggerize
    
    # -------------------------------
    # Estágio final
    # -------------------------------
    FROM base
    
    # Copiar artefatos (gems + código) do estágio de build
    COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
    COPY --from=build /rails /rails
    
    # Ajustar permissões e criar usuário não-root
    RUN groupadd --system --gid 1000 rails && \
        useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
        chown -R rails:rails db log storage tmp
    
    USER 1000:1000
    
    # Expor porta 3000
    EXPOSE 3000
    
    # Comando padrão para subir a app (fazendo db:migrate antes)
    CMD ["sh", "-c", "bin/rails db:migrate && bin/rails server -b 0.0.0.0"]
    