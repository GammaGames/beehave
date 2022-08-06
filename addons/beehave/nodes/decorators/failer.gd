extends Decorator

class_name AlwaysFailDecorator, "../../icons/fail.svg"


func tick(action, blackboard):
	for c in get_children():
		c.emit_signal("tick_start", c)
		var response = c.tick(action, blackboard)
		c.emit_signal("tick_end", c, response)
		if response == RUNNING:
			return RUNNING
		return FAILURE
