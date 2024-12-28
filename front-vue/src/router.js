import { createRouter, createWebHistory } from 'vue-router';
import BlogHome from './components/BlogHome.vue';
import UserLogin from './components/UserLogin.vue';
import UserRegister from './components/UserRegister.vue';
import UserPosts from './components/UserPosts.vue';
import PasswordResetRequest from './components/PasswordResetRequest.vue';
import PasswordReset from './components/PassWordReset.vue';

const routes = [
  { path: '/', component: BlogHome },
  { path: '/login', component: UserLogin },
  { path: '/register', component: UserRegister },
  {
    path: '/meus-posts',
    name: 'UserPosts',
    component: UserPosts,
    meta: { requiresAuth: true },
  },
  { path: '/esqueci-minha-senha', component: PasswordResetRequest },
  { path: '/password_resets/:token', component: PasswordReset }, // Rota para redefinir a senha
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  if (to.meta.requiresAuth && !token) {
    alert('Você precisa estar logado para acessar esta página.');
    next({ name: 'Login' });
  } else {
    next();
  }
});

export default router;
