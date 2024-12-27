<template>
    <div>
      <h2>Cadastrar</h2>
      <form @submit.prevent="register">
        <div>
          <label for="email">Email:</label>
          <input v-model="user.email" id="email" type="email" />
        </div>
        <div>
          <label for="password">Senha:</label>
          <input v-model="user.password" id="password" type="password" />
        </div>
        <div>
          <label for="passwordConfirmation">Confirme a Senha:</label>
          <input v-model="user.password_confirmation" id="passwordConfirmation" type="password" />
        </div>
        <button type="submit">Cadastrar</button>
      </form>
    </div>
  </template>
  
  <script>
  import api from '../services/api';
  
  export default {
    name: 'UserRegister',
    data() {
      return {
        user: {
          email: '',
          password: '',
          password_confirmation: '',
        },
      };
    },
    methods: {
      async register() {
        try {
          const response = await api.post('/signup', { user: this.user });
          alert(response.data.message); 
          this.$router.push('/login'); 
        } catch (error) {
          if (error.response && error.response.data && error.response.data.errors) {
            alert('Erro ao cadastrar: ' + error.response.data.errors.join(', '));
          } else {
            alert('Erro ao cadastrar: algo deu errado.');
            console.error(error);
          }
        }
      },
    },
  };
  </script>
  