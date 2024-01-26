class_name GameSaveJSON
extends GameSave
# See: https://www.gdquest.com/tutorial/godot/best-practices/save-game-formats/


func save_state(game_state: GameState) -> int:
	var file: FileAccess = FileAccess.open(_file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(game_state.as_json(), "\t"))
	file.close()
	return OK


func load_state(game_mediator: GameMediator) -> GameState:
	var file: FileAccess = FileAccess.open(_file_path, FileAccess.READ)
	var json := JSON.new()
	var error: int = json.parse(file.get_as_text(true))
	file.close()
	
	if error != OK:
		push_error("Failed to load JSON save file")
		return null
	
	if not json.data is Dictionary:
		return null
	
	var builder := GameStateFromJSON.new(json.data as Dictionary)
	error = builder.build(game_mediator)
	
	if error != OK:
		return null
	
	return builder.game_state
