extends Composite

class_name SelectorComposite, "../../icons/selector.svg"

func tick(actor, blackboard):
	for c in get_children():
		c.emit_signal("tick_start", c)
		var response = c.tick(actor, blackboard)
		c.emit_signal("tick_end", c, response)
		
		if c is ConditionLeaf:
			blackboard.set("last_condition", c)
			blackboard.set("last_condition_status", response)

		if response != FAILURE:
			if c is ActionLeaf and response == RUNNING:
				blackboard.set("running_action", c)
			return response

	return FAILURE
