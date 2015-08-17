SceneObject
{
	id: smth

	property var data
	property var scale_coeff: 1
	property var detail: [1, 1, 1]
	property var modes: []

	property var range: [] 
	property var range_modes: []

	function make3d() {

		if (!data) return; 
		
		clear();

		if ( data.length && script_flag ) {

			this.sceneObject = Smth.init(
					data, scale_coeff, 
					detail, modes, 
					range, range_modes
				);

			scene.add(this.sceneObject);

			this.sceneObject.visible = visible;
		}
	}

	onDataChanged: makeLater(this);

	onVisibleChanged: {
		if (this.sceneObject) {
			this.sceneObject.visible = visible;
		}
	}

	onDetailChanged: makeLater(this);

	onModesChanged: makeLater(this);

	function clear() {
		clearobj( this.sceneObject ); 
		this.sceneObject = undefined;
	}
	
	function clearobj(obj) {
		if (obj) {

			scene.remove( obj );
			if (obj.geometry) obj.geometry.dispose();
			if (obj.material) obj.material.dispose();
			if (obj.texture) obj.texture.dispose();
		}
	}

	Component.onCompleted: {
		console.log("my component created" );
	}

	Component.onDestruction: {
		clear();

		console.log("my component deleted" );
	}
}