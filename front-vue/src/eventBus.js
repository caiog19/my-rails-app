import { reactive } from 'vue';

export const eventBus = reactive({
  isAuthenticated: !!localStorage.getItem('token'),
  updateAuthentication(isAuthenticated) {
    this.isAuthenticated = isAuthenticated;
  },
});
