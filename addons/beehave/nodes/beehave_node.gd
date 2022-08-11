extends BeehaveTree

class_name BeehaveNode, "../icons/action.svg"

enum { SUCCESS, FAILURE, RUNNING }

func tick(actor, blackboard):
	var result = self._tick(actor, blackboard)
	blackboard.get("processed", [], "cache").append(self)
	blackboard.set(self, result, "cache")
	
	return result

func _tick(actor, blackboard):
	pass
