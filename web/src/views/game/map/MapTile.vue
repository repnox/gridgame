<template>
  <g>
    <defs>
      <linearGradient id="loadingGradient">
        <stop offset="0%"   stop-color="black" />
        <stop offset="25%"   stop-color="black" />
        <stop offset="75%" stop-color="rgba(0,0,0,0)" />
        <stop offset="100%" stop-color="rgba(0,0,0,0)" />
      </linearGradient>
    </defs>
    <rect :x="renderX" :y="renderY" :width="renderWidth" :height="renderHeight" :style="'fill:'+fillColor+';stroke:rgb(0,0,0)'" />
    <text :x="renderX" :y="renderY + renderHeight - 7">
      {{tileText}}
    </text>
    <text v-if="hash !== '0x00'" :x="renderX" :y="renderY + 17">
      {{tileCode}}
    </text>
    <rect class="selectedOverlay" v-if="isSelected" :x="renderX" :y="renderY" :width="renderWidth-1" :height="renderHeight-1" />
    <rect class="hoverOverlay" @mouseover="onHoverTile" @click="onClickTile" :x="renderX" :y="renderY" :width="renderWidth-1" :height="renderHeight-1" />
    <circle
        v-if="isLoading"
        :cx="tileCenterX" :cy="tileCenterY" :r="renderWidth/3" stroke-width="10"
        fill="none" stroke="url(#loadingGradient)"
      >
      <animateTransform attributeName="transform"
                        attributeType="XML"
                        type="rotate"
                        :from="`0 ${tileCenterX} ${tileCenterY}`"
                        :to="`360 ${tileCenterX} ${tileCenterY}`"
                        dur="2s"
                        repeatCount="indefinite"/>
    </circle>
  </g>
</template>

<script>
import eventBus from "@/service/eventBus";
import gameView from "@/service/gameView";
import dataCommon from "@/service/dataCommon";
import metaRef from "@/ref/metaRef";

export default {
  props: {
    x: Number,
    y: Number,
    renderX: Number,
    renderY: Number,
    renderWidth: Number,
    renderHeight: Number,
    selectedTile: Object
  },
  data() {
    return {
      isLoading: true,
      hash: "",
      playerIds: [],
    }
  },
  methods: {
    onClickTile() {
      eventBus.$emit("TILE_CLICKED", this.x, this.y);
    },
    onHoverTile() {
      eventBus.$emit("TILE_HOVER", this.x, this.y);
    },
    async refresh() {
      this.isLoading = true;
      this.playerIds = [];
      this.hash = await gameView.getGridHash(this.x, this.y);
      if (this.hash && this.hash !== "0x00") {
        this.playerIds = await gameView.getPlayerIdsAt(this.x, this.y);
      }
      this.isLoading = false;
    }
  },
  computed: {
    fillColor() {
      if (!this.hash || this.hash === "0x00") {
        return "rgb(100,100,100)";
      } else {
        return metaRef.tiles.types[dataCommon.getTileType(this.hash)].color;
      }
    },
    tileCode() {
      if (!this.hash || this.hash === "0x00") {
        return "-";
      } else {
        return this.hash.substring(this.hash.length-1);
      }
    },
    tileText() {
      if (this.playerIds.length === 1) {
        return "1 Player";
      } else if (this.playerIds.length > 1) {
        return this.playerIds.length + " Players";
      } else {
        return "";
      }
    },
    isSelected() {
      return this.selectedTile.isActive && this.selectedTile.x === this.x && this.selectedTile.y === this.y;
    },
    tileCenterX() {
      return this.renderX + this.renderWidth/2;
    },
    tileCenterY() {
      return this.renderY + this.renderHeight/2;
    }
  },
  async mounted() {
    await this.refresh();

    eventBus.$on(`TILE_REFRESH_${this.x}_${this.y}`, async () => {
      await this.refresh();
    });
  }
}
</script>

<style scoped>
text {
  user-select: none;
}
.hoverOverlay {
  fill: rgb(255,255,255);
  opacity: 0;
}
.hoverOverlay:hover {
  opacity: .2;
}
.selectedOverlay {
  fill: rgb(255,255,255);
  stroke: rgb(255, 255, 255);
  stroke-width: 2px;
  fill-opacity: .2;
}
.clickOverlay {
  fill: rgb(255,255,255);
  opacity: 0;
}
</style>