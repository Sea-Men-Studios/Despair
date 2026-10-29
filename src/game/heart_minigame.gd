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

var can_trigger: bool = true

func _ready():
	spawn_note()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("minigame_interact") and can_trigger == true:
			heart_grow(null)
			stream_player.play()
			stream_player.get_stream_playback().start(0.33)
			can_trigger = false

func spawn_note():
	can_trigger = true
	var note: TextureRect = heart_note.instantiate()
	canvas.add_child(note)
	
	var shrink_tween = get_tree().create_tween()
	shrink_tween.tween_property(note, "size", normal_size - Vector2(10, 10), note_shrink_length)
	shrink_tween.parallel().tween_property(note, "global_position", original_position + Vector2(5, 5), note_shrink_length)
	shrink_tween.set_trans(Tween.TRANS_BOUNCE)
	shrink_tween.tween_callback(end_note.bind(shrink_tween, note))
	spawned_notes.append(note)

func end_note(tween: Tween, note: TextureRect):
	note_triggered()
	tween.stop()
	note.queue_free()
	spawned_notes.pop_at(0)
	spawn_note()

func heart_grow(object):
	if object != null: object.stop()
	
	var grow_tween = get_tree().create_tween()
	grow_tween.tween_property(heart, "size", grow_size, shrink_length)
	grow_tween.parallel().tween_property(heart, "global_position", original_position - (grow_size - normal_size) / 2, shrink_length)
	grow_tween.set_trans(Tween.TRANS_BOUNCE)
	grow_tween.tween_callback(heart_shrink.bind(grow_tween))
	
	if not spawned_notes.is_empty():
		note_triggered()

func heart_shrink(object):
	if object != null: object.stop()
	
	var shrink_tween = get_tree().create_tween()
	shrink_tween.tween_property(heart, "size", normal_size, grow_length)
	shrink_tween.parallel().tween_property(heart, "global_position", original_position, grow_length)
	shrink_tween.set_trans(Tween.TRANS_BOUNCE)
	
	stream_player.stop()

func note_triggered():
	var distance = (spawned_notes[0].size - normal_size).x
	var score: float = clamp((-0.035 * pow(distance - 92, 2) + 300), -50, 0)
	
	if can_trigger == true:
		current_score += score
		print("current score: ", current_score, "+", score, " distance: ", distance)
	
	if current_score <= 0:
		heart.modulate = Color(255, 0, 0)
