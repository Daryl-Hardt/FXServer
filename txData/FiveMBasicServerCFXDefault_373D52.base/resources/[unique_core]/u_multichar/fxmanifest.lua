fx_version 'cerulean'
game 'gta5'

name 'u_multichar'
author 'Unique'
version '0.0.1'

ui_page 'web/dist/index.html'

files {
  'web/dist/index.html',
  'web/dist/**/*'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}
