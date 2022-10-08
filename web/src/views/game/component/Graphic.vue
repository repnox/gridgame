<template>
  <div class="graphic-container" :style="containerStyle">
    <div class="graphic-background" :style="backgroundStyle"></div>
    <img :alt="value.alt" :src="imgSrc" :style="graphicStyle" class="graphic" />
  </div>
</template>

<script>
export default {
  name: "Graphic",
  props: {
    value: {
      type: Object
    },
    size: {
      type: Number,
      default: 100
    },
    overflow: {
      type: String,
      default: "hidden"
    }
  },
  computed: {
    imgSrc() {
      return "data:image/svg+xml,"+encodeURIComponent(this.value.data);
    },
    containerStyle() {
      return {
        width: this.size + "px",
        height: this.size + "px",
        overflow: this.overflow
      }
    },
    backgroundStyle() {
      return {
        width: this.size + "px",
        height: this.size + "px",
        'background-color': this.value.backgroundColor,
      }
    },
    graphicStyle() {
      return {
        left: this.value.offsetX + "px",
        top: this.value.offsetY + "px",
        width: this.size * this.value.scale + "px",
        height: this.size * this.value.scale + "px"
      }
    }
  }
}
</script>

<style scoped>
.graphic-container {
  position: relative;
}
.graphic {
  position: absolute;
}
.graphic-background {
  position: absolute;
}
</style>