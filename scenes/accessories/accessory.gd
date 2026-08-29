class_name Accessory
extends Resource

enum Category {
    NONE,
	HEAD,
	EYES,
	FACE,
	NECK,
    CHEST,
}

@export var texture: Texture2D = null
@export var color: Color = Color.BLACK

var category: Category = Category.NONE
var back_z_index: int = 0