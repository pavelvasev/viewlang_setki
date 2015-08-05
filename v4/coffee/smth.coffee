
root = exports ? this

root.gen_lines = (data, scale_coeff, detail, range, options, mode) ->
	
	k_first = 0
	j_first = 0
	i_first = 0

	k_last = data.length - 1
	j_last = data[0].length - 1
	i_last = data[0][0].length - 1

	k_size = k_last - k_first
	j_size = j_last - j_first
	i_size = i_last - i_first

	k_limit = Math.ceil(data.length / detail[0]) * detail[0]
	j_limit = Math.ceil(data[0].length / detail[1]) * detail[1]
	i_limit = Math.ceil(data[0][0].length / detail[2]) * detail[2]

	calc_color = (k, j, i) ->
		
		k_coeff = (k - k_first) / k_size
		j_coeff = (j - j_first) / j_size
		i_coeff = (i - i_first) / i_size

		((0xff * k_coeff) << 16) + ((0xff * j_coeff) << 8) + (0xff * i_coeff)

	# -------- first

	for k in [k_first..k_limit] by detail[0]
		do (k) ->
			k = k_last if k > k_last
			
			for j in [j_first..j_limit] by detail[1]
				do(j) ->
					j = j_last if j > j_last

					pnts = []
					for i in [i_first..i_last]
						do (i) ->
							pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])
					
					if k in [k_first, k_last] and j in [j_first, j_last]
						width = 2.5
					else
						width = 1

					if k in [k_first, k_last] or j in [j_first, j_last]
						color = 0x000000
					else
						#color = (calc_color(k, j, i_first) + calc_color(k, j, i_last)) / 2
						color = calc_color(k, j, (i_last - i_first))/2
					
					add_line(pnts, scale_coeff, color, width)

	# -------- second

			for i in [i_first..i_limit] by detail[2]
				do(i) ->
					i = i_last if i > i_last

					pnts = []
					for j in [j_first..j_last]
						do (j) ->
							pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

					if k in [k_first, k_last] and i in [i_first, i_last]
						width = 2.5
					else
						width = 1

					if k in [k_first, k_last] or i in [i_first, i_last]
						color = 0x000000
					else
						#color = (calc_color(k, j_first, i) + calc_color(k, j_last, i)) / 2
						color = calc_color(k, (j_last - j_first) / 2, i)
					
					add_line(pnts, scale_coeff, color, width)

	# -------- third

	for j in [j_first..j_limit] by detail[1]
		do(j) ->
			j = j_last if j > j_last

			for i in [i_first..i_limit] by detail[2]
				do(i) ->
					i = i_last if i > i_last

					pnts = []
					for k in [k_first..k_last]
						do (k) ->
							pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

					if j in [j_first, j_last] and i in [i_first, i_last]
						width = 2.5
					else
						width = 1

					if j in [j_first, j_last] or i in [i_first, i_last]
						color = 0x000000
					else
						#color = ( calc_color(k_first, j, i) + calc_color(k_last, j, i) ) / 2
						color = calc_color((k_last - k_first)/2, j, i)
					
					add_line(pnts, scale_coeff, color, width)



root.gen_spheres = (data, scale_coeff, detail, range, options, mode) ->
	k_first = 0
	j_first = 0
	i_first = 0

	k_last = data.length - 1
	j_last = data[0].length - 1
	i_last = data[0][0].length - 1

	calc_color = (k, j, i) ->
		((if k == k_first then 0x00 else 0xff) << 16) + ((if j == j_first then 0x00 else 0xff) << 8) + (if i == i_first then 0x00 else 0xff)

	for k in [k_first, k_last]
		do (k) ->
			for j in [j_first, j_last]
				do (j) ->
					for i in [i_first, i_last]
						do (i) ->
							position = data[k][j][i][0..2]
							color = calc_color(k, j, i)
							add_sphere(position, scale_coeff, color, 0.1)

root.add_line = (pnts, scale_coeff, color, width = 1) ->
	pnts = ( pnt * scale_coeff for pnt in pnts )

	geometry = new THREE.BufferGeometry()
	geometry.addAttribute( 'position', new THREE.BufferAttribute( 
			new Float32Array(pnts), 3 
		) )
	geometry.computeBoundingSphere()
	material = new THREE.LineBasicMaterial({ color: color, linewidth: width })
	
	sceneObject = new THREE.Line( geometry, material )
	threejs.scene.add( sceneObject )

	obj.add( sceneObject )
	
root.add_sphere = (position, scale_coeff, color, size) ->
	geometry = new THREE.SphereBufferGeometry( size )
	material = new THREE.MeshBasicMaterial( { color: color } )
	
	sceneObject = new THREE.Mesh( geometry, material )
	threejs.scene.add( sceneObject )
	
	sceneObject.position.x = position[0] * scale_coeff
	sceneObject.position.y = position[1] * scale_coeff
	sceneObject.position.z = position[2] * scale_coeff

	obj.add( sceneObject )


root.Smth =

	init: (data, scale_coeff, detail, range, options, mode) -> 

		root.obj = new THREE.Object3D()
		
		gen_lines(data, scale_coeff, detail, range, options, mode)

		gen_spheres(data, scale_coeff, detail, range, options, mode)

		console.log("Detail: ", detail)
		console.log("Objects:", root.obj.children.length)
		console.log("ok :D")

		root.obj

console.log("Smth init")
