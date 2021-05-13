fx_version 'adamant'

game 'gta5'

server_script {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'server.lua',
	'config.lua',
}

client_script {
	'@es_extended/locale.lua',
	'client.lua',
	'config.lua',
}
