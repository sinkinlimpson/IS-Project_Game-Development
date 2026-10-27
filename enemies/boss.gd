extends Enemy

class_name Boss

enum BossStates {WANDER, CHARGE_WINDUP, CHARGING, STUNNED, RECOVER, SHOOT}

@export_group("Boss")

@export var knockbackResistance = 0.85

@export var wanderSpeed = 40.0
@export var wanderDuration = 1.5

@export var stunDuration = 2.0
@export var stunColor = Color(0.5, 0.6, 1.0)

@export var burstCount = 3
@export var burstDelay = 0.35

var bossState = BossStates.WANDER
var bossTimer = 0.0
var bossMoveDir = Vector2.ZERO

var bossWanderTimer = 0.0

var chargeElapsed = 0.0
var shotsLeft = 0
var shotTimer = 0.0

func _ready():
	super._ready()
	changeState(BossStates.WANDER)

func _process(_delta):
	pass

func changeState(newState):
	$Sprite2D.self_modulate = Color.WHITE
	bossState = newState

	match newState:
		BossStates.WANDER:
			bossTimer = wanderDuration
			bossWanderTimer = 0.0
		BossStates.CHARGE_WINDUP:
			bossTimer = chargeWindup
			if player != null:
				chargeDir = (player.global_position - global_position).normalized()
			$Sprite2D.self_modulate = windupColor

