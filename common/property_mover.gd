class_name PropertyMover extends Node2D


var cycle_time: float = 0.0
var cycle_offset: float = 0.0
var property_movement_specs: Array[PropertyMoverSpecifier]
var cycler: Timer
var target_node
var base_position: Vector2
var correction_required: float = 0.0

func _ready() -> void:
	base_position = global_position
	build_timer.call_deferred()


func build_timer() -> void:
	cycler = Timer.new()
	cycler.wait_time = cycle_time
	cycler.one_shot = false
	add_child(cycler)
	correction_required = cycle_time - (cycle_offset * cycle_time)
	cycler.start(cycle_offset * cycle_time)
	cycler.timeout.connect(_check_for_correction)


func _physics_process(delta: float):
	if target_node == null or cycler == null:
		return
	var target_val: float
	var curve_val: float
	var time_val: float
	var target_name: String
	var target_prop: StringName
	var new_vals: Array[float]
	var curr_base_position: Vector2 = Vector2.ZERO
	for property_spec in property_movement_specs:
		new_vals = []
		target_name = PropertyMoverSpecifier.SupportedProperties.keys()[property_spec.property_name].to_lower()
		target_prop = StringName(target_name)
		time_val = (cycle_time - cycler.time_left) / cycle_time
		#print("TIME VAL IS ", str(cycle_time), " MINUS ", str(cycler.time_left), " PLUS ", str(correction_required))
		#print("TIME VAL IS ", str(cycle_time), " MINUS ", str(cycler.time_left))
		if not "global" in target_name:
			curr_base_position = base_position
		for sub_component in property_spec.sub_components:
			curve_val = sub_component.specification.sample(time_val)
			
			target_val = sub_component.property_min + (
				(sub_component.property_max - sub_component.property_min) * curve_val
				)
			new_vals.append(target_val)
		if len(new_vals) == 0:
			push_error("Zero dimension property received for ", target_prop, " of ", str(target_node))
		elif len(new_vals) == 1:
			target_node.set(target_prop, new_vals[0])
		elif len(new_vals) == 2:
			target_node.set(target_prop, Vector2(new_vals[0], new_vals[1]) + curr_base_position)
		else:
			push_error("More than 2 dimensions for ", target_prop, " of ", str(target_node), ". Not supported!")


func _check_for_correction() -> void:
	if correction_required != 0:
		cycler.start(cycle_time)
		correction_required = 0
