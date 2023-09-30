<template>
  <q-page class="row items-center justify-evenly">
    <q-card class="my-card">
      <q-card-section>
        <HomeStateComponent :home="home_state" />
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import HomeStateComponent from 'components/HomeStateComponent.vue';
import { Home } from 'components/models';

export default defineComponent({
  name: 'PageDashboard',
  components: { HomeStateComponent },
  setup() {
    const home_state = ref(new Home());
    return { home_state };
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
