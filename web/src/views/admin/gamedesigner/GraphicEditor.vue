<template>
  <div>
    <div v-if="!value.data">
      <p>No graphic defined.</p>
    </div>
    <b-form-file
        v-model="selectedFile"
        placeholder="Choose SVG or drop it here..."
        drop-placeholder="Drop SVG here..."
        accept=".svg"
    ></b-form-file>
    <div v-if="editedGraphic">
      <div class="graphic-editor-container" @mousedown.stop="graphicDragStart($event)" @mousemove.stop="graphicDragMove($event)" @mouseup.stop="graphicDragStop($event)">
        <div class="graphic-editor-background">
          <svg width="500" height="500">
            <rect width="500" height="500" :style="{fill:editedGraphic.backgroundColor}" />
          </svg>
        </div>
        <img class="graphic-editor-graphic" :style="editedGraphicStyle" :src="editedGraphicImgSrc" />
        <div class="graphic-editor-overlay">
          <svg width="500" height="500">
            <line x1="200" y1="0" x2="200" y2="500" style="stroke:rgb(255,0,0);stroke-width:1" />
            <line x1="300" y1="0" x2="300" y2="500" style="stroke:rgb(255,0,0);stroke-width:1" />
            <line x1="0" y1="200" x2="500" y2="200" style="stroke:rgb(255,0,0);stroke-width:1" />
            <line x1="0" y1="300" x2="500" y2="300" style="stroke:rgb(255,0,0);stroke-width:1" />

            <line x1="250" y1="0" x2="250" y2="500" style="stroke:rgb(0,0,0);stroke-width:1;stroke-opacity:0.25" />
            <line x1="0" y1="250" x2="500" y2="250" style="stroke:rgb(0,0,0);stroke-width:1;stroke-opacity:0.25" />
          </svg>
        </div>
      </div>
      <div>
        Click and drag to align.
        <br />
        Shift+drag to scale.
      </div>
      <div>
        <label>
          Name, Alt Text:
          <b-input v-model="editedGraphic.alt" />
        </label>
      </div>
      <div>
        <label>
          Background Color:
          <b-input v-model="editedGraphic.backgroundColor" />
        </label>
      </div>
      <div>
        <b-button variant="primary" @click="saveGraphic">Save</b-button>
      </div>
    </div>
  </div>
</template>

<script>
import {readFileAsBinaryString} from "@/service/utils";

export default {
  name: "GraphicEditor",
  props: {
    value: {
      type: Object
    }
  },
  data() {
    return {
      selectedFile: null,
      editedGraphic: null,
      dragState: null,
    }
  },
  methods: {
    saveGraphic() {
      this.$emit("input", this.editedGraphic);
    },
    graphicDragStart(ev) {
      document.activeElement.blur();
      this.dragState = {
        mouse: {
          startX: ev.pageX,
          startY: ev.pageY,
          endX: ev.pageX,
          endY: ev.pageY
        },
        graphic: {
          startX: this.editedGraphic.offsetX,
          startY: this.editedGraphic.offsetY,
          startScale: this.editedGraphic.scale,
        }
      }
      if (ev.shiftKey) {
        this.dragState.action = 'scale';
      } else {
        this.dragState.action = 'translate';
      }
    },
    graphicDragMove(ev) {
      if (this.dragState) {
        this.dragState.mouse.endX = ev.pageX;
        this.dragState.mouse.endY = ev.pageY;
        let dx = this.dragState.mouse.endX - this.dragState.mouse.startX;
        let dy = this.dragState.mouse.endY - this.dragState.mouse.startY;
        if (this.dragState.action === 'translate') {
          this.editedGraphic.offsetX = dx + this.dragState.graphic.startX;
          this.editedGraphic.offsetY = dy + this.dragState.graphic.startY;
        } else if (this.dragState.action === 'scale') {
          let sign = (dx+dy) < 0 ? -1 : 1;
          let d = sign * Math.sqrt(dx*dx + dy*dy);
          let ds = d / 100;
          this.editedGraphic.scale = ds + this.dragState.graphic.startScale;
          if (this.editedGraphic.scale < .1) {
            this.editedGraphic.scale = .1;
          }
        }
      }
    },
    graphicDragStop(ev) {
      this.dragState = null;
    }
  },
  computed: {
    editedGraphicStyle() {
      return {
        top: 200 + this.editedGraphic.offsetY + 'px',
        left: 200 + this.editedGraphic.offsetX + 'px',
        width: 100 * this.editedGraphic.scale + 'px',
        height: 100 * this.editedGraphic.scale + 'px',
      }
    },
    editedGraphicImgSrc() {
      return "data:image/svg+xml,"+encodeURIComponent(this.editedGraphic.data);
    }
  },
  watch: {
    value(graphic) {
      if (graphic.data) {
        this.editedGraphic = graphic;
      }
    },
    selectedFile(selectedFile) {
      readFileAsBinaryString(selectedFile).then((result) => {
        this.editedGraphic = {
          data: result,
          type: "svg",
          offsetX: 0,
          offsetY: 0,
          scale: 1,
          alt: "",
          backgroundColor: "transparent",
        }
      });
    }
  },
  mounted() {
    if (this.value.data) {
      this.editedGraphic = this.value;
    }
  }
}
</script>

<style scoped>
.graphic-editor-container {
  position: relative;
  margin: 10px auto;
  width: 500px;
  height: 500px;
  border: 1px solid black;
  overflow: hidden;
}
.graphic-editor-background {
  position: absolute;
  top: 0;
  left: 0;
}
.graphic-editor-overlay {
  position: absolute;
  top: 0;
  left: 0;
}
.graphic-editor-graphic {
  position: absolute;
  top: 0;
  left: 0;
}
</style>