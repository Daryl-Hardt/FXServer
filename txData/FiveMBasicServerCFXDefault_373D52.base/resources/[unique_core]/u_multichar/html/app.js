var app = new Vue({
  el: '#app',
  data: {
    visible: false,
    characters: [],
    firstname: '',
    lastname: '',
    gender: 0,
    error: ''
  },
  methods: {
    selectCharacter(id) {
      this.error = ''
      fetch(`https://u_multichar/selectCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify({ id: id })
      })
    },
    createCharacter() {
      this.error = ''
      if (!this.firstname || !this.lastname) {
        this.error = 'Vorname und Nachname eingeben.'
        return
      }
      fetch(`https://u_multichar/createCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify({
          firstname: this.firstname,
          lastname: this.lastname,
          gender: Number(this.gender)
        })
      })
      this.firstname = ''
      this.lastname = ''
    },
    deleteCharacter(id) {
      this.error = ''
      fetch(`https://u_multichar/deleteCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify({ id: id })
      })
    },
    closeUi() {
      fetch(`https://u_multichar/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify({})
      })
    }
  }
})

window.addEventListener('message', function (event) {
  if (event.data.action === 'open') {
    app.visible = true
    app.characters = event.data.characters || []
  }
  if (event.data.action === 'close') {
    app.visible = false
  }
})
