<template>
  <div class="full-screen">
    <GameBoard :x="-5" :y="-5" size="10" />
  </div>
</template>
<script>
import GameBoard from "./game/GameBoard";

export default {
  components: {GameBoard}
}
</script>

<style scoped>
.full-screen {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
}
</style>