extends Node2D

@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var heart: TextureRect = $CanvasLayer/Heart
@onready var heart_note: PackedScene = load("res://scenes/ui/heart_beat_note.tscn")
@onready var original_position: Vector2 = heart.global_position
@onready var canvas: CanvasLayer = $CanvasLayer

var normal_size: Vector2 = Vector2(140, 140)
var grow_size: Vector2 = Vector2(160, 160)

var shrink_length: float = 0.16
var grow_length: float = 0.12

var note_shrink_length: float = 1.5
var spawned_notes: Array = []

var current_score: float = 150

var cancel_fail: bool = false

func _ready():
	while true:
		spawn_note()
		await get_tree().create_timer(2).timeout

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("minigame_interact"):
			heart_grow(null)
			stream_player.play()
			stream_player.get_stream_playback().start(0.33)

func spawn_note():
	cancel_fail = false
	
	var note: TextureRect = heart_note.instantiate()
	canvas.add_child(note)
	
	var shrink_tween = get_tree().create_tween()
	shrink_tween.tween_property(note, "size", normal_size - Vector2(5, 5), note_shrink_length)
	shrink_tween.parallel().tween_property(note, "global_position", original_position + Vector2(2.5, 2.5), note_shrink_length)
	shrink_tween.set_trans(Tween.TRANS_BOUNCE)
	shrink_tween.tween_callback(note_trigger_fail)
	spawned_notes.append([note, shrink_tween])

func heart_grow(object):
	if object != null: object.stop()
	
	var grow_tween = get_tree().create_tween()
	grow_tween.tween_property(heart, "size", grow_size, shrink_length)
	grow_tween.parallel().tween_property(heart, "global_position", original_position - (grow_size - normal_size) / 2, shrink_length)
	grow_tween.set_trans(Tween.TRANS_BOUNCE)
	grow_tween.tween_callback(heart_shrink.bind(grow_tween))
	
	note_trigger()

func heart_shrink(object):
	if object != null: object.stop()
	
	var shrink_tween = get_tree().create_tween()
	shrink_tween.tween_property(heart, "size", normal_size, grow_length)
	shrink_tween.parallel().tween_property(heart, "global_position", original_position, grow_length)
	shrink_tween.set_trans(Tween.TRANS_BOUNCE)
	
	stream_player.stop()

func note_trigger():
	if not spawned_notes.is_empty():
		var distance = (spawned_notes[0][0].size - normal_size).x
		var score: float = clamp((-0.0016 * pow(distance - 18.4, 2) + 1), -50, 0)
		
		current_score += score
		
		cancel_fail = true
		
		var disappear_tween = get_tree().create_tween()
		disappear_tween.tween_property(spawned_notes[0][0], "modulate", Color(1, 1, 1, 0), shrink_length)
		disappear_tween.set_ease(Tween.EASE_OUT)
		disappear_tween.tween_callback(delete_note)
	else:
		current_score -= 25
	
	check_score()

func note_trigger_fail():
	if cancel_fail == false:
		current_score -= 50
		
		delete_note()
		
		check_score()

func delete_note():
	if not spawned_notes.is_empty():
		spawned_notes[0][1].stop()
		spawned_notes[0][0].queue_free()
		spawned_notes.pop_at(0)

func check_score():
	heart.modulate = Color(1, (255-(150-current_score))/255, (255-(150-current_score))/255)
	
	if current_score <= 0:
		print("die")
