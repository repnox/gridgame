<template>
  <b-container fluid>
    <b-row>
      <b-col cols="3">
        <div>
          <div class="m-4">
            <b-button variant="primary" @click="createPlayer()">Create Player</b-button>
          </div>
          <div v-for="player in ownedPlayers" :key="player.id">
            <player-data-actions
                :player="player"
              />
          </div>
        </div>
      </b-col>
      <b-col cols="6">
        <Map :selected-tile="selectedTile" />
      </b-col>
      <b-col cols="3">
        <div v-if="mode === ''">
          <div v-if="selectedTile.isActive && selectedTileDetails.hash">
            <div>Tile ({{selectedTile.x}}, {{selectedTile.y}})</div>
            <div>Hash: {{selectedTileDetails.displayName}}</div>
            <div v-if="selectedTileDetails">
              <div v-for="player in selectedTileDetails.players" :key="player.id">
                <player-data-actions
                    :player="player"
                />
              </div>
            </div>
          </div>
        </div>
        <div v-if="mode === 'travel'">
          <h1 class="my-4">Travel</h1>
          <div>
            Player: {{selectedTileDetails.displayName}}
          </div>
          <div class="my-4">
            From:
            ({{selectedTile.x}}, {{selectedTile.y}})
            To:
            <span v-if="hoverTile.isActive">
              ({{hoverTile.x}}, {{hoverTile.y}})
            </span>
            <span v-if="!hoverTile.isActive">
              ?
            </span>
          </div>
          <p>
            Click the destination tile.
          </p>
          <div class="my-4">
            <b-button variant="secondary" @click="cancelAction()">Cancel</b-button>
          </div>
          <b-alert variant="info" :show="!!travelAction.message">
            {{travelAction.message}}
          </b-alert>
          <b-alert variant="danger" :show="!!travelAction.error">
            {{travelAction.error}}
          </b-alert>
        </div>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import playerActions from "../../service/playerActions";
import tileActions from "../../service/tileActions";
import gameView from "../../service/gameView";
import Map from "./map/Map";
import eventBus from "@/service/eventBus";
import PlayerDataActions from "@/views/game/component/PlayerDataActions";

const MODE_DEFAULT = "";
const MODE_TRAVEL = "travel";

export default {
  components: {PlayerDataActions, Map},
  props: {
  },
  data() {
    return {
      mode: MODE_DEFAULT,
      ownedPlayers: [],
      travelAction: {
        player: {},
        message: "",
        error: "",
      },
      selectedTile: {
        isActive: false,
        x: 0,
        y: 0,
      },
      hoverTile: {
        isActive: false,
        x: 0,
        y: 0,
      },
      selectedTileDetails: {
        hash: "",
        displayName: "",
        players: [],
      }
    }
  },
  computed: {
  },
  watch: {
    async selectedTile() {
      await this.refreshSelectedTileDetails();
    }
  },
  methods: {
    async createPlayer() {
      await playerActions.createPlayer();
    },
    async cancelAction() {
      this.mode = MODE_DEFAULT;
    },
    async onPlayerTravelStart(player) {
      this.mode = MODE_TRAVEL;
      this.selectedTile = {
        isActive: true,
        x: player.location.x,
        y: player.location.y,
      };
      this.travelAction = {
        player,
        error: "",
        message: "",
      };
    },
    async onPlayerActionGenerateLootbox(player) {
      await tileActions.tileActionGenerateLootbox(player.id);
    },
    async onPlayerActionMintMcguffin(player) {
      await tileActions.tileActionMintMcguffin(player.id);
    },
    async onTileHover(x, y) {
      this.hoverTile = {
        isActive: true,
        x,
        y
      };
      this.travelAction.error = "";
      this.travelAction.message = "";
      window.setTimeout(async () => {
        let hoverChanged = () => x !== this.hoverTile.x || y !== this.hoverTile.y;
        if (this.mode === MODE_TRAVEL) {
          if (hoverChanged()) {
            return;
          }
          try {
            await playerActions.estimateMovePlayer(this.travelAction.player.id, x, y);
            if (hoverChanged()) {
              return;
            }
            this.setTravelMessage("Click to travel!");
          } catch (e) {
            if (hoverChanged()) {
              return;
            }
            window.console.log(e);
            let errorMessage = e.error && e.error.message === "execution reverted: Too far";
            let dataMessage = e.data && e.data.message === "execution reverted: Too far";
            if (errorMessage || dataMessage) {
              this.setTravelError("Too Far! Travel stat not high enough.");
            } else {
              this.setTravelError("Unexpected error!");
            }
          }
        }
      }, 100);
    },
    async onTileClick(x,y) {
      if (this.mode === MODE_TRAVEL) {
        if (!this.travelAction.error) {
          try {
            await this.cancelAction();
            await this.movePlayer(this.travelAction.player.id, x, y);
          } catch (e) {
          }
        }
      } else {
        eventBus.$emit(`TILE_REFRESH_${x}_${y}`);
        this.selectedTile = {
          isActive: true,
          x,
          y
        };
      }
    },
    async refreshSelectedTileDetails() {
      this.selectedTileDetails = {};
      if (this.selectedTile.isActive) {
        let gridhash = await gameView.getGridHash(this.selectedTile.x, this.selectedTile.y);
        this.selectedTileDetails = {
          hash: gridhash,
          displayName: gridhash === "0x00" ? "Undiscovered" : gridhash.substring(gridhash.length-1),
          players: await gameView.getPlayersAt(this.selectedTile.x, this.selectedTile.y),
        };
      }
    },
    async movePlayer(id, x, y) {
      await playerActions.movePlayer(id, x, y);
    },
    async refreshData() {
      this.ownedPlayers = await gameView.getOwnedPlayerData();
      await this.$store.dispatch("refreshWallet");
    },
    setTravelMessage(message) {
      this.travelAction.message = message;
      this.travelAction.error = "";
    },
    setTravelError(error) {
      this.travelAction.message = "";
      this.travelAction.error = error;
    },
  },
  beforeMount() {
    this.refreshData();
  },
  mounted() {
    eventBus.$on("PLAYER_TRAVEL_START", async (player) => {
      await this.onPlayerTravelStart(player);
    });

    eventBus.$on("PLAYER_TILE_ACTION_GENERATE_LOOTBOX", async (player) => {
      await this.onPlayerActionGenerateLootbox(player);
    });

    eventBus.$on("PLAYER_TILE_ACTION_MINT_MCGUFFIN", async (player) => {
      await this.onPlayerActionMintMcguffin(player);
    });

    eventBus.$on("TILE_CLICKED", async (x, y) => {
      await this.onTileClick(x,y);
    });

    eventBus.$on("TILE_HOVER", async (x, y) => {
      await this.onTileHover(x,y);
    });
  },
  beforeDestroy() {
    eventBus.$off("PLAYER_TRAVEL_START");
    eventBus.$off("PLAYER_TILE_ACTION_GENERATE_LOOTBOX");
    eventBus.$off("PLAYER_TILE_ACTION_MINT_MCGUFFIN");
    eventBus.$off("TILE_CLICKED");
    eventBus.$off("TILE_HOVER");
  }

}
</script>

<style scoped>
  .playerData {
    margin: 10px;
    padding: 10px;
    border: 1px solid black;
  }
</style>