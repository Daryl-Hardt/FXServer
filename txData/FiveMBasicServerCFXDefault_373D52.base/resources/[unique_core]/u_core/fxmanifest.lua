fx_version 'cerulean'
game 'gta5'

name 'u_core'
author 'Unique'
version '0.0.1'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/config.lua',
    'server/db.lua',
    'server/accounts.lua'
}

client_scripts {
    'client/main.lua'
}

server_exports {
    'GetAccountByIdentifier',
    'CreateAccount',
    'SetAccountWhitelisted'
}
