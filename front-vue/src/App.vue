<template>
  <div id="app">
    <nav class="navbar">
      <span class="navbar-title">Navega Mainô</span>
      
      <ul class="navbar-list">
        <li class="navbar-item">
          <router-link class="navbar-link" to="/">Home</router-link>
        </li>
        <li class="navbar-item">
          <router-link class="navbar-link" to="/login">Login</router-link>
        </li>
        <li class="navbar-item">
          <router-link class="navbar-link" to="/register">Cadastrar</router-link>
        </li>
        <li class="navbar-item" v-if="eventBus.isAuthenticated">
          <router-link class="navbar-link" to="/meus-posts">Meus Posts</router-link>
        </li>
      </ul>
      
      <button
        v-if="eventBus.isAuthenticated"
        @click="logout"
        class="logout-button"
        aria-label="Logout"
      >
        Sair
      </button>
    </nav>
    
    <router-view />
  </div>
</template>

<script>
import { eventBus } from './eventBus';
import '../src/styles/BlogApp.css';

export default {
  name: 'App',
  setup() {
    // Método de Logout
    const logout = () => {
      // Remover o token de autenticação
      localStorage.removeItem('token');
      
      // Atualizar o estado de autenticação
      eventBus.isAuthenticated = false;
      
      // Redirecionar para a página de login
      window.location.href = '/login';
      
      // Opcional: Exibir uma mensagem de confirmação
      alert('Você foi deslogado com sucesso.');
    };

    return {
      eventBus,
      logout,
    };
  },
};
</script>
