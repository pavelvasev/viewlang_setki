SceneObject
{
	id: gridlines

	property var data
	property var scale_coeff: 1

	property var detail: [1, 1, 1]
	// [k step, j step, i step]

	property var directions: [ true, true, true, true ]
	property var colors: [ "#000000", "#000000", "#000000", "#000000" ]
	property var options: [ false, true ]

	property var filter: []
	// [ [k first, k last, k step], 
	//   [j first, j last, j step], 
	//   [i first, i last, i step] ]

	property var filter_directions: [ true, true, true, true ]
	property var filter_colors: [ "#000000", "#000000", "#000000", "#0000ff" ]
	property var filter_options: [ false, true ]

	property var materials: []
	property var filter_materials: []

	property var filter_scalar: []

	property var filter_list: []

	property var lines

	function make3d() {

		if (!data) return; 
		
		clear();

		if ( data.length && script_grid_flag ) {

			materials = [];
			filter_materials = [];

			for ( var i = 0; i < colors.length; i++ ) {
				if (colors[i] == "#ffffff") colors[i] = "#fffffe"; // :D

				var tmp;

				if (options[0] && i < 3)
					/*tmp = new THREE.LineDashedMaterial({ 
						color: colors[i], linewidth: 1, 
						dashSize: 0.02, gapSize: 0.01 });*/
					tmp = new THREE.LineBasicMaterial({ 
						color: colors[i], linewidth: 1 });
				else
					tmp = new THREE.LineBasicMaterial({ 
						color: colors[i], linewidth: 1 });

				if (materials.length <= i)
					materials.push(tmp);
				else 
					materials[i] = tmp;
			};

			if (colors.length > 3) {
				
				var tmp;

				if (options[1])
					//tmp = new THREE.LineBasicMaterial({ 
					//	color: colors[3], linewidth: 2.5 });
					tmp = new THREE.LineBasicMaterial({ 
						color: colors[3], linewidth: 1 });
				else
					tmp = new THREE.LineBasicMaterial({ 
						color: colors[3], linewidth: 1 });
					
				if (materials.length <= 4)
					materials.push(tmp);
				else 
					materials[4] = tmp;
			}

			for ( var i = 0; i < filter_colors.length; i++ ) {
				var tmp;

				if (filter_options[0] && i < 3)
					/*tmp = new THREE.LineDashedMaterial({ 
						color: filter_colors[i], linewidth: 1, 
						dashSize: 0.02, gapSize: 0.01 });*/
					tmp = new THREE.LineBasicMaterial({ 
						color: filter_colors[i], linewidth: 1 });
				else
					tmp = new THREE.LineBasicMaterial({ 
						color: filter_colors[i], linewidth: 1 });

				if (filter_materials.length <= i)
					filter_materials.push(tmp);
				else 
					filter_materials[i] = tmp;
			};

			if (filter_colors.length > 3) {
				var tmp;

				if (filter_options[1])
					//tmp = new THREE.LineBasicMaterial({ 
					//	color: filter_colors[3], linewidth: 2.5 });
					tmp = new THREE.LineBasicMaterial({ 
						color: filter_colors[3], linewidth: 1 });
				else 
					tmp = new THREE.LineBasicMaterial({ 
						color: filter_colors[3], linewidth: 1 });
					
				if (filter_materials.length <= 4)
					filter_materials.push(tmp);
				else 
					filter_materials[4] = tmp;
			}
			
			ref = GridLines.init(
					data, scale_coeff, 
					detail, directions, materials, 
					colors, options,
					filter, filter_directions, filter_materials, 
					filter_colors, filter_options,
					filter_scalar, filter_list
				);

			this.sceneObject = ref[0];
			lines = ref[1];

			scene.add(this.sceneObject);

			this.sceneObject.visible = visible;
		}
	}

	onColorsChanged: makeLater(this);
	onOptionsChanged: makeLater(this);
	onFilter_colorsChanged: makeLater(this);
	onFilter_optionsChanged: makeLater(this);

	onDirectionsChanged: makeLater(this);
	onFilter_directionsChanged: makeLater(this);

	onDataChanged: makeLater(this);
	onDetailChanged: makeLater(this);
	onFilterChanged: makeLater(this);
	onFilter_scalarChanged: makeLater(this);
	onFilter_listChanged: makeLater(this);

	onVisibleChanged: {
		if (this.sceneObject) {
			this.sceneObject.visible = visible;
		}
	}

	function clear() {
		clearobj( this.sceneObject ); 
		this.sceneObject = undefined;

		if(lines) {

			for (var i = lines.children.length - 1; i >= 0; i--) {
				var obj = lines.children[i];

				if (obj.geometry) obj.geometry.dispose();

				obj = undefined;
			};
			
			lines = undefined;
		}
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