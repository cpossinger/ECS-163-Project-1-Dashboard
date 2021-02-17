import Vue from 'vue'
import App from './App.vue'
import vuetify from './plugins/vuetify';
import * as uid from "./plugins/uid"
Vue.use(uid);

new Vue({
  vuetify,
  render: h => h(App)
}).$mount('#app')
