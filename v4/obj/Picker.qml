Item
{
	id: picker

	height: 18
	width: 18	

	property var value: '#000000'
	property var htmlNode

	Component.onCompleted: {

		picker.dom.innerHTML = "<input type='color' " + "style='width: " + width + "px; height: " + height + "px; pointer-events: auto;' value='" + value + "'/>";

		htmlNode = picker.dom.firstChild;

		var changeHandler = function(e) {
			if (e)
				picker.value = e.target.value;
		};

		picker.dom.firstChild.onchange = changeHandler;

	}

	onValueChanged: htmlNode.value = picker.value;
}