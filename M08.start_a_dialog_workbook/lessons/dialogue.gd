extends Control

var expressions := {
	"happy": preload ("res://assets/emotion_happy.png"),
	"regular": preload ("res://assets/emotion_regular.png"),
	"sad": preload ("res://assets/emotion_sad.png"),
}

var bodies := {
	"sophia": preload ("res://assets/sophia.png"),
	"pink": preload ("res://assets/pink.png")
}

var dialogue_items: Array[Dictionary] = [
	{
		"expression": expressions["regular"],
		"text": "Who's the goat[wave]",
		"character": bodies["sophia"],
		"choices": {
			"jayden h": 1,
			"noah g": 3,
		}
	},
	{
		"expression": expressions["regular"],
		"text": "No. Jayden H is not the goat",
		"character": bodies["pink"],
		"choices": {
			"It's obviously Noah G": 3,
			"No its Jayden H": 2,
		}
	},
	{
		"expression": expressions["sad"],
		"text": "I said [shake]it's Noah G[/shake]!",
		"character": bodies["sophia"],
		"choices":{
			"I've been saying it was Noah G": 0,
			"It's Jayden H wdym": 1,
		}
	},
	{
		"expression": expressions["sad"],
		"text": "It's Noah G cause the G stands for Goat ofcourse",
		"character": bodies["pink"],
		"choices": {"Told you so (Quit)": -1}
	},
]


@onready var rich_text_label: RichTextLabel = %RichTextLabel
@onready var action_buttons_v_box_container: VBoxContainer = %ActionButtonsVBoxContainer
## Audio player that plays voice sounds while text is being written
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
## The character
@onready var body: TextureRect = %Body
## The Expression
@onready var expression: TextureRect = %Expression


func _ready() -> void:
	show_text(0)

func create_buttons(choices_data: Dictionary) -> void:
	for button in action_buttons_v_box_container.get_children():
		button.queue_free()
	for choice_text in choices_data:
		var button := Button.new()
		action_buttons_v_box_container.add_child(button)
		button.text = choice_text
		var target_line_idx: int = choices_data[choice_text]
		if target_line_idx == - 1:
			button.pressed.connect(get_tree().quit)
		else:
			button.pressed.connect(show_text.bind(target_line_idx))

func show_text(current_item_index: int) -> void:
	var current_item := dialogue_items[current_item_index]
	rich_text_label.text = current_item["text"]
	expression.texture = current_item["expression"]
	body.texture = current_item["character"]
	create_buttons(current_item["choices"])
	rich_text_label.visible_ratio = 0.0
	var tween := create_tween()
	var text_appearing_duration: float = current_item["text"].length() / 30.0
	tween.tween_property(rich_text_label, "visible_ratio", 1.0, text_appearing_duration)
	var sound_max_offset := audio_stream_player.stream.get_length() - text_appearing_duration
	var sound_start_position := randf() * sound_max_offset
	audio_stream_player.play(sound_start_position)
	tween.finished.connect(audio_stream_player.stop)
	
	slide_in()
	
func slide_in() -> void:
	var slide_tween := create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	body.position.x = get_viewport_rect().size.x / 7
	slide_tween.tween_property(body, "position:x", 0, 0.3)
	body.modulate.a = 0
	slide_tween.parallel().tween_property(body, "modulate:a", 1, 0.2)
