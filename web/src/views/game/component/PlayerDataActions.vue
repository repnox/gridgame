<template>
  <div class="playerData">
    <div>Player: {{player.displayName}} ({{player.location.x}},{{player.location.y}})</div>
    <div>Travel Stat: {{player.stats.travel}}</div>
    <div v-if="!isShowingItems">
      <b-button size="sm" class="mb-2" @click="onShowItemsClick()">
        <font-awesome-icon icon="plus" /> Items
      </b-button>
    </div>
    <div class="inlineItemList" v-if="isShowingItems">
      <div v-for="item of items" :key="item.index">
        <player-item :player-id="player.id" :index="item.index" />
      </div>
    </div>
    <div>Actions:</div>
    <div v-if="player.owner === $store.state.currentWalletAddress">
      <b-button class="m-2" variant="secondary" @click="onPlayerTravelClick()">Travel</b-button>
      <div v-if="isGenerateLootboxActionAvailable">
        <b-button class="m-2" variant="secondary" @click="onPlayerGenerateLootboxClick()">Generate Lootbox</b-button>
      </div>
      <div v-if="isMintMcguffinActionAvailable">
        <b-button class="m-2" variant="secondary" @click="onPlayerMintMcguffinClick()">Accept Item</b-button>
      </div>
      <div v-if="isCompleteFetchQuestActionAvailable">
        <b-button class="m-2" variant="secondary" @click="onPlayerCompleteFetchQuestClick()">Complete Fetch Quest</b-button>
      </div>
    </div>
  </div>
</template>

<script>
import eventBus from "@/service/eventBus";
import gameView from "@/service/gameView";
import tileActions from "@/service/tileActions";
import PlayerItem from "@/views/game/component/PlayerItem";

export default {
  components: {PlayerItem},
  props: {
    player: Object
  },
  data() {
    return {
      isGenerateLootboxActionAvailable: false,
      isMintMcguffinActionAvailable: false,
      isCompleteFetchQuestActionAvailable: false,
      isShowingItems: false,
      items: []
    }
  },
  methods: {
    async onShowItemsClick() {
      this.isShowingItems = true;
      let itemCount = await gameView.getPlayerItemCount(this.player.id);
      this.items = [];
      for (let i=0; i<itemCount; i++) {
        this.items.push({
          index: i
        });
      }
    },
    async onPlayerTravelClick() {
      eventBus.$emit("PLAYER_TRAVEL_START", this.player);
    },
    async onPlayerGenerateLootboxClick() {
      eventBus.$emit("PLAYER_TILE_ACTION_GENERATE_LOOTBOX", this.player);
    },
    async onPlayerMintMcguffinClick() {
      eventBus.$emit("PLAYER_TILE_ACTION_MINT_MCGUFFIN", this.player);
    },
    async onPlayerCompleteFetchQuestClick() {
      eventBus.$emit("PLAYER_TILE_ACTION_COMPLETE_FETCH_QUEST", this.player);
    },
  },
  async mounted() {
    this.isGenerateLootboxActionAvailable = await tileActions.isGenerateLootboxActionAvailable(this.player.location.x, this.player.location.y);
    this.isMintMcguffinActionAvailable = await tileActions.isMintMcguffinActionAvailable(this.player.location.x, this.player.location.y);
    this.isCompleteFetchQuestActionAvailable = await tileActions.isCompleteFetchQuestActionAvailable(this.player.location.x, this.player.location.y);
  }
}
</script>

<style scoped>
.playerData {
  margin: 10px;
  padding: 10px;
  border: 1px solid black;
}
.inlineItemList {
  max-height: 500px;
  overflow-y: auto;
}
</style>