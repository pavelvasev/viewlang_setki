SceneObject
{
	property var r: 40
	
	property var x_text: "X"
	property var y_text: "Y"
	property var z_text: "Z"

	property var font: "Normal 14pt Arial";

	property var axis_obj

	property var caption_obj_x
	property var caption_obj_y
	property var caption_obj_z

	visible: true

	function make3d() {
		
		clear();

		var mat = new THREE.LineDashedMaterial({ 
			color: "#000000", linewidth: 1 });

		var line_x = new_line([-r, 0, 0, r, 0, 0], mat);
		var line_y = new_line([0, -r, 0, 0, r, 0], mat);
		var line_z = new_line([0, 0, -r, 0, 0, r], mat);

		this.sceneObject = new THREE.Object3D();

		this.sceneObject.add( line_x );
		this.sceneObject.add( line_y );
		this.sceneObject.add( line_z );

		scene.add(this.sceneObject);

		var bas_mat = new THREE.LineBasicMaterial({ 
			color: "#000000", linewidth: 1 });

		var pnts;

		pnts = [];
		for(var i = -r; i < r; i += 3)
			pnts.push(i, 0, 0, i + 2, 0, 0);

		line_x = new_line(pnts, bas_mat);

		pnts = [];
		for(var i = -r; i < r; i += 3)
			pnts.push(0, i, 0, 0, i + 2, 0);

		line_y = new_line(pnts, bas_mat);
		
		pnts = [];
		for(var i = -r; i < r; i += 3)
			pnts.push(0, 0, i, 0, 0, i + 2);

		line_z = new_line(pnts, bas_mat);

		axis_obj = new THREE.Object3D();

		axis_obj.add( line_x );
		axis_obj.add( line_y );
		axis_obj.add( line_z );

		caption_obj_x = new_sprite(x_text, r - 1, -2, 0);
		caption_obj_y = new_sprite(y_text, 0, r - 2, -1);
		caption_obj_z = new_sprite(z_text, 0, -2, r - 1);

		this.sceneObject.add( caption_obj_x );
		this.sceneObject.add( caption_obj_y );
		this.sceneObject.add( caption_obj_z );

		this.sceneObject.visible = visible;
	}

	function new_sprite(text, position_x, position_y, position_z) {

		var caption_canvas = document.createElement('canvas');
		var context = caption_canvas.getContext('2d');

		caption_canvas.width = 256;
		caption_canvas.height = 64;

		context.font = font;
		context.textAlign = "center";
		context.fillStyle = "rgba(0, 0, 0, 1.0)";
		context.fillText( text, 128, 30 );

		var texture = new THREE.Texture(caption_canvas);
		texture.needsUpdate = true;

		var spriteMaterial = new THREE.SpriteMaterial( { map: texture } );
		var sprite = new THREE.Sprite( spriteMaterial );
		sprite.scale.set(caption_canvas.width / 10, caption_canvas.height / 10, 1.0);
		sprite.position.set(position_x, position_y, position_z);

		return sprite;
	}

	function new_line(pnts, material) {
		
		var geometry = new THREE.BufferGeometry()

		geometry.setAttribute( 'position', new THREE.BufferAttribute( 
				new Float32Array(pnts), 3 
			) )
		
		geometry.computeBoundingSphere();

		var lines = new THREE.LineSegments( geometry, material );
		lines.computeLineDistances();
		return lines;
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

	onVisibleChanged: {
		if (this.sceneObject) {
			this.sceneObject.visible = visible;
		}
	}

	onX_textChanged: { makeLater(this); }
	onY_textChanged: { makeLater(this); }
	onZ_textChanged: { makeLater(this); }

	onFontChanged: { makeLater(this); }

	Component.onCompleted: {
		console.log("my component created" );
	}

	Component.onDestruction: {
		clear();

		console.log("my component deleted" );
	}
}
