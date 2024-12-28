<template>
    <div>
      <h2>Recuperar Senha</h2>
      <form @submit.prevent="submitRequest">
        <div>
          <label for="email">Email:</label>
          <input v-model="email" id="email" type="email" required />
        </div>
        <button type="submit">Enviar Instruções</button>
      </form>
    </div>
  </template>
  
  <script>
  import api from '../services/api';
  
  export default {
    name: 'PasswordResetRequest',
    data() {
      return {
        email: '',
      };
    },
    methods: {
      async submitRequest() {
        try {
          const response = await api.post('/password_resets', { email: this.email });
          alert(response.data.message || 'Se o email existir, as instruções serão enviadas.');
          this.$router.push('/login');
        } catch (error) {
          if (error.response && error.response.data && error.response.data.errors) {
            alert('Erro: ' + error.response.data.errors.join(', '));
          } else {
            alert('Erro ao solicitar recuperação de senha.');
            console.error(error);
          }
        }
      },
    },
  };
  </script>
  