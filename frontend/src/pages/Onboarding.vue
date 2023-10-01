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
        <div class="qrcode-container">
          <qrcode-vue
            v-if="qrcodeData"
            :value="qrcodeData"
            size=200
            level="H" />
        </div>
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
  max-height: 60vh;
}

.qrcode-container {
  display: flex;
  justify-content: center;
}
</style>
