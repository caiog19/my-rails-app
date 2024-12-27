import { createRouter, createWebHistory } from 'vue-router';
import BlogHome from './components/BlogHome.vue';
import UserLogin from './components/UserLogin.vue';
import UserRegister from './components/UserRegister.vue';

const routes = [
  { path: '/', component: BlogHome },
  { path: '/login', component: UserLogin },
  { path: '/register', component: UserRegister },
];


const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
