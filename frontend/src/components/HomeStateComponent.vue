<template>
  <div>
    Doors:
    <ul>
      <li v-for="door in home.doors" :key="door.id">
        <q-toggle :label="door.name" v-model="door.state" disable left-label />
      </li>
    </ul>

    Lights:
    <ul>
      <li v-for="light in home.lights" :key="light.id">
        <q-toggle :label="light.name" v-model="light.state" disable left-label />
      </li>
    </ul>

    Cat Feeders:
    <ul>
      <li v-for="catFeeder in home.catFeeders" :key="catFeeder.id">
        <q-toggle :label="catFeeder.name" v-model="catFeeder.state" disable left-label />
      </li>
    </ul>
  </div>
</template>

<script lang="ts">
import { defineComponent, PropType } from 'vue';
import { Home } from 'components/models';

export default defineComponent({
  name: 'HomeStateComponent',
  props: {
    home: {
      type: Object as PropType<Home>,
    }
  },
});
</script>
