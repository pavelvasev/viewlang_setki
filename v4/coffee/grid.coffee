
root = exports ? this

root.gen_lines = (data, scale_coeff, detail, style, filter, filter_style) ->

	k_size = k_last - k_first
	j_size = j_last - j_first
	i_size = i_last - i_first

	k_limit = Math.ceil(data.length / detail[0]) * detail[0]
	j_limit = Math.ceil(data[0].length / detail[1]) * detail[1]
	i_limit = Math.ceil(data[0][0].length / detail[2]) * detail[2]

	if style.length < 3
		style = [[], [], []]

	if style[0].length < 3
		style[0] = [true, true, true]

	if style[1].length < 3
		calc_color = (dir, k, j, i) ->

			i_coeff = if dir == 1 then 0x88 else (i - k_first) / i_size * 0xff
			j_coeff = if dir == 2 then 0x88 else (j - k_first) / j_size * 0xff
			k_coeff = if dir == 3 then 0x88 else (k - k_first) / k_size * 0xff

			(k_coeff << 16) + (j_coeff << 8) + i_coeff

	else if style[1].length > 2
		calc_color = (dir, k, j, i) -> style[1][dir - 1]
	
	if style.length > 2 and style[2].length > 0
		line_dashed = style[2][0]
	else
		line_dashed = false
	
	if style.length > 2 and style[1].length > 3 and style[2].length > 1
		color_border = style[1][3]
		border_bold = style[2][1]
	else
		color_border = '#000000'
		border_bold = true

	# -------- first

	if style[0][0]
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
						
						if border_bold and 
						k in [k_first, k_last] and j in [j_first, j_last]
							width = 2.5
						else
							width = 1

						if k in [k_first, k_last] or j in [j_first, j_last]
							color = color_border
							dashed = false
						else
							color = calc_color(1, k, j, 0)
							dashed = line_dashed
						
						add_line(pnts, scale_coeff, color, dashed, width)

	# -------- second

	if style[0][1]
		for k in [k_first..k_limit] by detail[0]
			do (k) ->
				k = k_last if k > k_last

				for i in [i_first..i_limit] by detail[2]
					do(i) ->
						i = i_last if i > i_last

						pnts = []
						for j in [j_first..j_last]
							do (j) ->
								pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

						if border_bold and
						k in [k_first, k_last] and i in [i_first, i_last]
							width = 2.5
						else
							width = 1

						if k in [k_first, k_last] or i in [i_first, i_last]
							color = color_border
							dashed = false
						else
							color = calc_color(2, k, 0, i)
							dashed = line_dashed
							
						add_line(pnts, scale_coeff, color, dashed, width)

	# -------- third

	if style[0][2]
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

						if border_bold and 
						j in [j_first, j_last] and i in [i_first, i_last]
							width = 2.5
						else
							width = 1

						if j in [j_first, j_last] or i in [i_first, i_last]
							color = color_border
							dashed = false
						else
							color = calc_color(3, 0, j, i)
							dashed = line_dashed
						
						add_line(pnts, scale_coeff, color, dashed, width)

