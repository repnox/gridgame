<template>
  <b-container class="full-height">
    <b-row class="mt-4">
      <b-col>
        <b-button size="large" variant="primary" @click="mintNft()">Mint NFT</b-button>
      </b-col>
    </b-row>
    <b-row class="mt-4" v-if="isLoading">
      <b-col>
        <font-awesome-icon icon="spinner" :spin="true" />
      </b-col>
    </b-row>
    <b-row class="mt-4" v-if="error">
      <b-col>
        <p class="text-danger">{{error}}</p>
      </b-col>
    </b-row>
    <b-row class="mt-4" v-if="successMessage">
      <b-col>
        <p class="text-success" v-html="successMessage"></p>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import web3common from "../../service/web3common";

export default {
  name: "MintNFT",
  data() {
    return {
      contractAddress: null,
      error: null,
      successMessage: null,
      isLoading: null,
    }
  },
  methods: {
    async mintNft() {
      try {
        this.isLoading = true;
        const contract = await web3common.getPipeNftContract();
        const tx = await contract.mintTo(this.$store.state.walletAddress);
        const result = await tx.wait();
        console.log(result);
        let message = "Transaction Hash: "+result.transactionHash;
        message += "<br /> From: "+result.from;
        message += "<br /> To: "+result.to;
        message += "<br /> Mint #"+result.events[0].args['tokenId'];
        this.successMessage = message;
      } catch (err) {
        this.error = err;
      }
      this.isLoading = false;
    }
  }
}
</script>

<style scoped>

</style>