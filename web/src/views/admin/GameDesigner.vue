<template>
  <b-container>
    <b-row>
      <b-col>
        <div v-if="game == null">
          <div class="my-4">
            <div>Load Game</div>
            <b-form-file
                v-model="selectedFile"
                placeholder="Choose Zip or drop it here..."
                drop-placeholder="Drop Zip here..."
                accept=".zip"
            ></b-form-file>
            <b-button @click="loadGame">Load Game</b-button>
          </div>
          <div class="my-4">
            <b-button @click="newGame">New Game</b-button>
          </div>
        </div>
        <div v-if="game != null">
          <b-button variant="danger" @dblclick="exitGame" class="float-right">Exit Game (double-click)</b-button>
          <div>
            <label>
              Game Name:
              <b-input v-model="game.name" />
            </label>
          </div>
          <div>
            <b-button variant="primary" @click="saveGame">Save to Zip File</b-button>
            <p>
              Remember to save a zip file periodically to avoid losing data.
              This app will auto-save to localStorage, but this isn't reliable.
            </p>
          </div>
          <grid-tiles v-model="game.tiles" />
          <quest-items v-model="game.questItems" />
          <lootboxes v-model="game.lootboxes" />
        </div>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import GridTiles from "@/views/admin/gamedesigner/GridTiles";
import {numToHex, readFileAsBinaryString, readJsonFromZip} from "@/service/utils";
import QuestItems from "@/views/admin/gamedesigner/QuestItems";
import Lootboxes from "@/views/admin/gamedesigner/Lootboxes";
import nodezip from "node-zip";

const GAME_LOCAL_STORAGE_KEY = 'gridgame.admin.gamedesigner.game';

function patchTileData(game) {
  if (!game.tiles) {
    game.tiles = [];
    for (let i = 0; i < 16; i++) {
      game.tiles.push({
        index: i,
        hex: numToHex(i),
        graphic: {}
      });
    }
  }
}

function patchQuestItemData(game) {
  if (!game.questItems) {
    game.questItems = [];
    for (let i = 0; i < 16; i++) {
      game.questItems.push({
        index: i,
        hex: numToHex(i),
        graphic: {}
      });
    }
  }
}

function patchLootboxData(game) {
  if (!game.lootboxes) {
    game.lootboxes = [];
    for (let i = 0; i < 16; i++) {
      game.lootboxes.push({
        index: i,
        hex: numToHex(i),
        graphic: {}
      });
    }
  }
}

function patchMissingGameData(game) {
  if (!game.name) {
    game.name = "Grid Game";
  }
  patchTileData(game);
  patchQuestItemData(game);
  patchLootboxData(game);
  return game;
}

function downloadZipFile(filename, dataBase64) {
  var element = document.createElement('a');
  element.setAttribute('href', 'data:application/zip;base64,' + dataBase64);
  element.setAttribute('download', filename);

  element.style.display = 'none';
  document.body.appendChild(element);

  element.click();

  document.body.removeChild(element);
}

export default {
  name: "GameDesigner",
  components: {Lootboxes, QuestItems, GridTiles},
  data() {
    return {
      game: null,
      selectedFile: null,
    }
  },
  methods: {
    newGame() {
      this.clearGameLocalStorage();
      this.game = patchMissingGameData({});
    },
    exitGame() {
      this.clearGameLocalStorage();
      this.game = null;
    },
    saveGame() {
      let zip = new nodezip();
      zip.file('game', JSON.stringify(this.game));
      let data = zip.generate({base64:true,compression:'DEFLATE'});
      downloadZipFile("game.zip", data);
    },
    loadGame() {
      if (this.selectedFile) {
        readFileAsBinaryString(this.selectedFile).then((result) => {
          let zip = nodezip(result);
          this.game = patchMissingGameData(readJsonFromZip(zip, 'game'));
        });
      }
    },
    clearGameLocalStorage() {
      window.localStorage.setItem(GAME_LOCAL_STORAGE_KEY, null);
    },
    periodicallySaveGameToLocalStorage() {
      window.setTimeout(() => {
        try {
          if (this.game) {
            window.localStorage.setItem(GAME_LOCAL_STORAGE_KEY, JSON.stringify(this.game));
          }
          this.periodicallySaveGameToLocalStorage();
        } catch (e) {
          window.console.log(e);
        }
      }, 5000);
    }
  },
  mounted() {
    if (window.localStorage) {
      let existingGameJson = window.localStorage.getItem(GAME_LOCAL_STORAGE_KEY);
      if (existingGameJson && existingGameJson !== "null") {
        this.game = patchMissingGameData(JSON.parse(existingGameJson));
      }
      this.periodicallySaveGameToLocalStorage();
    }
  }
}
</script>

<style scoped>

</style>