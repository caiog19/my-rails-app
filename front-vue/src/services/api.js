import axios from 'axios';

const api = axios.create({
  baseURL: 'https://my-rails-app-r7us.onrender.com', 
  withCredentials: true,
});

const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
if (csrfToken) {
  api.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

export default api;