root.gen_surfaces = (data, scale_coeff, detail, style, filter, filter_style) ->
	
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
	
	k_lst_front = []
	k_lst_back = []

	for k in [k_first..k_limit] by detail[0] 
		do (k) ->
			k = k_last if k > k_last

			k_lst_front.push(k)
			k_lst_back.push(k)

	k_lst_back.reverse()

	j_lst_front = []
	j_lst_back = []

	for j in [j_first..j_limit] by detail[1] 
		do (j) ->
			j = j_last if j > j_last

			j_lst_front.push(j)
			j_lst_back.push(j)

	j_lst_back.reverse()


	i_lst_front = []
	i_lst_back = []

	for i in [i_first..i_limit] by detail[2] 
		do (i) ->
			i = i_last if i > i_last

			i_lst_front.push(i)
			i_lst_back.push(i)

	i_lst_back.reverse()

	if style.length > 2 and style[2].length > 0
		opacity = style[2][0]
	else
		opacity = 0.5

	if style.length > 1 and style[1].length > 2
		color = style[1]
	else
		color = ['#00ffff', '#ff00ff', '#ffff00']

	for k, k_index in k_lst_back
		do (k) ->

			vertices = []

			for j in [j_first..j_last]
				do(j) ->
					for i in [i_first..i_last]
						do (i) ->

							vertices.push(
									new THREE.Vector3(
										data[k][j][i][0], 
										data[k][j][i][1], 
										data[k][j][i][2])
								)
			faces = []

			for j in [0..j_size - 1]
				do(j) ->
					for i in [0..i_size - 1]
						do (i) ->

							a = (i_size + 1) * j + i
							b = (i_size + 1) * (j + 1) + i
							
							
							face_0 = new THREE.Face3(b, a + 1, a)
							face_1 = new THREE.Face3(b + 1, a + 1, b)

							faces.push(face_0, face_1)

			add_surface(vertices, scale_coeff, faces, color[0], opacity) if style[0][0]

			#

			if k_index < k_lst_back.length - 1 

				for j, j_index in j_lst_back
					do (j) ->

						vertices = []

						for k in [k_lst_back[k_index], k_lst_back[k_index + 1]]
							do(k) ->
						
								for i in [i_first..i_last]
									do (i) ->

										vertices.push(
											new THREE.Vector3(
												data[k][j][i][0], 
												data[k][j][i][1], 
												data[k][j][i][2])
											)

						faces = []

						for i in [0..i_size - 1]
							do (i, k = 0) ->

								a = (i_size + 1) * k + i
								b = (i_size + 1) * (k + 1) + i
												
												
								face_0 = new THREE.Face3(b, a + 1, a)
								face_1 = new THREE.Face3(b + 1, a + 1, b)

								faces.push(face_0, face_1)

						add_surface(vertices, scale_coeff, faces, color[1], opacity) if style[0][1]

						#

						if j_index < j_lst_back.length - 1 

							for i, i_index in i_lst_back
								do (i) ->

									vertices = []

									for k in [k_lst_back[k_index], k_lst_back[k_index + 1]]
										do(k) ->
										
											for j in [j_lst_back[j_index], j_lst_back[j_index + 1]]
												do (j) ->

													vertices.push(
														new THREE.Vector3(
															data[k][j][i][0], 
															data[k][j][i][1], 
															data[k][j][i][2])
														)		
													
									face_0 = new THREE.Face3(2, 1, 0)
									face_1 = new THREE.Face3(3, 1, 2)

									faces = [face_0, face_1]

									add_surface(vertices, scale_coeff, faces, color[2], opacity) if style[0][2]
			# ---

			k = k_lst_front[k_index]

			if k_index > 0

				for j, j_index in j_lst_front
					do (j) ->

						# ---

						if j_index > 0

							for i, i_index in i_lst_front
								do (i) ->

									vertices = []

									for k in [k_lst_front[k_index - 1], k_lst_front[k_index]]
										do(k) ->

											for j in [j_lst_front[j_index - 1], j_lst_front[j_index]]
												do (j) ->

													vertices.push(
														new THREE.Vector3(
															data[k][j][i][0], 
															data[k][j][i][1], 
															data[k][j][i][2])
														)		
													
									face_0 = new THREE.Face3(0, 1, 2)
									face_1 = new THREE.Face3(2, 1, 3)

									faces = [face_0, face_1]

									add_surface(vertices, scale_coeff, faces, color[2], opacity) if style[0][2]
						# ---

						vertices = []

						for k in [k_lst_back[k_index - 1], k_lst_back[k_index]]
							do(k) ->
						
								for i in [i_first..i_last]
									do (i) ->

										vertices.push(
											new THREE.Vector3(
												data[k][j][i][0], 
												data[k][j][i][1], 
												data[k][j][i][2])
											)

						faces = []

						for i in [0..i_size - 1]
							do (i, k = 0) ->

								a = (i_size + 1) * k + i
								b = (i_size + 1) * (k + 1) + i
												
												
								face_0 = new THREE.Face3(a, a + 1, b)
								face_1 = new THREE.Face3(b, a + 1, b + 1)

								faces.push(face_0, face_1)

						add_surface(vertices, scale_coeff, faces, color[1], opacity) if style[0][1]
			# ---

			k = k_lst_front[k_index]

			vertices = []

			for j in [j_first..j_last]
				do(j) ->
					for i in [i_first..i_last]
						do (i) ->

							vertices.push(
									new THREE.Vector3(
										data[k][j][i][0], 
										data[k][j][i][1], 
										data[k][j][i][2])
								)

			faces = []

			for j in [0..j_size - 1]
				do(j) ->
					for i in [0..i_size - 1]
						do (i) ->

							a = (i_size + 1) * j + i
							b = (i_size + 1) * (j + 1) + i
							
							
							face_0 = new THREE.Face3(a, a + 1, b)
							face_1 = new THREE.Face3(b, a + 1, b + 1)

							faces.push(face_0, face_1)

			add_surface(vertices, scale_coeff, faces, color[0], opacity) if style[0][0]

