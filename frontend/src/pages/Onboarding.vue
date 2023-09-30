<template>
  <q-page class="row items-center justify-evenly">
    <q-card class="my-card">
      <q-card-section>
        <div>
          <q-input outlined v-model="issuerId" label="Issuer">
            <template v-slot:after>
              <q-btn color="primary" size="lg" label="Render QR Code" @click="getQRCode" />
            </template>
          </q-input>
        </div>
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';

export default defineComponent({
  name: 'PageOnboaring',
  components: {},
  setup() {
    const issuerId = ref("");

    const getQRCode = () => {
      console.log(issuerId.value);
    }

    return {
      issuerId,
      getQRCode
    };
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
