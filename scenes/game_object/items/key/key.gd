extends Item

func _ready() -> void:
	if item_data is not KeyItemData:
		printerr("Key initialized with ItemData of invalid type")
	super()
