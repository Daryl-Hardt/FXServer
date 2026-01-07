<template>
  <div class="charselector" v-if="visible">
    <div class="title">
      <p>Charakterauswahl</p>
      <span>Klicke auf einen Charakter um ihn auszuwählen</span>
    </div>
    <div class="character-info">
      <div class="wrapper">
        <div class="titles">
          <p>Name</p>
          <p>Geburtsdatum</p>
          <p>Beruf</p>
          <p>Position</p>
        </div>
        <div class="info">
          <p>{{ character.name }}</p>
          <p>{{ character.birthdate }}</p>
          <p>{{ character.job }}</p>
          <p>{{ character.position }}</p>
        </div>
      </div>
      <button class="select" v-if="!newCharacter"><i class="fa-solid fa-play"></i> Spielen</button>
      <button class="select" v-if="newCharacter"><i class="fa-solid fa-plus"></i> Erstellen</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CharSelector',
  data() {
    return {
      visible: false,
      newCharacter: false,
      character: { name: '-', birthdate: '-', job: '-', position: '-' }
      //character: { name: 'Leroy Saint', birthdate: '13.08.2004', job: 'Zivilist', position: 'Legion Square' }
    }
  }
}

</script>

<style scoped>
.charselector {
  font-family: "Akrobat-Regular", sans-serif;
  position: relative;
  height: 100vh;
}

.title {
  padding: 3vh;
  text-align: left;
  margin-bottom: 3vh;
  text-transform: uppercase;
  font-family: "Akrobat-ExtraBold", sans-serif;
}

.title p {
  padding: 0;
  margin: 0;
  color: #ff0055;
  font-size: 3vh;
  text-shadow: 0 0 5vh #ff0055, 0 0 2vh #ff0055;
  letter-spacing: 2px;
}

.title span {
  padding: 0;
  margin: 0;
  font-size: 1.5vh;
  color: #dadada;
  letter-spacing: 1px;
}

.character-info {
  background-color: rgba(0, 0, 0, 0.5);
  color: white;
  width: 80vh;
  display: flex;
  padding: 2vh;

  position: absolute;
  bottom: 3vh;
  left: 50%;
  transform: translateX(-50%);
}

.character-info .wrapper {
  width: 100%;
}

.character-info .wrapper div {
  display: flex;
}

.character-info .wrapper div p {
  width: 100%;
  text-align: center;
  padding: 0;
  margin: 0;
}

.character-info .titles {
  color: rgb(209, 209, 209);
  text-transform: uppercase;
  letter-spacing: 2px;
}

.character-info .info {
  font-family: "Akrobat-Bold", sans-serif;
  font-size: 1.8vh;
}

.character-info .select {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1vh;

  text-transform: uppercase;
  background-color: #ff0055;
  color: white;
  border: none;

  font-family: "Akrobat-ExtraBold", sans-serif;
  letter-spacing: 1px;

  padding: .5vh 3vh;
  font-size: 1.6vh;

  cursor: pointer;
  transition: .2s;
}

.character-info .select:hover {
  filter: brightness(70%);
}

.character-info .select i {
  font-size: 1.3vh;
}
</style>
