extends BeehaveNode

class_name BeehaveDebug, "../icons/tree.svg"

export(NodePath) var beehave_tree
onready var _behave_tree := get_node(beehave_tree)
export(BeehaveRoot.PROCESS_MODE) var tree_process_mode := BeehaveRoot.PROCESS_MODE.MANUAL

export(Color) var enabled_color := Color.transparent
export(Color) var tick_color := Color.whitesmoke
export(Color) var success_color := Color.forestgreen
export(Color) var running_color := Color.royalblue
export(Color) var failure_color := Color.crimson

onready var tree : Tree
onready var root

var tree_map := {}

func _ready():
	self.tree = Tree.new()
	self.tree.anchor_left = 0
	self.tree.anchor_right = 1
	self.tree.anchor_top = 0
	self.tree.anchor_bottom = 1
	self.tree.size_flags_horizontal = self.tree.SIZE_SHRINK_END
	self.tree.hide_folding = true
	add_child(self.tree)
	
	_behave_tree.process_mode = tree_process_mode
	_behave_tree.connect("tick_start", self, "_tree_tick_start")
	self.root = self.tree.create_item()
	_add_children(self.root, _behave_tree)
	
func _input(event):
	if event.is_action_pressed("tick"):
		self._behave_tree.tick(1.0 / Engine.iterations_per_second)

func _add_children(item, node):
	tree_map[node] = item
	item.set_text(0, node.name)
	node.connect("tick_start", self, "_tick_start")
	node.connect("tick_end", self, "_tick_end")
	
	for c in node.get_children():
		var i = self.tree.create_item(item)
		self._add_children(i, c)
		
func _tree_tick_start(node):
	for node in tree_map.keys():
		var item = tree_map[node]
		item.set_custom_bg_color(0, Color.transparent)

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
