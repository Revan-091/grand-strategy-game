class_name ActionArmySplit
extends Action


var _army_id: int

# This array contains the number of troops in each army.
# So for example, [47, 53] would split an army of 100 troops
# into one army of 47 and one army of 53.
var _troop_partition: Array[int]

var _new_army_ids: Array[int]


func _init(
		army_id: int,
		troop_partition: Array[int],
		new_army_ids: Array[int]
) -> void:
	_army_id = army_id
	_troop_partition = troop_partition
	_new_army_ids = new_army_ids


func apply_to(game: Game) -> void:
	var army: Army = game.world.armies.army_with_id(_army_id)
	if not army:
		push_warning("Tried to split an army that doesn't exist")
		return
	
	# TODO bad code, shouldn't be in this class
	for army_size in _troop_partition:
		if army_size < 10:
			push_warning(
					"Tried to split an army, but at least one"
					+ " of the resulting armies was too small!"
			)
			return
	
	var number_of_clones: int = _troop_partition.size() - 1
	for i in number_of_clones:
		# Create the new army
		var _army_clone: Army = Army.quick_setup(
				game,
				_new_army_ids[i],
				_troop_partition[i + 1],
				army.owner_country(),
				army.province()
		)
		
		# Reduce the original army's troop count
		army.army_size.remove(_troop_partition[i + 1])
	
	#print(
	#		"Army ", army.id, " in province ", army.province().id,
	#		" was split into ", _new_army_ids
	#)
