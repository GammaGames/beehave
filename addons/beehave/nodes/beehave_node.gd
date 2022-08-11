extends BeehaveTree

class_name BeehaveNode, "../icons/action.svg"

enum { SUCCESS, FAILURE, RUNNING }

func tick(actor, blackboard):
	blackboard.get("processed").append(self)
	var result = self._tick(actor, blackboard)
	blackboard.set(self, result)
	return result

func _tick(actor, blackboard):
	pass
