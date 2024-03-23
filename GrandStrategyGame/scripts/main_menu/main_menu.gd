class_name MainMenu
extends Node


signal game_started(scenario: PackedScene, rules: GameRules, players: Players)


func _on_start_game_requested(
		scenario: PackedScene,
		rules: GameRules,
		players: Players
) -> void:
	game_started.emit(scenario, rules, players)
