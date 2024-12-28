<template>
  <div id="app">
    <nav>
      <ul>
        <li><router-link to="/">Home</router-link></li>
        <li><router-link to="/login">Login</router-link></li>
        <li><router-link to="/register">Cadastrar</router-link></li>
        <li v-if="eventBus.isAuthenticated"><router-link to="/meus-posts">Meus Posts</router-link></li>
      </ul>
    </nav>
    <router-view />
  </div>
</template>

<script>
import { eventBus } from './eventBus';

export default {
  name: 'App',
  setup() {
    return {
      eventBus,
    };
  },
};
</script>
