<template>
  <div class="itemIcon">
    <img :src="url" />
  </div>
</template>

<script>
export default {
  props: {
    url: String
  },
}
</script>

<style scoped>
.itemIcon {
  display: inline-block;
  padding: 5px;
  margin: 5px;
  border: 1px solid black;
  width: 100px;
  height: 100px;
}
img {
  width: 90px;
  height: 90px;
}
</style>
