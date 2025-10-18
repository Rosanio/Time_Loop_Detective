extends DialogContextResolver

func GetDialogForCurrentContext():
	var dialog = [
		{
			"type": 'basic',
			"text": "It's a nice day isn't it?"
		},
		{
			"type": 'prompt',
			"text": "What do you like to do on days like this?",
			"options": [
				"Ride my bike",
				"Stay inside",
				"Beat up random girls who pass me on the street"
			]
		},
		{
			"type": 'prompt-response',
			"options": [
				"Wow me too!",
				"Oh...",
				"Ahhhh! Someone help!"
			]
		}
	]
	dialogManager.show_dialog(dialog)
