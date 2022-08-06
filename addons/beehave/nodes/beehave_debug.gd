extends BeehaveNode

class_name BeehaveDebug, "../icons/tree.svg"

export(NodePath) var _beehave_tree
var beehave_tree : BeehaveRoot setget set_beehave_tree

export(Color) var tick_color := Color.whitesmoke
export(Color) var success_color := Color.forestgreen
export(Color) var running_color := Color.royalblue
export(Color) var failure_color := Color.crimson

onready var tree : Tree
onready var root

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
	self.tree = Tree.new()
	self.tree.anchor_left = 0
	self.tree.anchor_right = 1
	self.tree.anchor_top = 0
	self.tree.anchor_bottom = 1
	self.tree.size_flags_horizontal = self.tree.SIZE_SHRINK_END
	self.tree.hide_folding = true
	add_child(self.tree)
	
	self.beehave_tree.connect("tick_start", self, "_tree_tick_start")
	self.root = self.tree.create_item()
	_add_children(self.root, self.beehave_tree)
	
func _add_children(item, node):
	tree_map[node] = item
	item.set_text(0, node.name)
	var icon
	if node is BeehaveRoot:
		icon = preload("../icons/tree.svg")
	elif node is SelectorComposite or node is SelectorStarComposite:
		icon = preload("../icons/selector.svg")
	elif node is SequenceComposite or node is SequenceStarComposite:
		icon = preload("../icons/sequencer.svg")
	elif node is InverterDecorator:
		icon = preload("../icons/inverter.svg")
	elif node is ConditionLeaf:
		icon = preload("../icons/condition.svg")
	elif node is ActionLeaf:
		icon = preload("../icons/action.svg")
		
	if icon:
		item.set_icon(0, icon)
	
	if not node.is_connected("tick_start", self, "_tick_start"):
		node.connect("tick_start", self, "_tick_start")
	if not node.is_connected("tick_end", self, "_tick_end"):
		node.connect("tick_end", self, "_tick_end")
	
	for c in node.get_children():
		var i = self.tree.create_item(item)
		self._add_children(i, c)

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
