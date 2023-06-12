extends Area2D
class_name Bird


signal score_changed(bird: Bird, new_score: int, old_score: int)
signal hit(bird: Bird)
signal died(bird: Bird)

var velocity := 0.0
var score := 0

enum {IDLE, FLYING, DYING, DIED}
var state := IDLE:
	set(value):
		state = value
		match value:
			IDLE:
				score = 0
				rotation = 0.0
				set_physics_process(false)
			FLYING:
				set_physics_process(true)
				$AnimatedSprite2D.play()
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

func _physics_process(delta):
	velocity += gravity * delta
	
	position.y += velocity * delta
	if position.y < 0:
		position.y = 0
	
	$AnimatedSprite2D.speed_scale = max(-velocity, 0) * 0.0017 + 1
	rotation = clamp(velocity * .007, -PI/2, PI/2)

func _on_area_entered(area):
	if state == FLYING:
		$HitSound.play()
		if area.is_in_group("pipes"):
			$DieSound.play()
		state = DYING
		hit.emit(self)
		if area.is_in_group("ground"):
			state = DIED
			died.emit(self)
		return
	
	if state == DYING:
		if area.is_in_group("ground"):
			state = DIED
			died.emit(self)
	

func increase_score(inc: int):
	score += inc
	$ScoreSound.play()
	score_changed.emit(self, score, score - inc)
