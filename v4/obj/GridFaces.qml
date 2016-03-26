SceneObject
{
	id: gridfaces

	property var data
	property var scale_coeff: 1

	property var detail: [1, 1, 1]
	// [k step, j step, i step]

	property var directions: [ false, false, false, false ]
	property var colors: [ "#ffffff", "#ffffff", "#ffffff" ]
	property var options: [ 0.2 ]

	property var filter: []
	// [ [k first, k last, k step], 
	//   [j first, j last, j step], 
	//   [i first, i last, i step] ]

	property var filter_directions: [ false, false, false, true ]
	property var filter_colors: [ "#000000", "#000000", "#000000" ]
	property var filter_options: [ 0.2 ]

	property var materials: []
	property var filter_materials: []

	property var filter_scalar: []

	function make3d() {

		if (!data) return; 
		
		clear();

		if ( data.length && script_grid_flag ) {

			materials = [];
			filter_materials = [];

			for ( var i = 0; i < colors.length; i++ ) {
				
				var tmp =  new THREE.MeshBasicMaterial({ 
					color: colors[i], 
					side: THREE.FrontSide, transparent: true,
					opacity: options[0]
				} );

				if (materials.length <= i)
					materials.push(tmp);
				else 
					materials[i] = tmp;
			};

			for ( var i = 0; i < filter_colors.length; i++ ) {
				
				var tmp =  new THREE.MeshBasicMaterial({ 
					color: filter_colors[i], 
					side: THREE.FrontSide, transparent: true,
					opacity: filter_options[0]
				} );

				if (filter_materials.length <= i)
					filter_materials.push(tmp);
				else 
					filter_materials[i] = tmp;
			};

			if (directions[0] || directions[1] || directions[2] || filter.length > 0 ||
				filter_scalar.length > 0)
			{
				this.sceneObject = GridFaces.init(
						data, scale_coeff, 
						detail, directions, materials, 
						filter, filter_directions, filter_materials, filter_scalar
					);

				scene.add(this.sceneObject);

				this.sceneObject.visible = visible;
			}
		}
	}

	onColorsChanged: (colors.length > 2 && options.length)? 
		updateMaterial(): makeLater(this);
	onOptionsChanged: (colors.length > 2 && options.length)? 
		updateMaterial(): makeLater(this);
	onFilter_colorsChanged: (filter_colors.length > 2 && filter_options.length)? 
		updateMaterial(): makeLater(this);
	onFilter_optionsChanged: (filter_colors.length > 2 && filter_options.length)? 
		updateMaterial(): makeLater(this);

	function updateMaterial() {

		var obj = this.sceneObject;

		if (obj) {

			if (directions[0] || directions[1] || directions[2]) {

				for (var i = obj.children.length - 1; i >= 0; i--) {
					
					var item = obj.children[i];

					var n = item.name;
					var tmp = item.material;

					if (colors.length + filter_colors.length <= n) {
						makeLater(this);
						return;
					}

					if (filter.length < 3 && 
						(!directions[0] && !directions[1] && directions[2])) {
						mat_colors = [colors[2], colors[0], colors[1]];
					} else if (filter.length < 3 && directions[1] && (!directions[0])) {
						mat_colors = [colors[1], colors[2], colors[0]];
					} else { 
						mat_colors = [colors[0], colors[1], colors[2]];
					}

					item.material = new THREE.MeshBasicMaterial({ 
						color: (n < 3)? mat_colors[n]: filter_colors[n - 3], 
						side: THREE.FrontSide, transparent: true,
						opacity: (n < 3)? options[0]: filter_options[0]
					} );

					if (tmp) tmp.dispose();
				}
			} else {

				for (var i = obj.children.length - 1; i >= 0; i--) {
					
					var item = obj.children[i];

					var n = item.name;
					var tmp = item.material;

					if (filter_colors.length <= n) {
						makeLater(this);
						return;
					}

					item.material = new THREE.MeshBasicMaterial({ 
						color: filter_colors[n], 
						side: THREE.FrontSide, transparent: true,
						opacity: filter_options[0]
					} );

					if (tmp) tmp.dispose();
				}
			}

		}
	}

	onDirectionsChanged: makeLater(this);
	onFilter_directionsChanged: makeLater(this);

	onDataChanged: makeLater(this);
	onDetailChanged: makeLater(this);
	onFilterChanged: makeLater(this);
	onFilter_scalarChanged: makeLater(this);

	onVisibleChanged: {
		if (this.sceneObject) {
			this.sceneObject.visible = visible;
		}
	}

	function clear() {
		clearobj( this.sceneObject ); 
		this.sceneObject = undefined;
	}
	
	function clearobj(obj) {
		if (obj) {
			
			for (var i = obj.children.length - 1; i >= 0; i--) {
				item = obj.children[i];
				scene.remove( item );
				if (item.geometry) item.geometry.dispose();
				if (item.material) item.material.dispose();
				if (item.texture) item.texture.dispose();

				item = undefined;
			}

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
}