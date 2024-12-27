import { createRouter, createWebHistory } from 'vue-router';
import BlogHome from './components/BlogHome.vue';
import UserLogin from './components/UserLogin.vue';
import UserRegister from './components/UserRegister.vue';
import UserPosts from './components/UserPosts.vue';
const routes = [
  { path: '/', component: BlogHome },
  { path: '/login', component: UserLogin, name: 'Login' },
  { path: '/register', component: UserRegister },
  {
    path: '/meus-posts',
    name: 'UserPosts',
    component: UserPosts,
    meta: { requiresAuth: true }, 
  },
];


const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  console.log(`Tentando acessar: ${to.path}`);
  console.log(`Token presente: ${!!token}`);

  if (to.meta.requiresAuth && !token) {
    alert('Você precisa estar logado para acessar esta página.');
    next({ name: 'Login' }); // Certifique-se de que a rota 'Login' está nomeada
  } else {
    next(); 
  }
});



export default router;
