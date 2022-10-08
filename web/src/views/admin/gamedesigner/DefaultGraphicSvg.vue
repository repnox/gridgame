<template>
  <svg width="100" height="100">
    <rect width="100" height="100" style="fill:rgb(0,0,255);stroke-width:1;stroke:rgb(0,0,0)" />
    <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="white">{{value.hex}}</text>
  </svg>
</template>

<script>
export default {
  name: "DefaultTileGraphicSvg",
  props: {
    value: {
      type: Object
    }
  },
  methods: {
  }
}
</script>

<style scoped>

</style>