import Vue from 'vue'
import VueRouter from 'vue-router'
import routes from "./routes";

Vue.use(VueRouter)

const router = new VueRouter({
//  mode: 'history', // Not supported on GCP, no ability to add rewrite rules
  base: process.env.BASE_URL,
  routes,
  scrollBehavior (to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    } else {
      return { x: 0, y: 0 }
    }
  }
})

export default router
