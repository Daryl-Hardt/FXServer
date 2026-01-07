<template>
  <div id="app">
    <CharCreator />
  </div>
</template>

<script>
import CharCreator from './components/CharCreator.vue'

export default {
  name: 'App',
  components: { CharCreator }
}
</script>

<style>
html,
body,
#app {
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  background-size: contain;
}

@font-face {
  font-family: "Akrobat-Thin";
  src: url(assets/font/Akrobat-Thin.otf);
}

@font-face {
  font-family: "Akrobat-SemiBold";
  src: url(assets/font/Akrobat-SemiBold.otf);
}

@font-face {
  font-family: "Akrobat-Regular";
  src: url(assets/font/Akrobat-Regular.otf);
}

@font-face {
  font-family: "Akrobat-Light";
  src: url(assets/font/Akrobat-Light.otf);
}

@font-face {
  font-family: "Akrobat-ExtraLight";
  src: url(assets/font/Akrobat-ExtraLight.otf);
}

@font-face {
  font-family: "Akrobat-ExtraBold";
  src: url(assets/font/Akrobat-ExtraBold.otf);
}

@font-face {
  font-family: "Akrobat-Bold";
  src: url(assets/font/Akrobat-Bold.otf);
}

@font-face {
  font-family: "Akrobat-Black";
  src: url(assets/font/Akrobat-Black.otf);
}
</style>
