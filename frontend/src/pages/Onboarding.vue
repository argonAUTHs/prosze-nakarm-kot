<template>
  <q-page class="row items-center justify-evenly">
    <q-card class="my-card">
      <q-card-section>
        <q-input outlined v-model="issuerId" label="Issuer ID">
          <template v-slot:after>
            <q-btn color="primary" size="lg" label="Render QR Code" @click="getQRCode" />
          </template>
        </q-input>
        <br>
        <qrcode-vue v-if="qrcodeData" :value="qrcodeData" size=300 level="H" />
      </q-card-section>
    </q-card>
  </q-page>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue';
import QrcodeVue from 'qrcode.vue';

export default defineComponent({
  name: 'PageOnboaring',
  components: {
    QrcodeVue
  },
  setup() {
    const issuerId = ref('');
    const qrcodeData = ref('');

    const getQRCode = () => {
      qrcodeData.value = issuerId.value;
    }

    return {
      issuerId,
      qrcodeData,
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
