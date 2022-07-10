fx_version "adamant"

games { 'gta5'}

client_scripts {
	'configs/clientConfig.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'configs/serverConfig.lua',
    'server/*.lua'
}

dependencies {
    "plouffe_lib"
}

exports {
    "IsInGarage",
    "CustomFetchGarage",
    "CustomPuInGarage",
    "UpdateCurrentVehicle",
    "GetGarageInfo"
}

server_exports {
    "CreatePlate",
    "CreateGarage"
}