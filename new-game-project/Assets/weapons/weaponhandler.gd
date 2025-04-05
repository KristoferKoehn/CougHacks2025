extends Node3D
@onready var spawner  = $spawner
@onready var antree = $AnimationPlayer

var PLAYERPLACEHOLDER

var weaponhandler = {
	"slot":0,
	"weapons":[null,null],
	"primaryammo":[0,0],
	"secondaryammo":[0,0]
	}

func startup(): 
	addweapon(0,"assaultrifle")

func _physics_process(delta: float) -> void:
	
	
	for i in weaponhandler["weapons"]:
		if i != null:
			i.active = false
			i.visible = false
	if weaponhandler["weapons"][weaponhandler["slot"]] != null:
		weaponhandler["weapons"][weaponhandler["slot"]].active = true
		weaponhandler["weapons"][weaponhandler["slot"]].visible = true
		
	if Input.is_action_just_pressed("swap"):
		swap()
	if Input.is_action_just_pressed("debug1"):
		addweapon(weaponhandler["slot"],"diskshooter")
	if Input.is_action_just_pressed("debug2"):
		addweapon(weaponhandler["slot"],"bazooka")

func swap():
	if weaponhandler["slot"] == 0 and weaponhandler["weapons"][1]!=null:
		weaponhandler["slot"] = 1
	elif weaponhandler["slot"] == 1:
		weaponhandler["slot"] = 0

func reset():
	if weaponhandler["weapons"][1] != null:
		weaponhandler["weapons"][1].stopreload()
	if weaponhandler["weapons"][0] != null:
		weaponhandler["weapons"][0].stopreload()
	for i in weaponhandler["weapons"]:
		i.visible = false
	weaponhandler["weapons"][weaponhandler["slot"]].visible = true

func addweapon(slot,title):
	var stats = WeaponStats.new()
	if weaponhandler["weapons"][1]!=null:
		weaponhandler["weapons"][slot].queue_free()
		weaponhandler["weapons"].erase(slot)
		var newgun = load(stats.weapons[title]["path"])
		var newguninstance = newgun.instantiate()
		add_child(newguninstance)
		weaponhandler["weapons"][slot] = newguninstance
	elif weaponhandler["weapons"][0]==null:
		var newgun = load(stats.weapons[title]["path"])
		var newguninstance = newgun.instantiate()
		add_child(newguninstance)
		weaponhandler["weapons"][0] = newguninstance
	else:
		var newgun = load(stats.weapons[title]["path"])
		var newguninstance = newgun.instantiate()
		add_child(newguninstance)
		weaponhandler["weapons"][1] = newguninstance
	
