<template>
  <div class="text-center">
    <svg viewBox="0 0 1000 1000" style="max-height: 100vh">
      <g v-for="tile in visibleTiles" :key="tile.key">
        <map-tile
            v-if="isLoaded"
            :x="tile.x"
            :y="tile.y"
            :render-x="tile.renderX"
            :render-y="tile.renderY"
            :render-width="tile.renderWidth"
            :render-height="tile.renderHeight"
            :selected-tile="selectedTile"
          />
      </g>
    </svg>
  </div>
</template>

<script>
import gameView from "@/service/gameView";
import MapTile from "@/views/game/map/MapTile";

export default {
  components: {MapTile},
  props: {
    selectedTile: Object
  },
  data() {
    return {
      isLoaded: false,
      mapBounds: {
        minX: 0,
        minY: 0,
        maxX: 0,
        maxY: 0
      },
    }
  },
  computed: {
    visibleTiles() {
      let visibleTiles = [];
      let mapWidth = this.mapBounds.maxX - this.mapBounds.minX;
      let mapHeight = this.mapBounds.maxY - this.mapBounds.minY;
      let renderWidth = 1000 / mapWidth;
      let renderHeight = 1000 / mapHeight;
      let renderY = 0;
      for (let y = this.mapBounds.minY; y < this.mapBounds.maxY; y++) {
        let renderX = 0;
        for (let x = this.mapBounds.minX; x < this.mapBounds.maxX; x++) {
          visibleTiles.push({
            x,
            y,
            renderWidth,
            renderHeight,
            renderX,
            renderY,
          });
          renderX += renderWidth;
        }
        renderY += renderHeight;
      }
      return visibleTiles;
    }
  },
  mounted() {
    this.refreshData();
  },
  methods: {
    async refreshData() {
      this.mapBounds = await gameView.getMapBounds();
      this.isLoaded = true;
    }
  }

}
</script>

<style scoped>
  svg text {
    font: 18px sans-serif;
  }
</style>