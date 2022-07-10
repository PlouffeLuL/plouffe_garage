Auth = exports.plouffe_lib:Get("Auth")
Utils = exports.plouffe_lib:Get("Utils")
Callback = exports.plouffe_lib:Get("Callback")

Server = {
	WebHook = "",
	LogWebHook = "",
	Init = false,
	PlatesStr = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
}

Garage = {}
GarageFnc = {} 

Garage.ReductionPerSeconds = 0.01
Garage.DefaultImpoundPrice = 1000
Garage.TowingImpoundPrice = 2500
Garage.RecoveryPrice = 5000

Garage.Player = {}

Garage.ImpoundAcces = {
	police = {
		['0'] = false,
		['1'] = false,
		['2'] = {3},
		['3'] = {3},
		['4'] = {3,6},
		['5'] = {3,6,9,12},
		['6'] = {3,6,9,12,24,36,48},
		['7'] = {3,6,9,12,24,36,48,60,72,84,96}
	}
}

Garage.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0) 
}

Garage.Labels = {
	default = "Fourrière régulière",
	towed = "Fourrière de remorquage",
	police = "Fourrière de police",
}

Garage.Zones = {
	society_vineyard = {
		name = "society_vineyard",
		label = "Garage du vignoble",
		coords = vector3(-1923.5028076172, 2036.2921142578, 140.73489379883),
		maxDst = 5.0,
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			jobs = {
				vineyard = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_bsg = {
		name = "gang_bsg",
		label = "Garage des bsg",
		coords = vector3(151.65734863281, -1714.2103271484, 29.291421890259),
		type = "box",
		maxZ = 3.0,
		box = {
			A = vector2(152.81304931641, -1719.0565185547),
			B = vector2(156.66423034668, -1714.7484130859),
			C = vector2(152.40705871582, -1709.1721191406),
			D = vector2(148.11763000488, -1714.7005615234)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				bsg = {
					-- Ranks will work ServerSide once stupid gang shit is remade
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true
				}
			}
		}
	},
	gang_vagos = {
		name = "gang_vagos",
		label = "Garage des vagos",
		coords = vector3(321.2444152832, -2028.146484375, 20.759029388428),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(302.42532348633, -2024.4010009766),
			B = vector2(331.12045288086, -2048.0),
			C = vector2(342.77020263672, -2035.3458251953),
			D = vector2(312.99279785156, -2010.4509277344)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				vagos = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_families = {
		name = "gang_families",
		label = "Garage des families",
		coords = vector3(-114.31567382812, -1605.6927490234, 31.740043640137),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(-98.730865478516, -1580.5466308594),
			B = vector2(-90.057037353516, -1586.5893554688),
			C = vector2(-128.38754272461, -1615.9178466797),
			D = vector2(-120.80186462402, -1621.0679931641)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				families = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_lost = {
		name = "gang_lost",
		label = "Garage des lost",
		coords = vector3(990.52838134766, -129.08232116699, 74.06078338623),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(989.189453125, -115.40856933594),
			B = vector2(976.55438232422, -136.93368530273),
			C = vector2(991.19897460938, -139.83055114746),
			D = vector2(1003.2152709961, -126.82372283936)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				lost = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_cartel = {
		name = "gang_cartel",
		label = "Garage du cartel",
		coords = vector3(-124.14545440674, 999.12365722656, 235.73937988281),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(-134.68647766113, 1007.3434448242),
			B = vector2(-126.29090881348, 983.80187988281),
			C = vector2(-113.98715209961, 988.53991699219),
			D = vector2(-121.81907653809, 1011.9801025391)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				cartel = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_ballas = {
		name = "gang_ballas",
		label = "Garage des ballas",
		coords = vector3(101.98101806641, -1960.8996582031, 20.840049743652),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(105.35127258301, -1952.8223876953),
			B = vector2(105.12127685547, -1967.4583740234),
			C = vector2(99.235771179199, -1966.5731201172),
			D = vector2(99.625862121582, -1952.2222900391)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				ballas = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_mafia = {
		name = "gang_mafia",
		label = "Garage de la mafia",
		coords = vector3(1406.9215087891, 1115.8500976562, 114.83660125732),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(1399.0280761719, 1123.2241210938),
			B = vector2(1399.2750244141, 1107.416015625),
			C = vector2(1416.9583740234, 1107.7631835938),
			D = vector2(1416.9561767578, 1123.3176269531)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				mafia = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	gang_cali = {
		name = "gang_cali",
		label = "Garage de cali",
		coords = vector3(-1787.1580810547, 460.01330566406, 128.30871582031),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(-1794.0764160156, 463.45501708984),
			B = vector2(-1780.3664550781, 467.90008544922),
			C = vector2(-1777.9134521484, 455.52633666992),
			D = vector2(-1792.5537109375, 453.45565795898)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				cali = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	tunershop_inside = {
		name = "tunershop_inside",
		label = "Intérieur du tunershop",
		coords = vector3(139.58755493164, -3034.6889648438, 6.0532913208008),
		maxDst = 8.0,
		maxZ = 8.0,
		type = "box",
		box = {
			A = vector2(154.36100769043, -3016.8347167969),
			B = vector2(153.48963928223, -3050.5649414062),
			C = vector2(121.22157287598, -3050.0061035156),
			D = vector2(121.15350341797, -3016.22265625)
		},
		isSociety = true,
		isImpound = false,
		useBlip = false,
		access = {
			gangs = {
				clown = {
					["0"] = true,
					["1"] = true,
					["2"] = true,
					["3"] = true,
					["4"] = true,
					["5"] = true
				}
			}
		}
	},
	garagePoliceMissionRow = {
		name = "garagePoliceMissionRow",
		label = "Poste de police de mission row",
		coords = vector3(441.43862915039, -989.09979248047, 25.219976425171),
		maxZ = 3.0,
		maxDst = 2.0,
		type = "box",
		box = {
			A = vector2(426.64291381836, -974.34771728516),
			B = vector2(426.49078369141, -998.62768554688),
			C = vector2(459.97537231445, -998.97180175781),
			D = vector2(459.99255371094, -974.33294677734)
		},
		isImpound = false,
		useBlip = false
	},
	garageAlta = {
		name = "garageAlta",
		label = "Atlas Street",
		coords = vector3(-318.748046875, -934.42761230469, 31.080966949463),
		maxDst = 55.0,
		isImpound = false,
		useBlip = true
	},
	garageVinewoodBoulevard = {
		name = "garageVinewoodBoulevard",
		label = "Vinewood boulevard",
		coords = vector3(612.43078613281, 110.38316345215, 92.855087280273),
		maxDst = 20.0,
		isImpound = false,
		useBlip = true
	},
	garageDelPerro = {
		name = "garageDelPerro",
		label = "DelPerro Boulevard",
		coords = vector3(-742.10040283203, -69.010284423828, 41.750492095947),
		maxDst = 15.0,
		isImpound = false,
		useBlip = true
	},
	garageFeteForaine = {
		name = "garageFeteForaine",
		label = "Fete foraine",
		coords = vector3(-1648.9879150391, -899.11889648438, 8.6940031051636),
		maxDst = 60.0,
		isImpound = false,
		useBlip = true
	},
	garageVespucciBeach = {
		name = "garageVespucciBeach",
		label = "Plage de vespucci",
		coords = vector3(-1185.4392089844, -1489.0056152344, 4.3796720504761),
		maxDst = 18.0,
		isImpound = false,
		useBlip = true
	},
	garageAutopia = {
		name = "garageAutopia",
		label = "Autopia",
		coords = vector3(-77.820121765137, -2009.1158447266, 18.016954421997),
		maxDst = 35.0,
		isImpound = false,
		useBlip = true
	},
	garageMirrorPark = {
		name = "garageMirrorPark",
		label = "Mirror Park",
		coords = vector3(1028.9494628906, -772.28192138672, 58.044361114502),
		maxDst = 18.0,
		isImpound = false,
		useBlip = true
	},
	garageSandyShore = {
		name = "garageSandyShore",
		label = "SandyShore",
		coords = vector3(1729.7806396484, 3716.4582519531, 34.12247467041),
		maxDst = 15.0,
		isImpound = false,
		useBlip = true
	},
	garageGrapeseed = {
		name = "garageGrapeseed",
		label = "Grapeseed",
		coords = vector3(1702.6511230469, 4800.56640625, 41.789958953857),
		maxDst = 15.0,
		isImpound = false,
		useBlip = true
	},
	garagePaletoBay = {
		name = "garagePaletoBay",
		label = "Paleto Bay",
		coords = vector3(163.62496948242, 6606.73828125, 31.858882904053),
		maxDst = 43.0,
		isImpound = false,
		useBlip = true
	},
	garageHopitalPillbox = {
		name = "garageHopitalPillbox",
		label = "Hopital de pillbox",
		coords = vector3(323.31771850586, -546.78814697266, 28.744073867798),
		maxDst = 20.0,
		isImpound = false,
		useBlip = false
	},
	garageTequila = {
		name = "garageTequila",
		label = "Garage tequila",
		coords = vector3(-575.23126220703, 326.93817138672, 84.629516601562),
		maxDst = 20.0,
		isImpound = false,
		useBlip = true
	},
	garageTunerShop = {
		name = "garageTunerShop",
		label = "Garage Tuner Shop",
		coords = vector3(207.16207885742, -3071.0698242188, 5.777708530426),
		maxDst = 10.0,
		isImpound = false,
		useBlip = false
	},
	garageBoatDealer = {
		name = "garageBoatDealer",
		label = "Garage Concess Bateau",
		coords = vector3(-801.51257324219, -1299.1251220703, 5.0003833770752),
		maxDst = 10.0,
		isImpound = false,
		useBlip = true
	},
	garageAirDealer = {
		name = "garageAirDealer",
		label = "Garage Concess Bateau",
		coords = vector3(-967.81848144531, -2890.8583984375, 13.960341453552),
		maxDst = 10.0,
		isImpound = false,
		useBlip = true
	},
	garagePaintballSandy = {
		name = "garagePaintballSandy",
		label = "Garage Paintball Sandy",
		coords = vector3(2392.2021484375, 2522.3364257812, 46.679389953613),
		maxDst = 10.0,
		isImpound = false,
		useBlip = true
	},
	garageCarWarehouse = {
		name = "garageCarWarehouse",
		label = "Entrepot Automobile",
		coords = vector3(-286.08154296875, -2652.2883300781, 6.0066208839417),
		maxDst = 10.0,
		isImpound = false,
		useBlip = true
	},
	impoundAdamsApple = {
		name = "impoundAdamsApple",
		label = "Impound Adams Apple Boulevard",
		coords = vector3(-143.14282226563, -1172.6710205078, 23.769598007202),
		maxDst = 15.0,
		isImpound = true,
		useBlip = true
	},
	impoundPaleto = {
		name = "impoundPaleto",
		label = "Impound Paleto",
		coords = vector3(-219.92951965332, 6347.39453125, 31.891592025757),
		maxDst = 10.0,
		isImpound = true,
		useBlip = true
	},
	garagePoliceDavisStreet = {
		name = "garagePoliceDavisStreet",
		label = "Poste de police davis street",
		coords = vector3(388.85516357422, -1624.5501708984, 29.292074203491),
		maxZ = 3.0,
		maxDst = 2.0,
		type = "box",
		box = {
			A = vector2(387.18368530273, -1640.2322998047),
			B = vector2(405.61239624023, -1617.2652587891),
			C = vector2(392.05123901367, -1605.7205810547),
			D = vector2(373.521484375, -1628.3494873047)
		},
		isImpound = false,
		useBlip = false
	},
	impoundDavisStreet = {
		name = "impoundDavisStreet",
		label = "Impound Davis Street",
		coords = vector3(408.55416870117, -1635.2763671875, 29.298969268799),
		maxZ = 3.0,
		maxDst = 2.0,
		type = "box",
		box = {
			A = vector2(388.70080566406, -1642.2017822266),
			B = vector2(410.71347045898, -1659.6663818359),
			C = vector2(423.45568847656, -1639.2401123047),
			D = vector2(409.50186157227, -1617.0836181641)
		},
		isImpound = true,
		useBlip = true
	},
	garagePolicePaleto = {
		name = "garagePolicePaleto",
		label = "Poste de police Paleto",
		coords = vector3(-472.74523925781, 6030.876953125, 31.340389251709),
		maxZ = 3.0,
		maxDst = 2.0,
		type = "box",
		box = {
			A = vector2(-450.99829101563, 6041.3227539063),
			B = vector2(-460.53549194336, 6051.6572265625),
			C = vector2(-488.37243652344, 6024.4477539063),
			D = vector2(-478.47695922852, 6014.802734375)
		},
		isImpound = false,
		useBlip = false
	}
}