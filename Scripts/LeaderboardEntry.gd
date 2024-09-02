class_name LeaderboardEntry
extends MarginContainer


func setup(place: int, player_name: String, score: int) -> void:
	var place_label: Label = %"Place Label"
	var name_label: Label = %"Name Label"
	var score_label: Label = %"Score Label"
	
	place_label.text = str(place) + "."
	name_label.text = player_name
	score_label.text = str(score)
