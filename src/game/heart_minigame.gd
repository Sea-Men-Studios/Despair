extends Node2D

@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var heart: TextureRect = $CanvasLayer/Heart
@onready var heartbeater: TextureRect = $CanvasLayer/HeartBeatIndicator
@onready var original_position: Vector2 = heart.global_position

var normal_size: Vector2 = Vector2(140, 140)
var grow_size: Vector2 = Vector2(160, 160)

var shrink_length: float = 0.16
var grow_length: float = 0.12

var thumps: int = 0

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("minigame_interact"):
			heart_grow(null)
			stream_player.play()
			stream_player.get_stream_playback().start(0.33)

func heart_grow(object):
	if object != null: object.stop()
	
	var grow_tween = get_tree().create_tween()
	grow_tween.tween_property(heart, "size", grow_size, shrink_length)
	grow_tween.parallel().tween_property(heart, "global_position", original_position - (grow_size - normal_size) / 2, shrink_length)
	grow_tween.set_trans(Tween.TRANS_BOUNCE)
	
	thumps += 1
	
	if thumps <= 2:
		grow_tween.tween_callback(heart_shrink.bind(grow_tween))
	else:
		grow_tween.stop()
		stream_player.stop()
		thumps = 0

func heart_shrink(object):
	if object != null: object.stop()
	
	var shrink_tween = get_tree().create_tween()
	shrink_tween.tween_property(heart, "size", normal_size, grow_length)
	shrink_tween.parallel().tween_property(heart, "global_position", original_position, grow_length)
	shrink_tween.set_trans(Tween.TRANS_BOUNCE)
	shrink_tween.tween_callback(heart_grow.bind(shrink_tween))
