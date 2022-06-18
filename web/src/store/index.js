import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'
import web3common from "@/service/web3common";

Vue.use(Vuex)

const APP_REG_ADDRESS = "0x18d00909391Ea82fb79ba0f7f049254e89A3b03E";

export default new Vuex.Store({
  plugins: [createPersistedState({
    storage: window.sessionStorage,
  })],
  state: {
    applicationRegistryAddress: APP_REG_ADDRESS,
    currentWalletAddress: null,
  },
  getters: {
  },
  mutations: {
    setCurrentWalletAddress(state, currentWalletAddress) {
      state.currentWalletAddress = currentWalletAddress;
    }
  },
  actions: {
    async refreshWallet(context) {
      let currentWalletAddress = await web3common.getCurrentWalletAddress();
      context.commit("setCurrentWalletAddress", currentWalletAddress);
    }
  },
  modules: {
  }
})
