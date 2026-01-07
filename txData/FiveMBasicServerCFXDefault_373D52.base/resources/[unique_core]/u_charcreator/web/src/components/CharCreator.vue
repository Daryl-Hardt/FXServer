<template>
  <div class="cc" v-if="visible">
    <div class="title">
      <p>Charakter Editor</p>
      <span>Passe das Aussehen deines Charakters an!</span>
    </div>
    <div class="editor">
      <div class="categories">
        <div
          class="category"
          :class="{ active: activeCategoryKey === 'identity' }"
          @click="setCategory('identity')"
        >
          <img src="../assets/img/identity.png" alt="dna">
          <p>Identität</p>
        </div>
        <div
          class="category"
          :class="{ active: activeCategoryKey === 'dna' }"
          @click="setCategory('dna')"
        >
          <img src="../assets/img/dna.png" alt="dna">
          <p>DNA</p>
        </div>
        <div
          class="category"
          :class="{ active: activeCategoryKey === 'features' }"
          @click="setCategory('features')"
        >
          <img src="../assets/img/face-features.png" alt="dna">
          <p>Merkmale</p>
        </div>
        <div
          class="category"
          :class="{ active: activeCategoryKey === 'hair' }"
          @click="setCategory('hair')"
        >
          <img src="../assets/img/scissors.png" alt="dna">
          <p>Haare</p>
        </div>
        <div
          class="category"
          :class="{ active: activeCategoryKey === 'face' }"
          @click="setCategory('face')"
        >
          <img src="../assets/img/face-features.png" alt="dna">
          <p>Gesicht</p>
        </div>
        <!--<div
          class="category"
          :class="{ active: activeCategoryKey === 'clothes' }"
          @click="setCategory('clothes')"
        >
          <img src="../assets/img/shirt.png" alt="dna">
          <p>Kleidung</p>
        </div>-->
      </div>
      <div class="options">
        <div class="option identity" v-if="activeCategoryKey === 'identity'">
          <div class="wrapper form-group">
            <label>Geschlecht</label>
            <div style="display:flex; gap:1vh;">
              <button type="button" class="mix-btn gender-btn" @click="setGender(0)" :style="gender===0?'filter:brightness(1.2)':''"><img src="../assets/img/male.png" alt="male" class="gender-icon"></button>
              <button type="button" class="mix-btn gender-btn" @click="setGender(1)" :style="gender===1?'filter:brightness(1.2)':''"><img src="../assets/img/female.png" alt="female" class="gender-icon"></button>
            </div>
          </div>

          <div class="wrapper form-group">
            <label>Vorname</label>
            <div class="input-wrapper">
              <span class="icon">
                <i class="fa-solid fa-user"></i>
              </span>
              <input
                type="text"
                v-model="identity.firstName"
                placeholder="Vorname"
              >
            </div>
          </div>

          <div class="wrapper form-group">
            <label>Nachname</label>
            <div class="input-wrapper">
              <span class="icon">
                <i class="fa-solid fa-user"></i>
              </span>
              <input
                type="text"
                v-model="identity.lastName"
                placeholder="Nachname"
              >
            </div>
          </div>

          <div class="wrapper form-group">
            <label>Geburtsdatum</label>
            <div class="input-wrapper">
              <span class="icon">
                <i class="fa-solid fa-calendar-day"></i>
              </span>
              <input
                type="text"
                v-model="identity.birthdate"
                placeholder="TT.MM.JJJJ"
              >
            </div>
          </div>

          <div class="wrapper form-group">
            <label>Herkunft</label>
            <div class="input-wrapper">
              <span class="icon">
                <i class="fa-solid fa-earth-europe"></i>
              </span>
              <input
                type="text"
                v-model="identity.origin"
                placeholder="Herkunft"
              >
            </div>
          </div>

          <div class="wrapper form-group">
            <label>Größe</label>
            <div class="input-wrapper">
              <span class="icon">
                <i class="fa-solid fa-ruler-vertical"></i>
              </span>
              <input
                type="text"
                v-model="identity.height"
                placeholder="z. B. 185 cm"
              >
            </div>
          </div>
        </div>

        <div class="option dna" v-if="activeCategoryKey === 'dna'">
          <div class="wrapper">
            <p class="title">Gesicht 1</p>
            <div class="parents">
              <img
                v-for="id in parents"
                :key="'face1-' + id"
                :src="getParentSrc(id)"
                :class="{ active: dnaSelection.face1 === id }"
                @click="selectParent('face1', id)"
              >
            </div>
            <p class="title">Haut 1</p>
            <div class="parents">
              <img
                v-for="id in parents"
                :key="'skin1-' + id"
                :src="getParentSrc(id)"
                :class="{ active: dnaSelection.skin1 === id }"
                @click="selectParent('skin1', id)"
              >
            </div>
          </div>
          
          <div class="wrapper">
            <p class="title">Gesicht 2</p>
            <div class="parents">
              <img
                v-for="id in parents"
                :key="'face2-' + id"
                :src="getParentSrc(id)"
                :class="{ active: dnaSelection.face2 === id }"
                @click="selectParent('face2', id)"
              >
            </div>

            <p class="title">Haut 2</p>
            <div class="parents">
              <img
                v-for="id in parents"
                :key="'skin2-' + id"
                :src="getParentSrc(id)"
                :class="{ active: dnaSelection.skin2 === id }"
                @click="selectParent('skin2', id)"
              >
            </div>
          </div>

          <div class="wrapper">
            <p class="title">Gesicht 3</p>
            <div class="parents">
              <img
                v-for="id in parents"
                :key="'face3-' + id"
                :src="getParentSrc(id)"
                :class="{ active: dnaSelection.face3 === id }"
                @click="selectParent('face3', id)"
              >
            </div>
            
            <p class="title">Haut 3</p>
            <div class="parents">
              <img
                v-for="id in parents"
                :key="'skin3-' + id"
                :src="getParentSrc(id)"
                :class="{ active: dnaSelection.skin3 === id }"
                @click="selectParent('skin3', id)"
              >
            </div>
          </div>

          <div class="mix-wrapper">
            <div class="wrapper">
              <p class="title">Kopf Mix</p>
              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepMix('head', -5)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>
                <input type="range" min="0" max="100" v-model="mix.head">
                <button type="button" class="mix-btn" @click="stepMix('head', 5)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>
            </div>

            <div class="wrapper">
              <p class="title">Haut Mix</p>
              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepMix('skin', -5)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>
                <input type="range" min="0" max="100" v-model="mix.skin">
                <button type="button" class="mix-btn" @click="stepMix('skin', 5)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>
            </div>

            <div class="wrapper">
              <p class="title">Third Mix</p>
              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepMix('third', -5)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>
                <input type="range" min="0" max="100" v-model="mix.third">
                <button type="button" class="mix-btn" @click="stepMix('third', 5)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="option features" v-if="activeCategoryKey === 'features'">
          <div class="wrapper" v-for="group in featureGroups" :key="group.key">
            <p class="title">{{ group.label }}</p>

            <div class="slider-row" v-for="f in group.items" :key="f.index">
              <div class="slider-top">
                <span class="slider-label">{{ f.label }}</span>
                <span class="slider-value">{{ featureValues[f.index].toFixed(1) }}</span>
              </div>

              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepFeature(f.index, -f.step)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>

                <input
                  type="range"
                  :min="f.min"
                  :max="f.max"
                  :step="f.step"
                  v-model.number="featureValues[f.index]"
                  @input="emitAppearance()"
                >

                <button type="button" class="mix-btn" @click="stepFeature(f.index, f.step)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div class="option hair" v-if="activeCategoryKey === 'hair'">
          <div class="wrapper">
            <p class="title">Frisur</p>

            <div class="slider-row">
              <div class="slider-top">
                <span class="slider-label">Style</span>
                <span class="slider-value">{{ hair.style }}</span>
              </div>

              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepHairStyle(-1)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>

                <input
                  type="range"
                  min="0"
                  :max="Math.max(0, hairMax.style - 1)"
                  step="1"
                  v-model.number="hair.style"
                  @input="emitAppearance()"
                >

                <button type="button" class="mix-btn" @click="stepHairStyle(1)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>
            </div>
          </div>

          <div class="wrapper">
            <p class="title">Haarfarbe</p>

            <div class="color-grid">
              <button
                v-for="c in hairColors"
                :key="'hairColor-' + c"
                type="button"
                class="color-dot"
                :class="{ active: hair.color === c }"
                :style="getHairColorStyle(c)"
                @click="setHairColor(c)"
              ></button>
            </div>

            <p class="title" style="margin-top: 1vh;">Highlights</p>

            <div class="color-grid">
              <button
                v-for="c in hairColors"
                :key="'hairHighlight-' + c"
                type="button"
                class="color-dot"
                :class="{ active: hair.highlight === c }"
                :style="getHairColorStyle(c)"
                @click="setHairHighlight(c)"
              ></button>
            </div>
          </div>

          <div class="wrapper">
            <p class="title">Bart / Augenbrauen / Brusthaar</p>

            <div class="slider-row" v-for="ov in hairOverlays" :key="ov.key">
              <div class="slider-top">
                <span class="slider-label">{{ ov.label }}</span>
                <span class="slider-value">{{ hairOverlay[ov.key].index }}</span>
              </div>

              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepOverlay(ov.key, -1)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>

                <input
                  type="range"
                  min="0"
                  :max="ov.max"
                  step="1"
                  v-model.number="hairOverlay[ov.key].index"
                  @input="emitAppearance()"
                >

                <button type="button" class="mix-btn" @click="stepOverlay(ov.key, 1)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>

              <div class="slider-row" style="margin-top: 1vh;">
                <div class="slider-top">
                  <span class="slider-label">Stärke</span>
                  <span class="slider-value">{{ hairOverlay[ov.key].opacity.toFixed(2) }}</span>
                </div>

                <div class="mix-controls">
                  <button type="button" class="mix-btn" @click="stepOverlayOpacity(ov.key, -0.05)">
                    <i class="fa-solid fa-chevron-left"></i>
                  </button>

                  <input
                    type="range"
                    min="0"
                    max="1"
                    step="0.01"
                    v-model.number="hairOverlay[ov.key].opacity"
                    @input="emitAppearance()"
                  >

                  <button type="button" class="mix-btn" @click="stepOverlayOpacity(ov.key, 0.05)">
                    <i class="fa-solid fa-chevron-right"></i>
                  </button>
                </div>
              </div>

              <div class="color-grid" style="margin-top: 1vh;">
                <button
                  v-for="c in hairColors"
                  :key="ov.key + '-color-' + c"
                  type="button"
                  class="color-dot"
                  :class="{ active: hairOverlay[ov.key].color === c }"
                  :style="getHairColorStyle(c)"
                  @click="setOverlayColor(ov.key, c)"
                ></button>
              </div>
            </div>
          </div>
        </div>

        <div class="option face" v-if="activeCategoryKey === 'face'">
          <div class="wrapper">
            <p class="title">Augen</p>

            <div class="slider-row">
              <div class="slider-top">
                <span class="slider-label">Augenfarbe</span>
                <span class="slider-value">{{ face.eyeColor }}</span>
              </div>

              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepEyeColor(-1)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>

                <input
                  type="range"
                  min="0"
                  max="31"
                  step="1"
                  v-model.number="face.eyeColor"
                  @input="emitAppearance()"
                >

                <button type="button" class="mix-btn" @click="stepEyeColor(1)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>
            </div>
          </div>

          <div class="wrapper" v-for="group in skinOverlayGroups" :key="group.key">
            <p class="title">{{ group.label }}</p>

            <div class="overlay-row" v-for="ov in group.items" :key="ov.key">
              <div class="slider-top">
                <span class="slider-label">{{ ov.label }}</span>
                <span class="slider-value">{{ overlays[ov.key].index }}</span>
              </div>

              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepSkinOverlay(ov.key, -1)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>

                <input
                  type="range"
                  :min="ov.min"
                  :max="ov.max"
                  step="1"
                  v-model.number="overlays[ov.key].index"
                  @input="emitAppearance()"
                >

                <button type="button" class="mix-btn" @click="stepSkinOverlay(ov.key, 1)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>

              <div class="slider-row" style="margin-top: 1vh;">
                <div class="slider-top">
                  <span class="slider-label">Stärke</span>
                  <span class="slider-value">{{ overlays[ov.key].opacity.toFixed(2) }}</span>
                </div>

                <div class="mix-controls">
                  <button type="button" class="mix-btn" @click="stepSkinOverlayOpacity(ov.key, -0.05)">
                    <i class="fa-solid fa-chevron-left"></i>
                  </button>

                  <input
                    type="range"
                    min="0"
                    max="1"
                    step="0.01"
                    v-model.number="overlays[ov.key].opacity"
                    @input="emitAppearance()"
                  >

                  <button type="button" class="mix-btn" @click="stepSkinOverlayOpacity(ov.key, 0.05)">
                    <i class="fa-solid fa-chevron-right"></i>
                  </button>
                </div>
              </div>

              <div v-if="ov.hasColor" class="color-grid" style="margin-top: 1vh;">
                <button
                  v-for="c in makeupColors"
                  :key="ov.key + '-mk-' + c"
                  type="button"
                  class="color-dot"
                  :class="{ active: overlays[ov.key].color === c }"
                  :style="getMakeupColorStyle(c)"
                  @click="setSkinOverlayColor(ov.key, c)"
                ></button>
              </div>
            </div>
          </div>
        </div>

        <div class="option clothes" v-if="activeCategoryKey === 'clothes'">
          <div class="wrapper" v-for="grp in clothesGroups" :key="grp.key">
            <p class="title">{{ grp.label }}</p>

            <div class="slider-row" v-for="c in grp.items" :key="c.key">
              <div class="slider-top">
                <span class="slider-label">{{ c.label }}</span>
                <span class="slider-value">{{ clothes[c.key].drawable }} / {{ clothesMax[c.key].drawable - 1 }}</span>
              </div>

              <div class="mix-controls">
                <button type="button" class="mix-btn" @click="stepClothesDrawable(c.key, -1)">
                  <i class="fa-solid fa-chevron-left"></i>
                </button>

                <input
                  type="range"
                  min="0"
                  :max="Math.max(0, clothesMax[c.key].drawable - 1)"
                  step="1"
                  v-model.number="clothes[c.key].drawable"
                  @input="onClothesDrawableChanged(c.key)"
                >

                <button type="button" class="mix-btn" @click="stepClothesDrawable(c.key, 1)">
                  <i class="fa-solid fa-chevron-right"></i>
                </button>
              </div>

              <div class="slider-row" style="margin-top: 1vh;">
                <div class="slider-top">
                  <span class="slider-label">Textur</span>
                  <span class="slider-value">{{ clothes[c.key].texture }} / {{ clothesMax[c.key].texture - 1 }}</span>
                </div>

                <div class="mix-controls">
                  <button type="button" class="mix-btn" @click="stepClothesTexture(c.key, -1)">
                    <i class="fa-solid fa-chevron-left"></i>
                  </button>

                  <input
                    type="range"
                    min="0"
                    :max="Math.max(0, clothesMax[c.key].texture - 1)"
                    step="1"
                    v-model.number="clothes[c.key].texture"
                    @input="emitAppearance()"
                  >

                  <button type="button" class="mix-btn" @click="stepClothesTexture(c.key, 1)">
                    <i class="fa-solid fa-chevron-right"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
        
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CharCreator',
  data() {
    return {
      visible: false,
      activeCategoryKey: 'identity',

      identity: {
        firstName: '',
        lastName: '',
        birthdate: '',
        origin: '',
        height: ''
      },

      gender: 0,

      parents: Array.from({ length: 46 }, (_, i) => i),
      dnaSelection: {
        face1: 0, skin1: 0,
        face2: 0, skin2: 0,
        face3: 0, skin3: 0
      },

      mix: {
        head: 50,
        skin: 50,
        third: 50
      },

      featureValues: Array.from({ length: 20 }, () => 0.0),

      hairMax: {
        style: 1
      },

      hair: {
        style: 0,
        color: 0,
        highlight: 0
      },

      hairColors: Array.from({ length: 64 }, (_, i) => i),
      hairRgb: {},
      makeupRgb: {},

      hairOverlays: [
        { key: 'beard', label: 'Bart', overlayId: 1, max: 28 },
        { key: 'eyebrows', label: 'Augenbrauen', overlayId: 2, max: 33 },
        { key: 'chest', label: 'Brusthaar', overlayId: 10, max: 16 }
      ],
      hairOverlay: {
        beard: { index: 0, opacity: 0.8, color: 0 },
        eyebrows: { index: 0, opacity: 0.8, color: 0 },
        chest: { index: 0, opacity: 0.8, color: 0 }
      },

      face: {
        eyeColor: 0
      },

      overlays: {
        blemishes: { overlayId: 0, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 },
        ageing: { overlayId: 3, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 },
        complexion: { overlayId: 6, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 },
        sunDamage: { overlayId: 7, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 },
        freckles: { overlayId: 9, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 },

        makeup: { overlayId: 4, index: 0, opacity: 0.0, hasColor: true, colorType: 1, color: 0 },
        blush: { overlayId: 5, index: 0, opacity: 0.0, hasColor: true, colorType: 2, color: 0 },
        lipstick: { overlayId: 8, index: 0, opacity: 0.0, hasColor: true, colorType: 2, color: 0 },

        bodyBlemishes: { overlayId: 11, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 },
        bodyBlemishes2: { overlayId: 12, index: 0, opacity: 0.0, hasColor: false, colorType: 0, color: 0 }
      },

      makeupColors: Array.from({ length: 64 }, (_, i) => i),

      clothesMax: {
        mask: { drawable: 1, texture: 1 },
        hair: { drawable: 1, texture: 1 },
        torso: { drawable: 1, texture: 1 },
        legs: { drawable: 1, texture: 1 },
        bag: { drawable: 1, texture: 1 },
        shoes: { drawable: 1, texture: 1 },
        accessory: { drawable: 1, texture: 1 },
        undershirt: { drawable: 1, texture: 1 },
        kevlar: { drawable: 1, texture: 1 },
        decals: { drawable: 1, texture: 1 },
        tops: { drawable: 1, texture: 1 }
      },

      clothes: {
        mask: { componentId: 1, drawable: 0, texture: 0, palette: 0 },
        hair: { componentId: 2, drawable: 0, texture: 0, palette: 0 },
        torso: { componentId: 3, drawable: 0, texture: 0, palette: 0 },
        legs: { componentId: 4, drawable: 0, texture: 0, palette: 0 },
        bag: { componentId: 5, drawable: 0, texture: 0, palette: 0 },
        shoes: { componentId: 6, drawable: 0, texture: 0, palette: 0 },
        accessory: { componentId: 7, drawable: 0, texture: 0, palette: 0 },
        undershirt: { componentId: 8, drawable: 0, texture: 0, palette: 0 },
        kevlar: { componentId: 9, drawable: 0, texture: 0, palette: 0 },
        decals: { componentId: 10, drawable: 0, texture: 0, palette: 0 },
        tops: { componentId: 11, drawable: 0, texture: 0, palette: 0 }
      }
    }
  },

  computed: {
    featureGroups() {
      return [
        {
          key: 'nose',
          label: 'Nase',
          items: [
            { index: 0, label: 'Breite', min: -1, max: 1, step: 0.1 },
            { index: 1, label: 'Höhe', min: -1, max: 1, step: 0.1 },
            { index: 2, label: 'Länge', min: -1, max: 1, step: 0.1 },
            { index: 3, label: 'Rücken', min: -1, max: 1, step: 0.1 },
            { index: 4, label: 'Spitze', min: -1, max: 1, step: 0.1 },
            { index: 5, label: 'Drehung', min: -1, max: 1, step: 0.1 }
          ]
        },
        {
          key: 'brows',
          label: 'Augenbrauen',
          items: [
            { index: 6, label: 'Höhe', min: -1, max: 1, step: 0.1 },
            { index: 7, label: 'Breite', min: -1, max: 1, step: 0.1 }
          ]
        },
        {
          key: 'cheeks',
          label: 'Wangen',
          items: [
            { index: 8, label: 'Wangenknochen Höhe', min: -1, max: 1, step: 0.1 },
            { index: 9, label: 'Wangenknochen Breite', min: -1, max: 1, step: 0.1 },
            { index: 10, label: 'Wangen Breite', min: -1, max: 1, step: 0.1 }
          ]
        },
        {
          key: 'eyesLips',
          label: 'Augen & Lippen',
          items: [
            { index: 11, label: 'Augenöffnung', min: -1, max: 1, step: 0.1 },
            { index: 12, label: 'Lippenfülle', min: -1, max: 1, step: 0.1 }
          ]
        },
        {
          key: 'jawChin',
          label: 'Kiefer & Kinn',
          items: [
            { index: 13, label: 'Kieferbreite', min: -1, max: 1, step: 0.1 },
            { index: 14, label: 'Kieferform', min: -1, max: 1, step: 0.1 },
            { index: 15, label: 'Kinnhöhe', min: -1, max: 1, step: 0.1 },
            { index: 16, label: 'Kinnlänge', min: -1, max: 1, step: 0.1 },
            { index: 17, label: 'Kinnform', min: -1, max: 1, step: 0.1 },
            { index: 18, label: 'Kinngrübchen', min: -1, max: 1, step: 0.1 }
          ]
        },
        {
          key: 'neck',
          label: 'Hals',
          items: [
            { index: 19, label: 'Halsbreite', min: -1, max: 1, step: 0.1 }
          ]
        }
      ]
    },

    skinOverlayGroups() {
      return [
        {
          key: 'skin',
          label: 'Hautdetails',
          items: [
            { key: 'blemishes', label: 'Hautunreinheiten', min: 0, max: 23, hasColor: false },
            { key: 'ageing', label: 'Alter/Falten', min: 0, max: 14, hasColor: false },
            { key: 'complexion', label: 'Teint', min: 0, max: 11, hasColor: false },
            { key: 'sunDamage', label: 'Sonnenschäden', min: 0, max: 10, hasColor: false },
            { key: 'freckles', label: 'Sommersprossen', min: 0, max: 17, hasColor: false }
          ]
        },
        {
          key: 'makeup',
          label: 'Makeup',
          items: [
            { key: 'makeup', label: 'Makeup', min: 0, max: 74, hasColor: true },
            { key: 'blush', label: 'Rouge', min: 0, max: 6, hasColor: true },
            { key: 'lipstick', label: 'Lippenstift', min: 0, max: 9, hasColor: true }
          ]
        },
        {
          key: 'body',
          label: 'Körper',
          items: [
            { key: 'bodyBlemishes', label: 'Körperflecken', min: 0, max: 11, hasColor: false },
            { key: 'bodyBlemishes2', label: 'Zusätzliche Körperflecken', min: 0, max: 1, hasColor: false }
          ]
        }
      ]
    },

    clothesGroups() {
      return [
        {
          key: 'base',
          label: 'Basis',
          items: [
            { key: 'tops', label: 'Oberteil' },
            { key: 'undershirt', label: 'Unterhemd' },
            { key: 'torso', label: 'Arme/Torso' },
            { key: 'legs', label: 'Hose' },
            { key: 'shoes', label: 'Schuhe' }
          ]
        },
        {
          key: 'extras',
          label: 'Extras',
          items: [
            { key: 'mask', label: 'Maske' },
            { key: 'accessory', label: 'Accessoires' },
            { key: 'bag', label: 'Tasche' },
            { key: 'kevlar', label: 'Weste' },
            { key: 'decals', label: 'Decals' }
          ]
        }
      ]
    }
  },

  mounted() {
    window.addEventListener('message', (e) => {
      const msg = e.data || {}

      if (msg.action === 'open') {
        this.visible = true
        if (typeof msg.gender === 'number') this.gender = msg.gender
      }

      if (msg.action === 'close') {
        this.visible = false
      }

      if (msg.type === 'cc:meta') {
        if (msg.hairMax) this.hairMax = msg.hairMax
      }

      if (msg.type === 'cc:textureMax') {
        if (msg.key && typeof msg.textureMax === 'number') {
          this.clothesMax[msg.key].texture = Math.max(1, msg.textureMax)
        }
      }

      if (msg.type === 'cc:palette') {
        if (msg.hair) this.hairRgb = msg.hair
        if (msg.makeup) this.makeupRgb = msg.makeup
      }
    })
  },

  methods: {
    nui(name, data = {}) {
      return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
      })
    },

    setCategory(key) {
      this.activeCategoryKey = key
      this.emitRequestMeta()
    },

    setGender(g) {
      this.gender = g
      this.nui('cc_setGender', { gender: g }).catch(() => {})
    },

    getParentSrc(id) {
      return require(`../assets/img/parents/parent_${id}.png`)
    },

    selectParent(groupKey, id) {
      this.dnaSelection[groupKey] = id
      this.emitAppearance()
    },

    stepMix(key, delta) {
      const value = Number(this.mix[key]) + delta
      if (value < 0) this.mix[key] = 0
      else if (value > 100) this.mix[key] = 100
      else this.mix[key] = value
      this.emitAppearance()
    },

    stepFeature(index, delta) {
      const v = Number(this.featureValues[index]) + delta
      if (v < -1) this.featureValues.splice(index, 1, -1)
      else if (v > 1) this.featureValues.splice(index, 1, 1)
      else this.featureValues.splice(index, 1, Number(v.toFixed(2)))
      this.emitAppearance()
    },

    stepHairStyle(delta) {
      const max = Math.max(0, this.hairMax.style - 1)
      const v = this.hair.style + delta
      this.hair.style = Math.min(max, Math.max(0, v))
      this.emitAppearance()
    },

    getHairColorStyle(i) {
      const rgb = this.hairRgb[i]
      if (!rgb) return { backgroundColor: '#2b2b2b' }
      return { backgroundColor: `rgb(${rgb.r}, ${rgb.g}, ${rgb.b})` }
    },

    getMakeupColorStyle(i) {
      const rgb = this.makeupRgb[i]
      if (!rgb) return { backgroundColor: '#2b2b2b' }
      return { backgroundColor: `rgb(${rgb.r}, ${rgb.g}, ${rgb.b})` }
    },

    setHairColor(i) {
      this.hair.color = i
      this.emitAppearance()
    },

    setHairHighlight(i) {
      this.hair.highlight = i
      this.emitAppearance()
    },

    stepOverlay(key, delta) {
      const max = this.hairOverlays.find(x => x.key === key)?.max ?? 0
      const v = this.hairOverlay[key].index + delta
      this.hairOverlay[key].index = Math.min(max, Math.max(0, v))
      this.emitAppearance()
    },

    stepOverlayOpacity(key, delta) {
      const v = Number(this.hairOverlay[key].opacity) + delta
      this.hairOverlay[key].opacity = Math.min(1, Math.max(0, Number(v.toFixed(2))))
      this.emitAppearance()
    },

    setOverlayColor(key, color) {
      this.hairOverlay[key].color = color
      this.emitAppearance()
    },

    stepEyeColor(delta) {
      const v = this.face.eyeColor + delta
      this.face.eyeColor = Math.min(31, Math.max(0, v))
      this.emitAppearance()
    },

    stepSkinOverlay(key, delta) {
      const ov = this.skinOverlayGroups.flatMap(g => g.items).find(x => x.key === key)
      const max = ov ? ov.max : 0
      const v = this.overlays[key].index + delta
      this.overlays[key].index = Math.min(max, Math.max(0, v))
      this.emitAppearance()
    },

    stepSkinOverlayOpacity(key, delta) {
      const v = Number(this.overlays[key].opacity) + delta
      this.overlays[key].opacity = Math.min(1, Math.max(0, Number(v.toFixed(2))))
      this.emitAppearance()
    },

    setSkinOverlayColor(key, color) {
      this.overlays[key].color = color
      this.emitAppearance()
    },

    stepClothesDrawable(key, delta) {
      const max = Math.max(0, this.clothesMax[key].drawable - 1)
      const v = this.clothes[key].drawable + delta
      this.clothes[key].drawable = Math.min(max, Math.max(0, v))
      this.onClothesDrawableChanged(key)
    },

    stepClothesTexture(key, delta) {
      const max = Math.max(0, this.clothesMax[key].texture - 1)
      const v = this.clothes[key].texture + delta
      this.clothes[key].texture = Math.min(max, Math.max(0, v))
      this.emitAppearance()
    },

    onClothesDrawableChanged(key) {
      const max = Math.max(0, this.clothesMax[key].texture - 1)
      if (this.clothes[key].texture > max) this.clothes[key].texture = max
      this.emitRequestClothesTextureMax(key)
      this.emitAppearance()
    },

    emitRequestMeta() {
      this.nui('cc_requestMeta')
        .then(r => r.json())
        .then(meta => {
          if (meta?.hairMax) this.hairMax = meta.hairMax
        })
        .catch(() => {})
    },

    emitRequestClothesTextureMax(key) {
      this.nui('cc_requestTextureMax', {
        key,
        componentId: this.clothes[key].componentId,
        drawable: this.clothes[key].drawable
      })
        .then(r => r.json())
        .then(res => {
          if (res?.key && typeof res.textureMax === 'number') {
            this.clothesMax[res.key].texture = Math.max(1, res.textureMax)
          }
        })
        .catch(() => {})
    },

    emitAppearance() {
      this.nui('cc_update', {
        dnaSelection: this.dnaSelection,
        mix: {
          head: this.mix.head / 100,
          skin: this.mix.skin / 100,
          third: this.mix.third / 100
        },
        features: this.featureValues,
        hair: this.hair,
        hairOverlay: this.hairOverlay,
        overlays: this.overlays,
        face: this.face,
        clothes: this.clothes
      }).catch(() => {})
    },

    finish() {
      this.nui('cc_finish', {})
        .then(r => r.json())
        .catch(() => {})
    },
    close() {
      this.nui('cc_close', {})
        .then(() => {
          this.visible = false
        })
        .catch(() => {})
    }

  }
}
</script>


