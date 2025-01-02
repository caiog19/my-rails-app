<template>
  <div id="app">
    <nav class="navbar">
      <div class="navbar-left">
        <span class="navbar-title">Navega Mainô</span>
      </div>
      
      <div class="navbar-center">
        <ul class="navbar-list">
          <li class="navbar-item">
            <router-link class="navbar-link" to="/">Home</router-link>
          </li>
          <li class="navbar-item" v-if="!eventBus.isAuthenticated">
            <router-link class="navbar-link" to="/login">Login</router-link>
          </li>
          <li class="navbar-item" v-if="!eventBus.isAuthenticated">
            <router-link class="navbar-link" to="/register">Cadastrar</router-link>
          </li>
          <li class="navbar-item" v-if="eventBus.isAuthenticated">
            <router-link class="navbar-link" to="/meus-posts">Meus Posts</router-link>
          </li>
        </ul>
      </div>
      
      <div class="navbar-right">
        <button
          v-if="eventBus.isAuthenticated"
          @click="logout"
          class="logout-button"
          aria-label="Logout"
        >
          Sair
        </button>
      </div>
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
    const logout = () => {
      localStorage.removeItem('token');
      eventBus.isAuthenticated = false;
      window.location.href = '/login';
      alert('Você foi deslogado com sucesso.');
    };

    return {
      eventBus,
      logout,
    };
  },
};
</script>
