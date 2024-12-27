<template>
    <div>
      <h2>Login</h2>
      <form @submit.prevent="login">
        <div>
          <label for="email">Email:</label>
          <input v-model="credentials.email" id="email" type="email" />
        </div>
        <div>
          <label for="password">Senha:</label>
          <input v-model="credentials.password" id="password" type="password" />
        </div>
        <button type="submit">Entrar</button>
      </form>
    </div>
  </template>
  
  <script>
  import api from '../services/api';
  
  export default {
    name: 'UserLogin',
    data() {
      return {
        credentials: {
          email: '',
          password: '',
        },
      };
    },
    methods: {
      async login() {
        try {
          const response = await api.post('/login', this.credentials);
          alert(response.data.message); 
          localStorage.setItem('token', response.data.token); 
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
  