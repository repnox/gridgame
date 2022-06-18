<template>
  <b-container>

  </b-container>
</template>

<script>


import web3common from "../../service/web3common";

export default {
  name: "InspectApplicationRegistry",
  data() {
    return {
    }
  },
  methods: {
  },
  async mounted() {
    await web3common.getApplicationRegistry();
  }
}
</script>

<style scoped>

</style>