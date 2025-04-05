class_name weapon
extends Node3D
@onready var spawner = $spawner

var weapontitle
var ammo = 1
var maxammo = 1
var ammoreserve = 100
var stats = WeaponStats.new()
var reloading = false
var reloadtime = 0.0
var canshoot = true
var fireratetime = 0.0
var active = false

func startup(title):
	weapontitle = title
	ammo = stats.weapons[title]["ammo"]
	maxammo = stats.weapons[title]["ammo"]
	ammoreserve = stats.weapons[title]["capacity"]

func startreload():
	ammoreserve += ammo
	ammo = 0
	reloading = true

func stopreload():
	reloadtime = 0.0

func finishreload():
	ammo = maxammo
	reloading = false

func shoot():
	if ammo != 0 and not reloading and canshoot:
		ammo -= 1
		canshoot = false 
		#print(ammo)
	if ammo == 0 and not reloading:
		startreload()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("click"):
		shoot()
	if reloading and active:
		reloadtime += delta
		if reloadtime >= stats.weapons[weapontitle]["reloadtime"]:
			reloading = false
			reloadtime = 0.0
			finishreload()
	if not canshoot:
		fireratetime += delta
		if fireratetime >= stats.weapons[weapontitle]["firerate"]:
			canshoot = true
			fireratetime = 0.0
	
	
	
	
	
