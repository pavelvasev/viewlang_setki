SceneObject
{
	id: gridfaces

	property var data
	property var scale_coeff: 1

	property var detail: [1, 1, 1]
	property var style: []
	property var filter: []
	property var fstyle: []

	function make3d() {

		if (!data) return; 
		
		clear();

		if ( data.length && script_grid_flag ) {

			this.sceneObject = GridFaces.init(
					data, scale_coeff, 
					detail, style,
					filter, fstyle
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
	onStyleChanged: makeLater(this);
	onFilterChanged: makeLater(this);
	onFstyleChanged: makeLater(this);

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