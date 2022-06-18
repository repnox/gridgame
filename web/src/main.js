import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import { BootstrapVue } from 'bootstrap-vue'

import "./style/bootstrap-custom.scss";
import { library } from '@fortawesome/fontawesome-svg-core'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'


import {
  faExclamationTriangle,
  faSpinner,
  faPlus,
  faCheckCircle,
} from "@fortawesome/free-solid-svg-icons";

library.add(faExclamationTriangle);
library.add(faSpinner);
library.add(faPlus);
library.add(faCheckCircle);

Vue.use(BootstrapVue);
Vue.component('font-awesome-icon', FontAwesomeIcon);

Vue.config.productionTip = false

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
