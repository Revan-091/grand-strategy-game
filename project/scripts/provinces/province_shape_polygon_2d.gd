class_name ProvinceShapePolygon2D
extends Polygon2D
## A [Province]'s shape.
## It can draw an outline of your choice around the drawn polygon.
## Emits a signal when the shape is clicked by the user.
##
## See this page for more info:
## https://godotengine.org/qa/3963/is-it-possible-to-have-a-polygon2d-with-outline


signal clicked()

enum OutlineType {
	NONE = 0,
	SELECTED = 1,
	NEIGHBOR_TARGET = 2,
	NEIGHBOR = 3,
}

@export var province: Province

@export var outline_color := Color.WEB_GRAY:
	set(value):
		outline_color = value
		queue_redraw()

@export var outline_width: float = 10.0:
	set(value):
		outline_width = value
		queue_redraw()

var _outline_type: OutlineType = OutlineType.NONE:
	set(value):
		_outline_type = value
		queue_redraw()


func _ready() -> void:
	if not province:
		print_debug("Province shape doesn't have reference to province!")
		return
	
	province.owner_changed.connect(_on_owner_changed)
	_on_owner_changed(province.owner_country)
	province.selected.connect(_on_selected)
	province.deselected.connect(_on_deselected)
	for link in province.links:
		link.selected.connect(_on_link_selected)
		link.deselected.connect(_on_deselected)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if (
				event_typed.pressed
				and not event_typed.is_echo()
				and event_typed.button_index == MOUSE_BUTTON_LEFT
		):
			var mouse_position: Vector2 = get_viewport().get_mouse_position()
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position_in_world: Vector2 = (
					(mouse_position - get_viewport_rect().size * 0.5)
					/ camera.zoom
					+ camera.get_screen_center_position()
			)
			var local_mouse_position: Vector2 = (
					mouse_position_in_world - global_position
			)
			if Geometry2D.is_point_in_polygon(local_mouse_position, polygon):
				get_viewport().set_input_as_handled()
				clicked.emit()


func _draw() -> void:
	match _outline_type:
		OutlineType.NONE:
			pass
		OutlineType.SELECTED:
			_draw_outline(get_polygon(), outline_color, outline_width)
		OutlineType.NEIGHBOR_TARGET:
			_draw_outline(get_polygon(), outline_color, outline_width * 0.8)
		OutlineType.NEIGHBOR:
			_draw_outline(get_polygon(), outline_color, outline_width * 0.5)


func _draw_outline(
		poly: PackedVector2Array,
		ocolor: Color,
		width: float
) -> void:
	var radius: float = width * 0.5
	draw_circle(poly[0], radius, ocolor)
	for i in range(1, poly.size()):
		draw_line(poly[i - 1], poly[i], ocolor, width)
		draw_circle(poly[i], radius, ocolor)
	draw_line(poly[poly.size() - 1], poly[0], ocolor, width)


func _on_owner_changed(country: Country) -> void:
	if country:
		color = country.color
	else:
		color = Color.WHITE


func _on_selected(_can_target_links: bool) -> void:
	_outline_type = ProvinceShapePolygon2D.OutlineType.SELECTED


func _on_link_selected(can_target_links: bool) -> void:
	if can_target_links:
		_outline_type = ProvinceShapePolygon2D.OutlineType.NEIGHBOR_TARGET
	else:
		_outline_type = ProvinceShapePolygon2D.OutlineType.NEIGHBOR


func _on_deselected() -> void:
	_outline_type = ProvinceShapePolygon2D.OutlineType.NONE
