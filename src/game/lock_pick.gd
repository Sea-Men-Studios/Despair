extends CanvasLayer

@onready var lock_pick_area: Area2D = $LockPickArea
@onready var pin_1: Area2D = $Pin1
@onready var pin_2: Area2D = $Pin2
@onready var pin_3: Area2D = $Pin3
@onready var pin_4: Area2D = $Pin4
@onready var pin_5: Area2D = $Pin5
@onready var pin_6: Area2D = $Pin6
@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var unlock_sound: AudioStreamPlayer2D = $UnlockSound

const PICK_SPEED := 120.0
const PUSH_SMOOTHING := 12.0
const TRAVEL_SMOOTHING := 8.0
const RESET_SMOOTHING := 10.0
const SWEET_MIN_Y := 380.0
const SWEET_MAX_Y := 420.0
const SWEET_TOLERANCE := 10.0   
const MAX_Y := 340.0            


var pins: Array[Area2D] = []
var sweet_ys: Array[float] = []   
var rest_ys: Array[float] = []    
var current_pin := 0
var traveling := false
var resetting := false
var pick_target := Vector2.ZERO
var in_sweet_spot := false

func _ready() -> void:
	pins = [pin_1, pin_2, pin_3, pin_4, pin_5, pin_6]
	for pin in pins:
		rest_ys.append(pin.position.y)
	roll_sweet_spots()
	pick_target = pins[current_pin].position
	lock_pick_area.position = pick_target


func roll_sweet_spots() -> void:
	sweet_ys.clear()
	for i in pins.size():
		sweet_ys.append(randf_range(SWEET_MIN_Y, SWEET_MAX_Y))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$".".visible = false
	if event.is_action_pressed("ui_accept"):
		try_set_pin()

func is_in_sweet_spot() -> bool:
	return absf(pins[current_pin].position.y - sweet_ys[current_pin]) <= SWEET_TOLERANCE

func try_set_pin() -> void:
	if traveling or resetting or current_pin >= pins.size():
		return

	if is_in_sweet_spot():
		in_sweet_spot = false
		current_pin += 1
		if current_pin < pins.size():
			pick_target = pins[current_pin].position
			traveling = true
		else:
			unlock_sound.play()
			print("Lock opened!")
			await get_tree().create_timer(0.5).timeout
			queue_free()
	else:
		start_reset()

func start_reset() -> void:
	in_sweet_spot = false
	resetting = true
	pick_target.y = rest_ys[current_pin]


func _physics_process(delta: float) -> void:
	if current_pin >= pins.size():
		return  # lock is open

	
	if not (traveling or resetting) and Input.is_action_pressed("ui_up"):
		pick_target.y -= PICK_SPEED * delta

	var smoothing := PUSH_SMOOTHING
	if traveling:
		smoothing = TRAVEL_SMOOTHING
	elif resetting:
		smoothing = RESET_SMOOTHING

	var t := 1.0 - exp(-smoothing * delta)
	lock_pick_area.position = lock_pick_area.position.lerp(pick_target, t)

	
	if traveling:
		if lock_pick_area.position.distance_to(pick_target) < 1.0:
			lock_pick_area.position = pick_target
			traveling = false
		return

	
	var pin := pins[current_pin]
	pin.position.y = lock_pick_area.position.y

	if resetting:
		if lock_pick_area.position.distance_to(pick_target) < 1.0:
			lock_pick_area.position = pick_target
			pin.position.y = rest_ys[current_pin]
			resetting = false
		return
	var in_zone := is_in_sweet_spot()
	if in_zone and not in_sweet_spot:
		click_sound.play()
	in_sweet_spot = in_zone

	if pin.position.y <= MAX_Y:
		start_reset()
