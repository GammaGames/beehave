extends BeehaveTree

class_name BeehaveNode, "../icons/action.svg"

enum { SUCCESS, FAILURE, RUNNING }

signal tick_start(node)
signal tick_end(node, status)

func _tick(actor, blackboard):
	emit_signal("tick_start", self)
	var result = self.tick(actor, blackboard)
	emit_signal("tick_end", self, result)
	return result

func tick(actor, blackboard):
	pass
