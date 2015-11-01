SceneObjectThreeJs
{
	id: gridpoints

	property var data
	property var scale_coeff: 1
	property var variable: ""
	property var min: []
	property var max: []
	property var index: 0
	property var colors: ["#000000", "#ffffff"]
	property var radius: 0.25

	function make3d() {

		if (!data) return; 
		
		clear();

		if ( data.length && variable != "" && 
			parseInt(variable) + 3 <= data[0][0][0].length ) {

			this.sceneObject = GridPoints.init(
					data, scale_coeff, variable, min, max, index, colors, radius
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

	onRadiusChanged: {
		if (!this.sceneObject || !this.sceneObject.material) return;
		this.sceneObject.material.size = radius;
		this.sceneObject.material.needsUpdate = true;
    }

    onDataChanged: makeLater(this);

    onVariableChanged: makeLater(this);

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

			obj = undefined;
		}
	}

	Component.onCompleted: {
		console.log("my component created" );
	}

	Component.onDestruction: {
		clear();

		console.log("my component deleted" );
	}

	function intersect( pos ) {
		if (!this.sceneObject) return null;

		raycaster.params.PointCloud.threshold = this.sceneObject.radius ? 
			this.sceneObject.radius / 4: 0.1;
		
		raycaster.setFromCamera( pos, camera );
		
		var intersects = raycaster.intersectObject( this.sceneObject,false );
		
		return (intersects.length == 0)? null: intersects[0];
	} 
}