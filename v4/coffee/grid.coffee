
root = exports ? this

root.gen_lines = (data, scale_coeff, lst, style, filter=false ) ->

	k_lst = lst[0]
	j_lst = lst[1]
	i_lst = lst[2]

	k_first = k_lst[0]
	j_first = j_lst[0]
	i_first = i_lst[0]

	k_last = k_lst[k_lst.length - 1]
	j_last = j_lst[j_lst.length - 1]
	i_last = i_lst[i_lst.length - 1]

	k_seg = [k_first..k_last]
	j_seg = [j_first..j_last]
	i_seg = [i_first..i_last]

	k_size = k_last - k_first
	j_size = j_last - j_first
	i_size = i_last - i_first

	if filter == true
		borders = [[k_first, k_last], [j_first, j_last], [i_first, i_last]]
	else
		borders = [
			[0, data.length - 1], 
			[0, data[0].length - 1], 
			[0, data[0][0].length - 1]]

	if style.length < 3
		style = [[], [], []]

	if style[0].length < 3
		style[0] = [true, true, true]

	if style[1].length < 3
		calc_color = (dir, k, j, i) ->
			mid = 0x88
			mid = 0xff if filter == true

			i_coeff = if dir == 1 then mid else (i - i_first) / i_size * 0xff
			j_coeff = if dir == 2 then mid else (j - j_first) / j_size * 0xff
			k_coeff = if dir == 3 then mid else (k - k_first) / k_size * 0xff

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
		color_border = '#0000ff' if filter == true

		border_bold = true

	# -------- first

	if style[0][0]
		for k in k_lst
			do (k) ->
				
				for j in j_lst
					do (j) ->

						pnts = []
						for i in i_seg
							do (i) ->
								pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

						if border_bold and k in borders[0] and j in borders[1]
							width = 2.5
						else
							width = 1

						if k in borders[0] or j in borders[1]
							color = color_border
							dashed = false
						else
							color = calc_color(1, k, j, 0)
							dashed = line_dashed
						
						add_line(pnts, scale_coeff, color, dashed, width)

	# -------- second

	if style[0][1]
		for k in k_lst
			do (k) ->

				for i in i_lst
					do (i) ->

						pnts = []
						for j in j_seg
							do (j) ->
								pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

						if border_bold and k in borders[0] and i in borders[2]
							width = 2.5
						else
							width = 1

						if k in borders[0] or i in borders[2]
							color = color_border
							dashed = false
						else
							color = calc_color(2, k, 0, i)
							dashed = line_dashed
							
						add_line(pnts, scale_coeff, color, dashed, width)

	# -------- third

	if style[0][2]
		for j in j_lst
			do(j) ->

				for i in i_lst
					do (i) ->

						pnts = []
						for k in k_seg
							do (k) ->
								pnts.push(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

						if border_bold and j in borders[1] and i in borders[2]
							width = 2.5
						else
							width = 1

						if j in borders[1] or i in borders[2]
							color = color_border
							dashed = false
						else
							color = calc_color(3, 0, j, i)
							dashed = line_dashed
						
						add_line(pnts, scale_coeff, color, dashed, width)

root.gen_surfaces = (data, scale_coeff, detail, style, 
	filter=[], filter_style=[]) ->

	k_first = 0
	j_first = 0
	i_first = 0

	k_last = data.length - 1
	j_last = data[0].length - 1
	i_last = data[0][0].length - 1

	get_segment = (l, r, step) ->
		lst = []
		for x in [l..r] by step
			do (x) ->
				lst.push(x)
		lst.push(r) if lst[lst.length - 1] != r
		lst

	if filter.length > 2 

		for i in [0..2]
			do (i) ->

				filter[i][0] = 0 if filter[i][0] < 0
				filter[i][1] = 0 if filter[i][1] < 0
				filter[i][2] = 1 if filter[i][2] < 1

				if 	filter[i][0] > filter[i][1]	
					f = filter[i][0]
					filter[i][0] = filter[i][1]
					filter[i][1] = f

		for i in [0..2]
			do (i) ->
				filter[0][i] = k_last if filter[0][i] > k_last
				filter[1][i] = j_last if filter[1][i] > j_last
				filter[2][i] = i_last if filter[2][i] > i_last

	if filter_style.length > 2

		k_lst_main = get_segment(k_first, k_last, detail[0])
		j_lst_main = get_segment(j_first, j_last, detail[1])
		i_lst_main = get_segment(i_first, i_last, detail[2])

		k_lst_filter = get_segment(filter[0][0], filter[0][1], filter[0][2])
		j_lst_filter = get_segment(filter[1][0], filter[1][1], filter[1][2])
		i_lst_filter = get_segment(filter[2][0], filter[2][1], filter[2][2])

		merge = (a, b) -> a.concat(b.filter((x) -> a.indexOf(x) < 0))

		k_lst_front = merge(k_lst_main, k_lst_filter)
		j_lst_front = merge(j_lst_main, j_lst_filter)
		i_lst_front = merge(i_lst_main, i_lst_filter)

		compare = (a, b) -> a - b

		k_lst_front.sort(compare)
		j_lst_front.sort(compare)
		i_lst_front.sort(compare)

		k_lst_back = k_lst_front.slice()
		j_lst_back = j_lst_front.slice()
		i_lst_back = i_lst_front.slice()

		k_lst_back.reverse()
		j_lst_back.reverse()
		i_lst_back.reverse()

		filter_internal = true

	else
	
		if filter.length > 2

			k_first = filter[0][0]
			j_first = filter[1][0]
			i_first = filter[2][0]

			k_last = filter[0][1]
			j_last = filter[1][1]
			i_last = filter[2][1]

			detail = [filter[0][2], filter[1][2], filter[2][2]]		

		k_lst_front = get_segment(k_first, k_last, detail[0])
		j_lst_front = get_segment(j_first, j_last, detail[1])
		i_lst_front = get_segment(i_first, i_last, detail[2])

		k_lst_back = get_segment(k_first, k_last, detail[0])
		j_lst_back = get_segment(j_first, j_last, detail[1])
		i_lst_back = get_segment(i_first, i_last, detail[2])

		k_lst_back.reverse()
		j_lst_back.reverse()
		i_lst_back.reverse()

	k_size = k_last - k_first
	j_size = j_last - j_first
	i_size = i_last - i_first

	if style.length > 2 and style[2].length > 0
		opacity = style[2][0]
	else
		opacity = 0.5

	if style.length > 1 and style[1].length > 2
		color = style[1]
	else
		color = ['#00ffff', '#ff00ff', '#ffff00']

	if filter_style.length > 2 and filter_style[2].length > 0
		filter_opacity = filter_style[2][0]
	else
		filter_opacity = 0.5

	if filter_style.length > 1 and filter_style[1].length > 2
		filter_color = filter_style[1]
	else
		filter_color = ['#00ff88', '#8800ff', '#ff8800']

	vec = (k, j, i) -> 
		new THREE.Vector3(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

	for k, k_index in k_lst_back
		do (k) ->

			vertices = []
			for j in [j_first..j_last]
				do(j) ->
					for i in [i_first..i_last]
						do (i) ->
							vertices.push(vec(k, j, i))

			faces = []
			faces_internal = []

			for j in [0..j_size - 1]
				do(j) ->
					for i in [0..i_size - 1]
						do (i) ->

							a = (i_size + 1) * j + i
							b = (i_size + 1) * (j + 1) + i
								
							face_0 = new THREE.Face3(b, a + 1, a)
							face_1 = new THREE.Face3(b + 1, a + 1, b)

							if filter_internal
								if k in k_lst_filter and 
								j >= filter[1][0] and j < filter[1][1] and 
								i >= filter[2][0] and i < filter[2][1]
									faces_internal.push(face_0, face_1)
								else if k in k_lst_main
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and style[0][0]
				add_surface(vertices, scale_coeff, faces, color[0], opacity)

			if filter_internal and faces_internal.length > 0 and 
			filter_style[0][0]
				add_surface(vertices, scale_coeff, faces_internal, 
					filter_color[0], filter_opacity)

			#

			if k_index < k_lst_back.length - 1 

				for j, j_index in j_lst_back
					do (j) ->

						vertices = []
						for k in [k_lst_back[k_index + 1]..k_lst_back[k_index]]
							do(k) ->
								for i in [i_first..i_last]
									do (i) ->
										vertices.push(vec(k, j, i))

						k_index_size = k_lst_back[k_index] - k_lst_back[k_index + 1]

						faces = []
						faces_internal = []

						for k in [0..k_index_size - 1]
							do (k) ->
								for i in [0..i_size - 1]
									do (i) ->

										a = (i_size + 1) * k + i
										b = (i_size + 1) * (k + 1) + i

										face_0 = new THREE.Face3(a, a + 1, b)
										face_1 = new THREE.Face3(b, a + 1, b + 1)

										if filter_internal

											k0 = k + k_lst_back[k_index + 1]

											if j in j_lst_filter and 
											k0 >= filter[0][0] and 
											k0 < filter[0][1] and 
											i >= filter[2][0] and 
											i < filter[2][1]
												
												faces_internal.push(
													face_0, face_1)

											else if j in j_lst_main
												faces.push(face_0, face_1)
										else
											faces.push(face_0, face_1)

						if faces.length > 0 and style[0][1]
							add_surface(vertices, scale_coeff, faces, color[1], opacity)

						if filter_internal and faces_internal.length > 0 and 
						filter_style[0][1]
							add_surface(vertices, scale_coeff, faces_internal, 
								filter_color[1], filter_opacity)

						#

						if j_index < j_lst_back.length - 1 

							for i, i_index in i_lst_back
								do (i) ->

									vertices = []
									for k in [k_lst_back[k_index + 1]..k_lst_back[k_index]]
										do(k) ->
											for j in [j_lst_back[j_index + 1].. j_lst_back[j_index]]
												do (j) ->
													vertices.push(vec(k, j, i))

									k_index_size = k_lst_back[k_index] - k_lst_back[k_index + 1]
									j_index_size = j_lst_back[j_index] - j_lst_back[j_index + 1]

									faces = []
									faces_internal = []

									for k in [0..k_index_size - 1]
										do (k) ->
											for j in [0..j_index_size - 1]
												do (j) ->

													a = (j_index_size + 1) * 
														k + j
													b = (j_index_size + 1) * 
														(k + 1) + j

													face_0 = new THREE.Face3(
														b, a + 1, a)
													face_1 = new THREE.Face3(
														b + 1, a + 1, b)

													if filter_internal

														k0 = k + k_lst_back[k_index + 1]
														j0 = j + j_lst_back[j_index + 1]

														if i in i_lst_filter and 
														k0 >= filter[0][0] and 
														k0 < filter[0][1] and 
														j0 >= filter[1][0] and 
														j0 < filter[1][1]
															
															faces_internal.push(face_0, face_1)

														else if i in i_lst_main
															faces.push(face_0, face_1)
													else
														faces.push(face_0, face_1)

									if faces.length > 0 and style[0][2]
										add_surface(vertices, scale_coeff, faces, color[2], opacity)

									if filter_internal and 
									faces_internal.length > 0 and 
									filter_style[0][2]
										add_surface(vertices, scale_coeff, faces_internal, 
											filter_color[2], filter_opacity)

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
									for k in [k_lst_front[k_index - 1].. k_lst_front[k_index]]
										do(k) ->
											for j in [j_lst_front[j_index - 1]..j_lst_front[j_index]]
												do (j) ->
													vertices.push(vec(k, j, i))

									k_index_size = k_lst_front[k_index] - k_lst_front[k_index - 1]
									j_index_size = j_lst_front[j_index] - j_lst_front[j_index - 1]

									faces = []
									faces_internal = []

									for k in [0..k_index_size - 1]
										do (k) ->
											for j in [0..j_index_size - 1]
												do (j) ->

													a = (j_index_size + 1) * k + j
													b = (j_index_size + 1) * (k + 1) + j

													face_0 = new THREE.Face3(a, a + 1, b)
													face_1 = new THREE.Face3(b, a + 1, b + 1)

													if filter_internal
														k0 = k + k_lst_front[k_index - 1]
														j0 = j + j_lst_front[j_index - 1]

														if i in i_lst_filter and 
														k0 >= filter[0][0] and 
														k0 < filter[0][1] and 
														j0 >= filter[1][0] and 
														j0 < filter[1][1]
															
															faces_internal.push(face_0, face_1)

														else if i in i_lst_main
															faces.push(face_0, face_1)
													else
														faces.push(face_0, face_1)

									if faces.length > 0 and style[0][2]
										add_surface(vertices, scale_coeff, faces, color[2], opacity)

									if filter_internal and 
									faces_internal.length > 0 and 
									filter_style[0][2]
										add_surface(vertices, scale_coeff, faces_internal, 
											filter_color[2], filter_opacity)
						# ---

						j = j_lst_front[j_index]

						vertices = []
						for k in [k_lst_back[k_index]..k_lst_back[k_index - 1]]
							do(k) ->
								for i in [i_first..i_last]
									do (i) -> 
										vertices.push(vec(k, j, i))

						k_index_size = k_lst_back[k_index - 1] - k_lst_back[k_index]

						faces = []
						faces_internal = []

						for k in [0..k_index_size - 1]
							do (k) ->
								for i in [0..i_size - 1]
									do (i) ->

										a = (i_size + 1) * k + i
										b = (i_size + 1) * (k + 1) + i

										face_0 = new THREE.Face3(b, a + 1, a)
										face_1 = new THREE.Face3(b + 1, a + 1, b)

										if filter_internal

											k0 = k + k_lst_back[k_index]

											if j in j_lst_filter and 
											k0 >= filter[0][0] and 
											k0 < filter[0][1] and 
											i >= filter[2][0] and 
											i < filter[2][1]
												
												faces_internal.push(
													face_0, face_1)

											else if j in j_lst_main
												faces.push(face_0, face_1)
										else
											faces.push(face_0, face_1)

						if faces.length > 0 and style[0][1]
							add_surface(vertices, scale_coeff, faces, color[1], opacity)

						if filter_internal and faces_internal.length > 0 and 
						filter_style[0][1]
							add_surface(vertices, scale_coeff, faces_internal, 
								filter_color[1], filter_opacity)
			# ---

			k = k_lst_front[k_index]

			vertices = []
			for j in [j_first..j_last]
				do(j) ->
					for i in [i_first..i_last]
						do (i) ->
							vertices.push(vec(k, j, i))

			faces = []
			faces_internal = []

			for j in [0..j_size - 1]
				do(j) ->
					for i in [0..i_size - 1]
						do (i) ->

							a = (i_size + 1) * j + i
							b = (i_size + 1) * (j + 1) + i
							
							face_0 = new THREE.Face3(a, a + 1, b)
							face_1 = new THREE.Face3(b, a + 1, b + 1)

							if filter_internal
								if k_lst_front[k_index] in k_lst_filter and 
								j >= filter[1][0] and j < filter[1][1] and 
								i >= filter[2][0] and i < filter[2][1]
									faces_internal.push(face_0, face_1)
								else if k in k_lst_main
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and style[0][0]
				add_surface(vertices, scale_coeff, faces, color[0], opacity)

			if filter_internal and faces_internal.length > 0 and 
			filter_style[0][0]
				add_surface(vertices, scale_coeff, faces_internal, 
					filter_color[0], filter_opacity)


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

		root.k_last = data.length - 1
		root.j_last = data[0].length - 1
		root.i_last = data[0][0].length - 1

		get_segment = (l, r, step) ->
			lst = []
			for x in [l..r] by step
				do (x) ->
					lst.push(x)
			lst.push(r) if lst[lst.length - 1] != r
			lst

		if filter.length < 3
			k_all = get_segment(0, k_last, detail[0])
			j_all = get_segment(0, j_last, detail[1])
			i_all = get_segment(0, i_last, detail[2])

			gen_lines(data, scale_coeff, 
				[k_all, j_all, i_all], style, filter, filter_style)

		else
			for i in [0..2]
				do (i) ->

					filter[i][0] = 0 if filter[i][0] < 0
					filter[i][1] = 0 if filter[i][1] < 0
					filter[i][2] = 1 if filter[i][2] < 1

					if 	filter[i][0] > filter[i][1]	
						f = filter[i][0]
						filter[i][0] = filter[i][1]
						filter[i][1] = f

			for i in [0..2]
				do (i) ->
					filter[0][i] = k_last if filter[0][i] > k_last
					filter[1][i] = j_last if filter[1][i] > j_last
					filter[2][i] = i_last if filter[2][i] > i_last

			j_all = get_segment(0, j_last, detail[1])
			i_all = get_segment(0, i_last, detail[2])

			k_tmp = get_segment(filter[0][0], filter[0][1], filter[0][2])
			j_tmp = get_segment(filter[1][0], filter[1][1], filter[1][2])
			i_tmp = get_segment(filter[2][0], filter[2][1], filter[2][2])

			if filter[2][0] != 0
				i_tmp = get_segment(0, filter[2][0], detail[2])

				if k_tmp.length and j_tmp.length and i_tmp.length
					gen_lines(data, scale_coeff, [k_tmp, j_tmp, i_tmp], style)

			if filter[2][1] != i_last
				i_tmp = get_segment(filter[2][1], i_last, detail[2])

				if k_tmp.length and j_tmp.length and i_tmp.length
					gen_lines(data, scale_coeff, [k_tmp, j_tmp, i_tmp], style)

			if filter[1][0] != 0
				j_tmp = get_segment(0, filter[1][0], detail[1])

				if k_tmp.length and j_tmp.length
					gen_lines(data, scale_coeff, [k_tmp, j_tmp, i_all], style)

			if filter[1][1] != j_last
				j_tmp = get_segment(filter[1][1], j_last, detail[1])

				if k_tmp.length and j_tmp.length
					gen_lines(data, scale_coeff, [k_tmp, j_tmp, i_all], style)

			if filter[0][0] != 0
				k_tmp = get_segment(0, filter[0][0], detail[0])

				if k_tmp.length
					gen_lines(data, scale_coeff, [k_tmp, j_all, i_all], style)

			if filter[0][1] != k_last
				k_tmp = get_segment(filter[0][1], k_last, detail[0])

				if k_tmp.length
					gen_lines(data, scale_coeff, [k_tmp, j_all, i_all], style) 

			k_tmp = get_segment(filter[0][0], filter[0][1], filter[0][2])
			j_tmp = get_segment(filter[1][0], filter[1][1], filter[1][2])
			i_tmp = get_segment(filter[2][0], filter[2][1], filter[2][2])

			if k_tmp.length and j_tmp.length and i_tmp.length
				gen_lines(data, scale_coeff, 
					[k_tmp, j_tmp, i_tmp], filter_style, true)

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
			filter_style[1] = ["#00ff88", "#8800ff", "#ff8800"]
		if filter_style[2].length < 1
			filter_style[2] = [0.2]

		if filter.length == 0
			gen_surfaces(data, scale_coeff, detail, style)
			
		else if filter.length > 2
			
			n1 = if (filter[0][0] != filter[0][1]) then true else false 
			n2 = if (filter[1][0] != filter[1][1]) then true else false 
			n3 = if (filter[2][0] != filter[2][1]) then true else false 

			if (n1 && n2) or (n1 && n3) or (n2 && n3)

				if style[0][0] || style[0][1] || style[0][2]
					gen_surfaces(data, scale_coeff, detail, style, filter, filter_style)
				else
					gen_surfaces(data, scale_coeff, detail, filter_style, filter)

		root.faces
