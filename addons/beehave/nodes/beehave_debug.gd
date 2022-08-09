extends BeehaveNode

class_name BeehaveDebug, "../icons/tree.svg"

export(NodePath) var _beehave_tree
var beehave_tree : BeehaveRoot setget set_beehave_tree

export(Theme) var theme
export(Color) var tick_color := Color.whitesmoke
export(Color) var success_color := Color.forestgreen
export(Color) var running_color := Color.royalblue
export(Color) var failure_color := Color.crimson

var tree : Tree
var tree_map := {}

func _ready():
	if self._beehave_tree:
		self.beehave_tree = get_node(self._beehave_tree)

func set_beehave_tree(value):
	if beehave_tree != value:
		if self.beehave_tree:
			self.beehave_tree.disconnect("tick_start", self, "_tree_tick_start")

		beehave_tree = value
		generate_tree()

func generate_tree():
	if self.tree:
		remove_child(self.tree)

	for node in self.tree_map.keys():
		node.disconnect("tick_start", self, "_tick_start")
		node.disconnect("tick_end", self, "_tick_end")

	self.tree_map = {}
	self.tree = self._create_tree()
	add_child(self.tree)

	self.beehave_tree.connect("tick_start", self, "_tree_tick_start")
	_add_children(self.tree.create_item(), self.beehave_tree)

func _create_tree():
	var tree := Tree.new()
	tree.anchor_left = 0
	tree.anchor_right = 1
	tree.anchor_top = 0
	tree.anchor_bottom = 1
	tree.hide_folding = true
	if self.theme:
		tree.theme = self.theme

	return tree

func _add_children(item, node):
	tree_map[node] = item
	item.set_text(0, node.name)

	item.set_icon(0, self._get_icon(node))

	if not node.is_connected("tick_start", self, "_tick_start"):
		node.connect("tick_start", self, "_tick_start")
	if not node.is_connected("tick_end", self, "_tick_end"):
		node.connect("tick_end", self, "_tick_end")

	for c in node.get_children():
		if c is BeehaveTree:
			var i = self.tree.create_item(item)
			self._add_children(i, c)

func _get_icon(node):
	var icon
	if node is BeehaveRoot:
		icon = preload("../icons/tree.svg")
	elif node is Composite:
		if node is SelectorComposite:
			icon = preload("../icons/selector.svg")
		elif node is SelectorStarComposite:
			icon = preload("../icons/selector.svg")
		elif node is SequenceComposite:
			icon = preload("../icons/sequencer.svg")
		elif node is SequenceStarComposite:
			icon = preload("../icons/sequencer.svg")
		else:
			icon = preload("../icons/category_composite.svg")
	elif node is Decorator:
		if node is InverterDecorator:
			icon = preload("../icons/inverter.svg")
		else:
			icon = preload("../icons/category_decorator.svg")
	elif node is ActionLeaf:
		icon = preload("../icons/action.svg")
	elif node is ConditionLeaf:
		icon = preload("../icons/condition.svg")

	return icon

func _input(event):
	if self.beehave_tree and event.is_action_pressed("tick"):
		self.beehave_tree.tick(1.0 / Engine.iterations_per_second)

func _tree_tick_start(node):
	for node in tree_map.keys():
		var item = tree_map[node]
		item.clear_custom_bg_color(0)

func _tick_start(node):
	var item = tree_map[node]
	item.set_custom_bg_color(0, self.tick_color)

func _tick_end(node, status):
	var item = tree_map[node]
	match status:
		SUCCESS:
			item.set_custom_bg_color(0, self.success_color)
		FAILURE:
			item.set_custom_bg_color(0, self.failure_color)
		RUNNING:
			item.set_custom_bg_color(0, self.running_color)
