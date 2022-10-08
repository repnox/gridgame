<template>
  <div>
    <b-button v-b-toggle.lootboxes-collapse variant="link"><font-awesome-icon icon="chevron-down"/> Lootboxes</b-button>
    <b-collapse id="lootboxes-collapse" class="mt-2">
      <b-card>
        <b-button v-b-toggle.lootboxes-collapse size="sm" style="float:right">X</b-button>
        <div class="card-text">
          <h1>Lootboxes</h1>
          <div class="d-flex flex-row flex-wrap">
            <div v-for="item in value" :key="item.index">
              <div class="item-graphic" @click="openGraphicModal(item)">
                <default-graphic-svg v-if="!item.graphic.data" :value="item" />
                <graphic v-if="item.graphic.data" :value="item.graphic" />
              </div>
            </div>
          </div>
        </div>
      </b-card>
    </b-collapse>
    <b-modal ref="modal" :title="'Edit Lootbox ' + selectedItem.hex" size="xl" hide-footer>
      <graphic-editor v-model="selectedItem.graphic" @input="closeGraphicModal" />
    </b-modal>
  </div>
</template>

<script>
import DefaultGraphicSvg from "@/views/admin/gamedesigner/DefaultGraphicSvg";
import GraphicEditor from "@/views/admin/gamedesigner/GraphicEditor";
import Graphic from "@/views/game/component/Graphic";
export default {
  name: "Lootboxes",
  components: {Graphic, GraphicEditor, DefaultGraphicSvg},
  props: {
    value: {
      type: Array
    },
  },
  data() {
    return {
      selectedItem: {
        hex: null
      },
    }
  },
  methods: {
    openGraphicModal(tile) {
      this.selectedItem = tile;
      this.$refs.modal.show();
    },
    closeGraphicModal() {
      this.$refs.modal.hide();
    }
  }
}
</script>

<style scoped>
.item-graphic {
  width: 100px;
  height: 100px;
  margin: 10px;
  display: inline-block;
  cursor: pointer;
  user-select: none;
}
</style>