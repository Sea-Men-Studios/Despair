extends CanvasLayer

@onready var lock_pick_area: Area2D = $LockPickArea
@onready var pin_1: Area2D = $Pin1
@onready var pin_2: Area2D = $Pin2
@onready var pin_3: Area2D = $Pin3
@onready var pin_4: Area2D = $Pin4
@onready var pin_5: Area2D = $Pin5
@onready var pin_6: Area2D = $Pin6

const PICK_SPEED := 120.0        # how fast the target rises while W is held
const PUSH_SMOOTHING := 12.0     # pick catching up to the target while pushing
const TRAVEL_SMOOTHING := 8.0    # pick gliding to the next pin
const MIN_TARGET_Y := 380.0
const MAX_TARGET_Y := 420.0

var pins: Array[Area2D] = []
var target_ys: Array[float] = []
var current_pin := 0
var traveling := false
var pick_target := Vector2.ZERO


func _ready() -> void:
	pins = [pin_1, pin_2, pin_3, pin_4, pin_5, pin_6]
	lets_go_gambling()
	pick_target = pins[current_pin].position
	lock_pick_area.position = pick_target

func lets_go_gambling() -> void:
	target_ys.clear()
	for i in pins.size():
		target_ys.append(randf_range(MIN_TARGET_Y, MAX_TARGET_Y))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _physics_process(delta: float) -> void:
	if current_pin >= pins.size():
		return  # lock is open

	
	if not traveling and Input.is_action_pressed("forwards"):
		pick_target.y -= PICK_SPEED * delta

	
	var smoothing := TRAVEL_SMOOTHING if traveling else PUSH_SMOOTHING
	var t := 1.0 - exp(-smoothing * delta)
	lock_pick_area.position = lock_pick_area.position.lerp(pick_target, t)

	if traveling:
		
		if lock_pick_area.position.distance_to(pick_target) < 1.0:
			lock_pick_area.position = pick_target
			traveling = false
		return  

	
	var pin := pins[current_pin]
	pin.position.y = lock_pick_area.position.y

	if pin.position.y <= target_ys[current_pin]:
		pin.position.y = target_ys[current_pin]
		current_pin += 1
		if current_pin < pins.size():
			pick_target = pins[current_pin].position  
			traveling = true
		else:
			print("Lock opened!")
