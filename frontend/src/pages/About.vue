<template>
  <q-page class="row items-center justify-evenly">
    <q-card class="my-card">
      <q-card-section>
        About
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
  name: 'PageAbout',
  components: {},
  setup() {
    return {};
  },
});
</script>

<style lang="scss" scoped>
.my-card {
  width: 50vw;
  min-width: 500px;
  height: 60vh;
  min-height: 400px;
}
</style>
