
extends CharacterBody3D
@onready var leftpole = $Gimbals/board/lthightarget
@onready var rightpole = $Gimbals/board/rthightarget
@onready var leftfoot = $Gimbals/board/leftIKtarget
@onready var rightfoot = $Gimbals/board/rightIKtarget
@onready var board = $Gimbals/board
@onready var armature = $Armature
@onready var armrotator = $Gimbals/board/armrotator/rightarmlookat
@onready var aimcast = $Gimbals/CameraGimbal/SpringArm3D/Camera3D/RayCast3D
@onready var camera = $Gimbals/CameraGimbal/SpringArm3D/Camera3D
@onready var springarm  = $camerapivot/SpringArm3D
@onready var camtrack = $camerapivot/SpringArm3D/camtrack
@onready var lefthand = $Armature/Skeleton3D/leftarmattach/playerhand
@onready var righthand = $Armature/Skeleton3D/rightarmattach/playerhand

@onready var aimnode = $aimnode

var leftdefaultrotation = 0.0
var rightdefaultrotation = 0.0
var leftdefaultposition = Vector3(0.0,0.0,0.0)
var rightdefaultposition = Vector3(0.0,0.0,0.0)
var defaultarmatureposition = Vector3(0.0,-0.683/4.0,0.0)
@export var sens: float = 0.005

var propellingForce = 50.0
var jumpForce = 1000.0

func _ready():
	$Armature/Skeleton3D/liknode.start(false)
	$Armature/Skeleton3D/riknode.start(false)
	leftdefaultrotation = leftfoot.rotation.y
	rightdefaultrotation = rightfoot.rotation.y
	leftdefaultposition = leftpole.position
	rightdefaultposition = rightpole.position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	lefthand.startup()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	#if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
	#	pivot.rotation.y -= event.relative.x * sens
	#	pivot.rotation.y = wrapf(pivot.rotation.y,0.0,TAU)
	#	springarm.rotation.x -= event.relative.y * sens
	#	springarm.rotation.x = clamp(springarm.rotation.x, -PI/2, PI/2)

func rotationhandler():
	armature.rotation.z = lerp_angle(armature.rotation.z,board.rotation.z,0.5)
	var boardrotstatez = board.rotation.z/(PI/2)
	var boardrotstatex = board.rotation.x/(PI/2)
	var armatureinfluence = Vector3(0.0,0.0,0.0)
	
	armatureinfluence = defaultarmatureposition
	if boardrotstatez == 0.0:
		pass
	elif boardrotstatez > 0.0:
		armatureinfluence = defaultarmatureposition
		armatureinfluence+=Vector3(1.617*boardrotstatez/4.0,1.08*boardrotstatez/4.0,0.0)
	elif boardrotstatez < 0.0:
		armatureinfluence = defaultarmatureposition
		armatureinfluence+=Vector3(0.492*boardrotstatez/4.0,0.6*boardrotstatez/4.0,0.0)
	
	if boardrotstatex == 0.0:
		leftpole.position = leftdefaultposition
		rightpole.position = rightdefaultposition
	elif boardrotstatex > 0.0:
		leftpole.position = leftdefaultposition + Vector3(-1.288*boardrotstatex/4.0,0.0,0.0)
		rightpole.position = rightdefaultposition + Vector3(1.203*boardrotstatex/4.0,0.0,0.0)
		
		var amounty = boardrotstatex*-2.672/4.0
		amounty = clampf(amounty,-3.445/4.0,0.4)
		armatureinfluence+=Vector3(0.0,amounty,4.294*boardrotstatex/4.0)
		
	elif boardrotstatex < 0.0:
		leftpole.position = leftdefaultposition + Vector3(-0.488*boardrotstatex/4.0,0.0,0.0)
		rightpole.position = rightdefaultposition + Vector3(0.403*boardrotstatex/4.0,0.0,0.0)
		
		var amounty = boardrotstatex*1.9/4.0
		amounty = clampf(amounty,-2.583/4.0,0.4)
		armatureinfluence+=Vector3(0.0,amounty,2.429*boardrotstatex/4.0)
		
		armatureinfluence+=Vector3(0.0,0.0,2.429*boardrotstatex/4.0)
		
	
	armature.position.x = move_toward(armature.position.x,armatureinfluence.x,0.5)
	armature.position.y = move_toward(armature.position.y,armatureinfluence.y,0.5)
	armature.position.z = move_toward(armature.position.z,armatureinfluence.z,0.5)

#func camtracker():
	#if aimcast.is_colliding():
		#$aimnode.global_position = aimcast.get_collision_point()
	#
	##camera.global_position = camtrack.global_position
	##camera.global_rotation = camtrack.global_rotation
	

func _physics_process(delta: float) -> void:
	#camtracker()
	rotationhandler()
	armature.rotation.y=board.rotation.y
	if aimcast.is_colliding():
		aimnode.global_position = aimcast.get_collision_point()
	else:
		aimnode.global_position = (aimcast.global_position - camera.global_position).normalized() * 1000 # Arbitrary "Max distance"
