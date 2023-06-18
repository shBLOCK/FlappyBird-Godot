extends Area2D
class_name Bird


static var SPEED := 70.0

signal score_changed(bird: Bird, new_score: int, old_score: int)
signal hit(bird: Bird)
signal died(bird: Bird)

var velocity := 0.0
var score := 0

var time := 0.0

enum {IDLE, FLYING, DYING, DIED}
var state := IDLE:
	set(value):
		state = value
		match value:
			IDLE:
				score = 0
				rotation = 0.0
				position.x = 0.0
				set_physics_process(true)
				$AnimatedSprite2D.play()
			FLYING:
				pass
			DYING:
				$AnimatedSprite2D.stop()
			DIED:
				velocity = 0.0
				set_physics_process(false)

func _ready():
	state = IDLE

func flap():
	velocity = -170
	$WingSound.play()

func _unhandled_input(event):
	if state != FLYING:
		return
	if event.is_action_pressed("flap"):
		flap()

var _target_rotation := 0.0

func _physics_process(delta):
	if state == FLYING or state == DYING:
		velocity += gravity * delta
		position.y += (velocity if $VisibleOnScreenDetector.is_on_screen() else max(0, velocity)) * delta
	
	_target_rotation = clamp(velocity * .006, -PI/2, PI/2)
#	_target_rotation = atan2(velocity, 200)
	
	rotation = lerpf(rotation, _target_rotation, delta * 18.0)
	
	if state == IDLE or state == FLYING:
		position.x += SPEED * delta

func _process(delta):
	time += delta
	
	$AnimatedSprite2D.speed_scale = max(-velocity, 0) * 0.007 + 1
	
	if state == IDLE:
		position.y = sin(time * PI) * 5

func _on_area_entered(area):
	match state:
		FLYING:
			$HitSound.play()
			if not area.is_in_group("ground"):
				$DieSound.play()
			state = DYING
			hit.emit(self)
			if area.is_in_group("ground"):
				state = DIED
				died.emit(self)
		DYING:
			if area.is_in_group("ground"):
				state = DIED
				died.emit(self)
	

func increase_score(inc: int):
	score += inc
	$ScoreSound.play()
	score_changed.emit(self, score, score - inc)
