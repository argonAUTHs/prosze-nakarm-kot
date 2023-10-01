<template>
  <q-page class="row items-center justify-evenly">
    <q-card class="my-card">
      <q-banner dense class="bg-info">
        <q-icon name="info" />
        Scan the QR code with TDA app to connect with house.
      </q-banner>
      <q-card-section>
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
import { defineComponent, ref, onMounted } from 'vue';
import QrcodeVue from 'qrcode.vue';

export default defineComponent({
  name: 'PageIndex',
  components: {
    QrcodeVue
  },
  setup() {
    const qrcodeData = ref('');

    onMounted(() => {
      qrcodeData.value = 'message_box_url';
    });

    return {
      qrcodeData,
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
