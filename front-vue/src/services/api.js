import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000', 
  withCredentials: true, 
});

const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
if (csrfToken) {
  api.defaults.headers.common['X-CSRF-Token'] = csrfToken;
}

export default api;