<style scoped>
.cc {
  font-family: "Akrobat-Regular", sans-serif;
  width: 70vh;
  padding: 3vh;
}

.title {
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
}

.title span {
  padding: 0;
  margin: 0;
  font-size: 1.5vh;
  color: #dadada;
}

.editor {
  display: flex;
}

.categories {
  margin-top: 1vh;
}

.categories .category {
  cursor: pointer;
  transition: .2s;
  padding: 1vh;
  background: radial-gradient(#2c2c2cbd, #3b3b3b7a);
  margin-bottom: .75vh;
  border: 1px solid rgb(114, 114, 114);
  border-radius: .5vh;
  width: 6vh;
  height: 6vh;
}

.categories .category:hover {
  background-color: #0000005e;
}

.categories .category img {
  width: 4vh;
  display: flex;
  margin: auto;
  margin-bottom: .5vh;
  filter: brightness(70%);
}

.categories .category p {
  text-transform: uppercase;
  font-size: 1.35vh;
  color: #c9c9c9;
  text-align: center;
  margin: 0;
}

.categories .active {
  background: radial-gradient(#ff004cbd, #8d022c7a);
  border-color: #ff004c;
}

.categories .active p {
  color: white;
}

.categories .active img {
  filter: brightness(100%);
}

.options {
  margin-left: 3vh;
}

.option {
  width: 40vh;
  max-height: 79vh;
  overflow-y: auto;
  padding-right: 1vh;
}

.option .title {
  margin: 0;
  padding: 0;
  color: white;
  font-size: 1.7vh;
  margin-bottom: 1vh;
  background: linear-gradient(to top, #3d3d3d, #2b2b2b, #3d3d3d);
  padding: 1vh;
  border-radius: .5vh;
  font-family: "Akrobat-Regular", sans-serif;
  border: 1px solid rgb(100, 100, 100);
}

.option .wrapper {
  background-color: #3b3b3b7a;
  border: 1px solid rgb(114, 114, 114);
  margin: 1vh 0;
  padding: 2vh;
  border-radius: .5vh;
}

.form-group {
  display: flex;
  flex-direction: column;
  margin-bottom: 2vh;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group label {
  font-size: 1.3vh;
  color: white;
  margin-bottom: 0.4vh;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-family: "Akrobat-Regular", sans-serif;
}

.input-wrapper {
  display: flex;
  align-items: stretch;
  overflow: hidden;
  transition: border-color 0.2s, box-shadow 0.2s, background 0.2s;
  border-radius: .5vh;
}

.input-wrapper .icon {
  width: 4vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: radial-gradient(#CD0C4B, #752C44);
  border: 1.5px solid #ff004c;
  color: #c9c9c9;
  font-size: 1.6vh;
  border-top-left-radius: .5vh;
  border-bottom-left-radius: .5vh;
}

.input-wrapper input {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  padding: 1vh 1.5vh;
  color: #ffffff;
  font-size: 1.5vh;
  font-family: "Akrobat-Regular", sans-serif;
  background-color: #222222bd;
  transition: .2s;
}

.input-wrapper input:hover {
  background-color: #111111bd;
}

.input-wrapper input::placeholder {
  color: #9b9b9b;
}

.option.dna .parents {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.8vh;
  max-height: 20vh;
  overflow-y: auto;
  padding-right: 0.5vh;
  margin-bottom: 1vh;
}

.option.dna .parents img {
  width: 100%;
  height: 11vh;
  object-fit: cover;
  background-color: #222222d2;
  transition: .2s;
  border: 1px solid transparent;
  border-radius: .3vh;
  cursor: pointer;
}

.option.dna .parents img.active {
  background: radial-gradient(#ff004cbd, #8d022c7a);
  border-color: #ff004c;
}

.option.dna .parents img:hover {
  background-color: #1b1b1bd5;
}

.mix-wrapper {
  margin-top: 1vh;
}

.mix-block {
  margin-bottom: 1.5vh;
}

.mix-block:last-child {
  margin-bottom: 0;
}

.mix-controls {
  display: flex;
  align-items: center;
  gap: 1vh;
}

.mix-btn {
  width: 3vh;
  height: 3vh;
  border-radius: 0.5vh;
  border: 1px solid #ff004c;
  background: radial-gradient(#CD0C4B, #752C44);
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.4vh;
  cursor: pointer;
  transition: .15s;
}

.mix-btn:hover {
  filter: brightness(1.1);
}

.mix-controls input[type="range"] {
  flex: 1;
  -webkit-appearance: none;
  height: 0.4vh;
  border-radius: 0.4vh;
  background: #181818;
  outline: none;
}

.mix-controls input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 1.4vh;
  height: 1.4vh;
  border-radius: 50%;
  background: radial-gradient(#CD0C4B, #752C44);
  border: 1px solid #ff0055;
  box-shadow: 0 0 0.8vh rgba(255, 0, 85, 0.7);
  cursor: pointer;
  transition: .2s;
}

.mix-controls input[type="range"]::-webkit-slider-thumb:hover {
  filter: brightness(1.1);
}

.slider-row {
  margin-bottom: 1.5vh;
}

.slider-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.8vh;
}

.slider-label {
  color: #e7e7e7;
  font-size: 1.3vh;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  font-family: "Akrobat-Regular", sans-serif;
}

.slider-value {
  color: #ff7aa8;
  font-size: 1.3vh;
  font-family: "Akrobat-Regular", sans-serif;
}

.color-grid {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 0.8vh;
}

.color-dot {
  width: 3.2vh;
  height: 3.2vh;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,0.18);
  background: #2b2b2b;
  cursor: pointer;
  transition: .15s;
}

.color-dot:hover {
  filter: brightness(1.1);
}

.color-dot.active {
  border: 1px solid #ff004c;
  box-shadow: 0 0 1.2vh rgba(255, 0, 85, 0.45);
  transform: scale(1.03);
}

.gender-btn {
  height: 10vh;
  width: 10vh;
}

.gender-icon {
  height: 6vh;
}

::-webkit-scrollbar {
  width: 3px;
}

::-webkit-scrollbar-track {
  box-shadow: inset 0 0 5px rgb(148, 148, 148);
}

::-webkit-scrollbar-thumb {
  background: rgb(255, 255, 255);
  border-radius: 10px;
}

::-webkit-scrollbar-thumb:hover {
  background: #b32779;
}
</style>
