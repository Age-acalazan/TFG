extends VBoxContainer

const SAVE_PATH := "user://leaderboard.json"

func save_score(score: int):
	var leaderboard := []
	var file : FileAccess

	#Lee el archivo si existe
	if FileAccess.file_exists(SAVE_PATH):
		file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var content = file.get_as_text()
		file.close()

		var parsed = JSON.parse_string(content)
		if parsed is Array:
			leaderboard = parsed

	#Crea una nueva entrada
	var datetime := Time.get_datetime_string_from_system()
	var entry := {
		"score": score,
		"datetime": datetime
	}
	leaderboard.append(entry)

	#Guarda en el archivo de vuelta
	file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(leaderboard, "\t"))
	file.close()

func load_leaderboard() -> Array:
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		return parsed
	
	return []

func format_datetime(iso_string: String):
	var dt = Time.get_datetime_dict_from_datetime_string(iso_string,false)
	return "%04d-%02d-%02d %02d:%02d" % [
		dt.year,
		dt.month,
		dt.day,
		dt.hour,
		dt.minute
	]

func show_leaderboard():
	var leaderboard = load_leaderboard()

	leaderboard.sort_custom(func(a, b):
		return a["score"] > b["score"]
	)
	var score_nodes := get_children()
	var i = 0
	for entry in leaderboard:
		score_nodes[i].text = " Puntos: " + str(int(entry["score"])) +" | Fecha: " +format_datetime(str(entry["datetime"]))
		i +=1
		if i >= 10:
			break
