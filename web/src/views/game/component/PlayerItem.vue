<template>
  <div>
    <div v-if="!loaded">
      <font-awesome-icon icon="spinner" spin />
    </div>
    <div v-if="loaded">
      <item-icon :url="iconUrl" />
      {{itemName}}
    </div>
  </div>
</template>

<script>
import gameView from "@/service/gameView";
import {FontAwesomeIcon} from "@fortawesome/vue-fontawesome";
import dataCommon from "@/service/dataCommon";
import artRef from "@/ref/metaRef";
import itemIcon from "@/views/game/component/ItemIcon";

export default {
  name: "PlayerItem.vue",
  components: {FontAwesomeIcon, itemIcon},
  props: {
    playerId: String,
    index: Number,
  },
  data() {
    return {
      loaded: false,
      itemId: null,
    }
  },
  computed: {
    itemType() {
      return dataCommon.getItemType(this.itemId);
    },
    itemSubtype() {
      return dataCommon.getItemSubtype(this.itemId);
    },
    iconUrl() {
      return artRef.items.types[this.itemType].subtypes[this.itemSubtype].iconUrl;
    },
    itemName() {
      return artRef.items.types[this.itemType].subtypes[this.itemSubtype].name;
    }
  },
  async mounted() {
    this.itemId = await gameView.getPlayerItemByIndex(this.playerId, this.index);
    this.loaded = true;
  }
}
</script>

<style scoped>

</style>