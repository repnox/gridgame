<template>
  <div>
    <b-button v-b-toggle.grid-tiles-collapse variant="link"><font-awesome-icon icon="chevron-down"/> Grid Tiles</b-button>
    <b-collapse id="grid-tiles-collapse" class="mt-2">
      <b-card>
        <b-button v-b-toggle.grid-tiles-collapse size="sm" style="float:right">X</b-button>
        <div class="card-text">
          <h1>Grid Tiles</h1>
          <div class="d-flex flex-row flex-wrap">
            <div v-for="tile in value" :key="tile.index">
              <div class="tile-graphic" @click="openGraphicModal(tile)">
                <default-graphic-svg v-if="!tile.graphic.data" :value="tile" />
                <graphic v-if="tile.graphic.data" :value="tile.graphic" overflow="visible" />
              </div>
            </div>
          </div>
        </div>
      </b-card>
    </b-collapse>
    <b-modal ref="modal" :title="'Edit Tile ' + selectedTile.hex" size="xl" hide-footer>
      <graphic-editor v-model="selectedTile.graphic" @input="closeGraphicModal" />
    </b-modal>
  </div>
</template>

<script>
import DefaultGraphicSvg from "@/views/admin/gamedesigner/DefaultGraphicSvg";
import GraphicEditor from "@/views/admin/gamedesigner/GraphicEditor";
import Graphic from "@/views/game/component/Graphic";
export default {
  name: "GridTiles",
  components: {Graphic, GraphicEditor, DefaultGraphicSvg},
  props: {
    value: {
      type: Array
    },
  },
  data() {
    return {
      selectedTile: {
        hex: null
      },
    }
  },
  methods: {
    openGraphicModal(tile) {
      this.selectedTile = tile;
      this.$refs.modal.show();
    },
    closeGraphicModal() {
      this.$refs.modal.hide();
    }
  }
}
</script>

<style scoped>
.tile-graphic {
  width: 100px;
  height: 100px;
  margin: 10px;
  display: inline-block;
  cursor: pointer;
  user-select: none;
}
</style>