class_name WeaponStats
extends Resource

var weapons = {
	"assaultrifle" : {
		"path" : "res://Assets/weapons/rifle/assaultrifle.tscn",
		"bulletpath" : "res://Assets/weapons/rifle/bullet.tscn",
		"firerate" : 0.15,
		"reloadtime" : 1.0,
		"capacity" : 450,
		"ammo" : 50,
		"bulletspeed":150,
		"damage":25
	},
	"diskshooter" : {
		"path" : "res://Assets/weapons/diskshooter/diskshooter.tscn",
		"bulletpath" : "res://Assets/weapons/diskshooter/disk.tscn",
		"firerate" : 2.5,
		"reloadtime" : 1.0,
		"capacity" : 49,
		"ammo" : 1,
		"bulletspeed":150,
		"damage":25
	},
		"bazooka" : {
		"path" : "res://Assets/weapons/bazooka/bazooka.tscn",
		"bulletpath" : "res://Assets/weapons/bazooka/rocket.tscn",
		"firerate" : 4.0,
		"reloadtime" : 1.0,
		"capacity" : 99,
		"ammo" : 1,
		"bulletspeed":150,
		"damage":25
	}
	}
