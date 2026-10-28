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

	print(chargeWindup, " ", chargeMaxTime, " ", chargeRecover, " ", wanderDuration, " ", stunDuration)

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
		BossStates.CHARGING:
			bossTimer = chargeMaxTime
			chargeElapsed = 0.0
		BossStates.STUNNED:
			bossTimer = stunDuration
			$Sprite2D.self_modulate = stunColor
		BossStates.RECOVER:
			bossTimer = chargeRecover
		BossStates.SHOOT:
			shotsLeft = burstCount
			shotTimer = 0.3

func pickAttack():
	return [BossStates.CHARGE_WINDUP, BossStates.SHOOT].pick_random()

func _physics_process(delta):
	updatePlayer()
	bossTimer -= delta

	var desired = Vector2.ZERO

	match bossState:
		BossStates.WANDER:
			bossWanderTimer -= delta

			if bossWanderTimer <= 0.0 or is_on_wall():
				bossMoveDir = Vector2.from_angle(randf() * TAU)
				
				bossWanderTimer = 0.6

			desired = bossMoveDir * wanderSpeed
			
			if bossTimer <= 0.0:
				changeState(pickAttack())
		BossStates.CHARGE_WINDUP:
			if bossTimer <= 0.0:
				changeState(BossStates.CHARGING)
		BossStates.CHARGING:
			chargeElapsed += delta

			desired = chargeDir * chargeSpeed

			if chargeElapsed > 0.1 and is_on_wall():
				changeState(BossStates.STUNNED)
			elif bossTimer <= 0.0:
				changeState(BossStates.RECOVER)
		BossStates.STUNNED:
			if bossTimer <= 0.0:
				changeState(BossStates.WANDER)
		BossStates.RECOVER:
			if bossTimer <= 0.0:
				changeState(BossStates.WANDER)
		BossStates.SHOOT:
			shotTimer -= delta

			if shotsLeft > 0 and shotTimer <= 0.0:
				shoot()
				shotsLeft -= 1
				shotTimer = burstDelay
			if shotsLeft == 0 and shotTimer <= 0.0:
				changeState(BossStates.WANDER)
	
	knockbackVelocity = knockbackVelocity.move_toward(Vector2.ZERO, knockbackFriction * delta)

	velocity = desired + knockbackVelocity * (1.0 - knockbackResistance)

	move_and_slide()

	var harmless = bossState == BossStates.RECOVER or bossState == BossStates.STUNNED
	
	if not harmless:
		checkContactDamage(delta)
