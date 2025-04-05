class_name projectile
extends RigidBody3D

var bullettitle = "assaultrifle"
var stats = WeaponStats.new()
var speed = 100.0
var damage = 50

func statgrabber(title):
	bullettitle = title
	speed = stats.weapons[title]["bulletspeed"]
	damage = stats.weapons[title]["damage"]
	
func start():
	linear_velocity = global_transform*speed
	
