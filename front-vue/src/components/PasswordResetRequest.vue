<template>
  <div class="auth-container">
    <h2>Recuperar Senha</h2>
    <form @submit.prevent="submitRequest">
      <div>
        <label for="email">Email:</label>
        <input
          v-model="email"
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
      <button type="submit">Enviar Instruções</button>
    </form>
    <p>
      <router-link to="/login">Voltar para Login</router-link>
    </p>
  </div>
</template>

<script>
import api from '../services/api';
import '../styles/BlogAuth.css';
export default {
  name: 'PasswordResetRequest',
  data() {
    return {
      email: '',
      errors: [],
    };
  },
  methods: {
    async submitRequest() {
      this.errors = [];
      if (!this.email) {
        this.errors.push({ field: 'email', message: 'Email não pode estar vazio' });
      }
      if (this.errors.length) {
        return;
      }

      try {
        const response = await api.post('/password_resets', { email: this.email });
        alert(response.data.message || 'Se o email existir, as instruções serão enviadas.');
        this.$router.push('/login');
      } catch (error) {
        if (error.response && error.response.data && error.response.data.errors) {
          this.errors = error.response.data.errors;
          alert('Erro: ' + error.response.data.errors.join(', '));
        } else {
          alert('Erro ao solicitar recuperação de senha.');
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


