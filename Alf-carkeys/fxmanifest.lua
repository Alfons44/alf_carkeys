fx_version 'adamant'

game 'gta5'

server_script {
	'@mysql-async/lib/MySQL.lua',
	'server.lua',
	'config.lua',
}

client_script {
	'client.lua',
	'config.lua',
}
