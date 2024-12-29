<template>
  <div class="auth-container">
    <h2>Cadastrar</h2>
    <form @submit.prevent="register">
      <div>
        <label for="fullName">Nome Completo:</label>
        <input
          v-model="user.full_name"
          id="fullName"
          type="text"
          placeholder="Digite seu nome completo"
          :class="{ 'is-invalid': getError('full_name') }"
          required
        />
        <p v-if="getError('full_name')" class="error-message">
          {{ getError('full_name') }}
        </p>
      </div>
      <div>
        <label for="email">Email:</label>
        <input
          v-model="user.email"
          id="email"
          type="email"
          placeholder="Digite seu email"
          :class="{ 'is-invalid': getError('email') }"
          required
        />
        <p v-if="getError('email')" class="error-message">
          {{ getError('email') }}
        </p>
      </div>
      <div>
        <label for="password">Senha:</label>
        <input
          v-model="user.password"
          :type="showPassword ? 'text' : 'password'"
          id="password"
          placeholder="Digite sua senha"
          :class="{ 'is-invalid': getError('password') }"
          required
        />
        <span @click="togglePasswordVisibility" class="password-toggle">
          {{ showPassword ? '🔒' : '👁️' }}
        </span>
        <p v-if="getError('password')" class="error-message">
          {{ getError('password') }}
        </p>
      </div>
      <div>
        <label for="passwordConfirmation">Confirme a Senha:</label>
        <input
          v-model="user.password_confirmation"
          :type="showPassword ? 'text' : 'password'"
          id="passwordConfirmation"
          placeholder="Confirme sua senha"
          :class="{ 'is-invalid': getError('password_confirmation') }"
          required
        />
        <span @click="togglePasswordVisibility" class="password-toggle">
          {{ showPassword ? '🔒' : '👁️' }}
        </span>
        <p v-if="getError('password_confirmation')" class="error-message">
          {{ getError('password_confirmation') }}
        </p>
      </div>
      <button type="submit">Cadastrar</button>
    </form>
    <p class="auth-message">
      Já tem uma conta? 
      <router-link to="/login">Fazer Login</router-link>
    </p>
  </div>
</template>

<script>
import api from '../services/api';
import './BlogAuth.css';

export default {
  name: 'UserRegister',
  data() {
    return {
      user: {
        full_name: '',
        email: '',
        password: '',
        password_confirmation: '',
      },
      errors: [],
      showPassword: false, 
    };
  },
  methods: {
    togglePasswordVisibility() {
      this.showPassword = !this.showPassword;
    },
    async register() {
      this.errors = [];
      if (!this.user.full_name) {
        this.errors.push({ field: 'full_name', message: 'Nome Completo não pode estar vazio' });
      }
      if (!this.user.email) {
        this.errors.push({ field: 'email', message: 'Email não pode estar vazio' });
      }
      if (this.user.password.length < 8) {
        this.errors.push({ field: 'password', message: 'Senha deve ter no mínimo 8 caracteres' });
      }
      if (this.user.password !== this.user.password_confirmation) {
        this.errors.push({ field: 'password_confirmation', message: 'Confirmação de Senha não coincide' });
      }
      if (this.errors.length) {
        return;
      }

      try {
        const response = await api.post('/signup', { user: this.user });
        alert(response.data.message);
        this.$router.push('/login');
      } catch (error) {
        if (error.response && error.response.data && error.response.data.errors) {
          this.errors = error.response.data.errors;
        } else {
          alert('Erro ao cadastrar: algo deu errado.');
          console.error(error);
        }
      }
    },
    getError(field) {
      const error = this.errors.find((e) => e.field === field);
      return error ? error.message : null;
    },
  },
};
</script>
