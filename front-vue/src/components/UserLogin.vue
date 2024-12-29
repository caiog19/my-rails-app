<template>
  <div class="auth-container">
    <h2>Login</h2>
    <form @submit.prevent="login">
      <div>
        <label for="email">Email:</label>
        <input
          v-model="credentials.email"
          id="email"
          type="email"
          placeholder="Digite seu email"
          required
        />
      </div>
      <div>
        <label for="password">Senha:</label>
        <input
          v-model="credentials.password"
          :type="showPassword ? 'text' : 'password'"
          id="password"
          placeholder="Digite sua senha"
          required
        />
        <span @click="togglePasswordVisibility" class="password-toggle">
          {{ showPassword ? '🔒' : '👁️' }}
        </span>
      </div>
      <button type="submit">Entrar</button>
    </form>
    <p>
      <router-link to="/esqueci-minha-senha">Esqueceu sua senha?</router-link>
    </p>
    <p class="auth-message">
      Não tem uma conta? 
      <router-link to="/register">Cadastre-se</router-link>
    </p>
  </div>
</template>

<script>
import api from '../services/api';
import { eventBus } from '../eventBus';
import '../styles/BlogAuth.css';

export default {
  name: 'UserLogin',
  data() {
    return {
      credentials: {
        email: '',
        password: '',
      },
      showPassword: false, 
    };
  },
  methods: {
    togglePasswordVisibility() {
      this.showPassword = !this.showPassword;
    },
    async login() {
      try {
        const response = await api.post('/login', this.credentials);
        alert(response.data.message);
        localStorage.setItem('token', response.data.token);
        eventBus.updateAuthentication(true);
        this.$router.push('/');
      } catch (error) {
        if (error.response && error.response.data && error.response.data.errors) {
          alert('Erro ao fazer login: ' + error.response.data.errors.join(', '));
        } else {
          alert('Erro ao fazer login: algo deu errado.');
          console.error(error);
        }
      }
    },
  },
};
</script>
