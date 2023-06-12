extends CanvasLayer


var score

func update_score(score: int):
	$Score.text = str(score)