root.add_line = (pnts, scale_coeff, color, dashed, width = 1) ->
	
	geometry = new THREE.BufferGeometry()
	
	geometry.addAttribute( 'position', new THREE.BufferAttribute( 
			new Float32Array(pnts), 3 
		) )
	
	geometry.computeBoundingSphere()

	if dashed
		material = new THREE.LineDashedMaterial({ 
			color: color, linewidth: width, dashSize: 0.02, gapSize: 0.01 })

		geometry.computeLineDistances()
	else
		material = new THREE.LineBasicMaterial({ 
			color: color, linewidth: width })
	
	sceneObject = new THREE.Line( geometry, material )
	
	sceneObject.scale.x = scale_coeff
	sceneObject.scale.y = scale_coeff
	sceneObject.scale.z = scale_coeff

	root.lines.add( sceneObject )
	
root.add_surface = (vertices, scale_coeff, faces, color, opacity) ->
	
	geometry = new THREE.Geometry()

	material = new THREE.MeshBasicMaterial( { 
		color: color, side: THREE.FrontSide, 
		transparent: true, opacity: opacity} )

	geometry.vertices = vertices
	geometry.faces = faces

	geometry.computeBoundingSphere()

	sceneObject = new THREE.Mesh(geometry, material)

	sceneObject.scale.x = scale_coeff
	sceneObject.scale.y = scale_coeff
	sceneObject.scale.z = scale_coeff

	root.faces.add( sceneObject )

root.GridLines =

	init: (data, scale_coeff, detail, style, filter, filter_style) ->

		root.lines = new THREE.Object3D()

		if style.length < 3
			style = [[], [], []]

		[root.k_first, root.j_first, root.i_first] = [0, 0, 0]

		root.k_last = data.length - 1
		root.j_last = data[0].length - 1
		root.i_last = data[0][0].length - 1

		gen_lines(data, scale_coeff, detail, style, filter, filter_style)

		root.lines

root.GridFaces = 
	init: (data, scale_coeff, detail, style, filter, filter_style) ->

		root.faces = new THREE.Object3D()

		if style.length < 3
			style = [[], [], []]

		if filter_style.length < 3
			filter_style = [[], [], []]

		if style[0].length < 3
			style[0] = [false, false, false]
		if style[1].length < 3
			style[1] = ["#00ffff", "#ff00ff", "#ffff00"]
		if style[2].length < 1
			style[2] = [0.2]
		
		if filter_style[0].length < 3
			filter_style[0] = [true, true, true]
		if filter_style[1].length < 3
			filter_style[1] = ["#00ffff", "#ff00ff", "#ffff00"]
		if filter_style[2].length < 1
			filter_style[2] = [0.2]

		gen_surfaces(data, scale_coeff, detail, style, filter, filter_style)

		root.faces
