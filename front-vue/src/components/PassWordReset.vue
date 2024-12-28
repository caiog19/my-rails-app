<template>
    <div>
      <h2>Redefinir Senha</h2>
      <form @submit.prevent="resetPassword">
        <div>
          <label for="password">Nova Senha:</label>
          <input v-model="password" id="password" type="password" required />
        </div>
        <div>
          <label for="passwordConfirmation">Confirme a Nova Senha:</label>
          <input v-model="passwordConfirmation" id="passwordConfirmation" type="password" required />
        </div>
        <button type="submit">Redefinir Senha</button>
      </form>
    </div>
  </template>
  
  <script>
  import api from '../services/api';
  
  export default {
    name: 'PasswordReset',
    data() {
      return {
        password: '',
        passwordConfirmation: '',
        token: this.$route.params.token, 
      };
    },
    methods: {
      async resetPassword() {
          if (this.password !== this.passwordConfirmation) {
          alert('As senhas não coincidem.');
          return;
        }
        try {
          const response = await api.put(`/password_resets/${this.token}`, {
            password: this.password,
            password_confirmation: this.passwordConfirmation,
          });
          alert(response.data.message || 'Senha redefinida com sucesso!');
          this.$router.push('/login');
        } catch (error) {
          if (error.response && error.response.data && error.response.data.errors) {
            alert('Erro: ' + error.response.data.errors.join(', '));
          } else {
            alert('Erro ao redefinir senha.');
            console.error(error);
          }
        }
      },
    },
  };
  </script>
  