
root = exports ? this

root.gen_lines = (data, scale_coeff, lst, 
	directions, materials, filter=false ) ->

	if directions.length < 4
		directions = [true, true, true, true]

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
		coeff = 5
		border_color = "#0000ff"
	else
		borders = [
			[0, data.length - 1], 
			[0, data[0].length - 1], 
			[0, data[0][0].length - 1]]
		coeff = 0
		border_color = "#000000"

	last_border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in borders[0] and j in borders[1] then true else false
		else if dir == 1
			r = if k in borders[0] and i in borders[2] then true else false
		else if dir == 2
			r = if j in borders[1] and i in borders[2] then true else false
		r

	border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in borders[0] or j in borders[1] then true else false
		else if dir == 1
			r = if k in borders[0] or i in borders[2] then true else false
		else if dir == 2
			r = if j in borders[1] or i in borders[2] then true else false
		r

	if materials.length < 4
		
		calc_material = (dir, k, j, i) ->

			#if last_border_line(dir, k, j, i) 
			#	m = [ new THREE.LineBasicMaterial({ 
			#		color: border_color, linewidth: 2.5 }), coeff + 4 ]

			if border_line(dir, k, j, i)
				m = [ new THREE.LineBasicMaterial({ 
					color: border_color, linewidth: 1 }), coeff + 3 ]
			else

				mid = if filter == true then 0xff else 0x55

				i_coeff = if dir == 0 then mid else (i - i_first) / 
					i_size * 0xff
				j_coeff = if dir == 1 then mid else (j - j_first) / 
					j_size * 0xff
				k_coeff = if dir == 2 then mid else (k - k_first) / 
					k_size * 0xff

				color = (i_coeff << 16) + (k_coeff << 8) + j_coeff

				m = [ new THREE.LineBasicMaterial(
					{ color: color, linewidth: 1 }), dir + coeff ]
			m

	else
		calc_material = (dir, k, j, i) -> 
			
			if last_border_line(dir, k, j, i) 
				m = [ materials[4], coeff + 4 ]
			else if border_line(dir, k, j, i)
				m = [ materials[3], coeff + 3 ]
			else 
				m = if directions[3] then [ materials[dir], dir + coeff ] else []
			m

	border_material = new THREE.MeshBasicMaterial( { color: 0x000000, side: THREE.DoubleSide } )
	
	border_points = (dir, a, b, x_seg, pnts, faces) ->
		
		for x, x_ind in x_seg
			do (x) ->
				if dir == 0
					[k, j, i] = [a, b, x]
				else if dir == 1
					[k, j, i] = [a, x, b]
				else if dir == 2
					[k, j, i] = [x, a, b]

				pnts.push(new THREE.Vector3(data[k][j][i][0] * scale_coeff + 0.05, 
					data[k][j][i][1] * scale_coeff, data[k][j][i][2] * scale_coeff))
				pnts.push(new THREE.Vector3(data[k][j][i][0] * scale_coeff, 
					data[k][j][i][1] * scale_coeff + 0.05, data[k][j][i][2] * scale_coeff))
				pnts.push(new THREE.Vector3(data[k][j][i][0] * scale_coeff, 
					data[k][j][i][1] * scale_coeff, data[k][j][i][2] * scale_coeff + 0.05))
				
				if x_ind != 0
					s = (x_ind - 1) * 3
					faces.push(new THREE.Face3(s, s + 1, s + 3))
					faces.push(new THREE.Face3(s + 1, s + 2, s + 4))
					faces.push(new THREE.Face3(s + 2, s, s + 5))
					faces.push(new THREE.Face3(s + 1, s + 4, s + 3))
					faces.push(new THREE.Face3(s + 2, s + 5, s + 4))
					faces.push(new THREE.Face3(s, s + 3, s + 5))

	if directions[0]
		for k in k_lst
			do (k) ->
				
				for j in j_lst
					do (j) ->

						if last_border_line(0, k, j, 0)
							pnts = []
							faces = []
							border_points(0, k, j, i_seg, pnts, faces)
							add_border_line(pnts, scale_coeff, faces, border_material, 100500)
						else
							pnts = []
							for i in i_seg
								do (i) ->
									pnts.push(data[k][j][i][0], 
										data[k][j][i][1], data[k][j][i][2])

							m = calc_material(0, k, j, 0)
							if m.length > 1 
								add_line(pnts, scale_coeff, m[0], m[1])

	if directions[1]
		for k in k_lst
			do (k) ->

				for i in i_lst
					do (i) ->

						if last_border_line(1, k, 0, i)	
							pnts = []
							faces = []
							border_points(1, k, i, j_seg, pnts, faces)
							add_border_line(pnts, scale_coeff, faces, border_material, 100500)
						else
							pnts = []
							for j in j_seg
								do (j) ->
									pnts.push(data[k][j][i][0], 
										data[k][j][i][1], data[k][j][i][2])

							m = calc_material(1, k, 0, i)
							if m.length > 1 
								add_line(pnts, scale_coeff, m[0], m[1])

	if directions[2]
		for j in j_lst
			do(j) ->

				for i in i_lst
					do (i) ->

						if last_border_line(2, 0, j, i)
							pnts = []
							faces = []
							border_points(2, j, i, k_seg, pnts, faces)
							add_border_line(pnts, scale_coeff, faces, border_material, 100500)
						else
							pnts = []
							for k in k_seg
								do (k) ->
									pnts.push(data[k][j][i][0], 
										data[k][j][i][1], data[k][j][i][2])

							m = calc_material(2, 0, j, i)
							if m.length > 1 
								add_line(pnts, scale_coeff, m[0], m[1])

root.gen_surfaces = (data, scale_coeff, det, dir, mat,
	filter=[], filter_directions=[], filter_materials=[]) ->
	
	if filter.length < 3 and filter_directions.length < 3
		filter_directions = [false, false, false]

	k_first = 0
	j_first = 0
	i_first = 0

	if filter.length < 3 and (!dir[0] and !dir[1] and dir[2])
		vec = (k, j, i) -> 
			new THREE.Vector3(data[j][i][k][0], data[j][i][k][1], data[j][i][k][2])

		detail = [det[2], det[0], det[1]]
		directions = [dir[2], dir[0], dir[1]]
		materials = [mat[2], mat[0], mat[1]] 

		k_last = data[0][0].length - 1
		j_last = data.length - 1
		i_last = data[0].length - 1	

	else if filter.length < 3 and 
	((!dir[0] and dir[1] and !dir[2]) or (!dir[0] and dir[1] and dir[2]))
		vec = (k, j, i) -> 
			new THREE.Vector3(data[i][k][j][0], data[i][k][j][1], data[i][k][j][2])

		detail = [det[1], det[2], det[0]]
		directions = [dir[1], dir[2], dir[0]] 
		materials = [mat[1], mat[2], mat[0]] 

		k_last = data[0].length - 1
		j_last = data[0][0].length - 1
		i_last = data.length - 1

	else
		vec = (k, j, i) -> 
			new THREE.Vector3(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

		detail = [det[0], det[1], det[2]]
		directions = [dir[0], dir[1], dir[2]]
		materials = [mat[0], mat[1], mat[2]] 

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

	if filter.length > 2 and filter_materials.length > 2

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

	k_size = 1 if k_size < 1
	j_size = 1 if j_size < 1
	i_size = 1 if i_size < 1

	internal_area = (dir, k, j, i) ->
		f1 = f2 = f3 = true
		
		if dir != 0
			f1 = if k >= filter[0][0] and k < filter[0][1] then true else false
		if dir != 1
			f2 = if j >= filter[1][0] and j < filter[1][1] then true else false
		if dir != 2
			f3 = if i >= filter[2][0] and i < filter[2][1] then true else false

		f1 && f2 && f3

	i_part = (dir, i_index, k1, k2, j1, j2) ->
		
		if dir == 0
			get_face_0 = (a, b) -> new THREE.Face3(b, a + 1, a)
			get_face_1 = (a, b) -> new THREE.Face3(b + 1, a + 1, b)
			i = i_lst_back[i_index]
		else
			get_face_0 = (a, b) -> new THREE.Face3(a, a + 1, b)
			get_face_1 = (a, b) -> new THREE.Face3(b, a + 1, b  + 1)
			i = i_lst_front[i_index]

		k_index_size = k2 - k1
		j_index_size = j2 - j1

		if k1 != k2 and j1 != j2
			vertices = []
			for k in [k1..k2]
				do(k) ->
					for j in [j1..j2]
						do (j) ->
							vertices.push(vec(k, j, i))

			faces = []
			faces_internal = []

			for k in [0..k_index_size - 1]
				do (k) ->
					for j in [0..j_index_size - 1]
						do (j) ->
							
							a = (j_index_size + 1) * k + j
							b = (j_index_size + 1) * (k + 1) + j

							face_0 = get_face_0(a, b)
							face_1 = get_face_1(a, b)

							if filter_internal and
							i >= filter[2][0] and i <= filter[2][1]
								
								k0 = k + k1
								j0 = j + j1
												
								if internal_area(2, k0, j0, i)
									if i in i_lst_filter
										faces_internal.push(face_0, face_1)
								else if i in i_lst_main
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and directions[2]
				add_surface(vertices, scale_coeff, 
					faces, materials[2], 2)

			if filter_internal and faces_internal.length > 0 and 
			filter_directions[2]
				add_surface(vertices, scale_coeff, 
					faces_internal, filter_materials[2], 5)

	j_part = (dir, j_index, k1, k2) ->

		if dir != 0
			if j_index > 0
				j1 = j_lst_front[j_index - 1]
				j2 = j_lst_front[j_index]

				if j_index >= j_lst_front.length / 2

					for i, i_index in i_lst_front
						do (i) ->
							if i_index >= i_lst_front.length / 2
								i_part(1, i_index, k1, k2, j1, j2)
					for i, i_index in i_lst_back
						do (i) ->
							if i_index > i_lst_front.length / 2
								i_part(0, i_index, k1, k2, j1, j2)
				else

					for i, i_index in i_lst_front
						do (i) ->
							if i_index < i_lst_front.length / 2
								i_part(1, i_index, k1, k2, j1, j2)
					for i, i_index in i_lst_back
						do (i) ->
							if i_index <= i_lst_front.length / 2
								i_part(0, i_index, k1, k2, j1, j2)

		j = j_lst_front[j_index]

		if dir == 0
			get_face_0 = (a, b) -> new THREE.Face3(a, a + 1, b)
			get_face_1 = (a, b) -> new THREE.Face3(b, a + 1, b + 1)
		else
			get_face_0 = (a, b) -> new THREE.Face3(b, a + 1, a)
			get_face_1 = (a, b) -> new THREE.Face3(b + 1, a + 1, b)

		k_index_size = k2 - k1

		if k1 != k2 and i_first != i_last
			vertices = []
			for k in [k1..k2]
				do(k) ->
					for i in [i_first..i_last]
						do (i) ->
							vertices.push(vec(k, j, i))			

			faces = []
			faces_internal = []

			for k in [0..k_index_size - 1]
				do (k) ->
					for i in [0..i_size - 1]
						do (i) ->

							a = (i_size + 1) * k + i
							b = (i_size + 1) * (k + 1) + i

							face_0 = get_face_0(a, b)
							face_1 = get_face_1(a, b)

							if filter_internal and
							j >= filter[1][0] and j <= filter[1][1]
								
								k0 = k + k1
												
								if internal_area(1, k0, j, i)
									if j in j_lst_filter
										faces_internal.push(face_0, face_1)
								else if j in j_lst_main
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and directions[1]
				add_surface(vertices, scale_coeff, 
					faces, materials[1], 1)

			if filter_internal and faces_internal.length > 0 and 
			filter_directions[1]
				add_surface(vertices, scale_coeff, 
					faces_internal, filter_materials[1], 4)

		if dir != 1
			if j_index > 0
				j1 = j_lst_front[j_index - 1]
				j2 = j_lst_front[j_index]

				if j_index >= j_lst_front.length / 2

					for i, i_index in i_lst_front
						do (i) ->
							if i_index < i_lst_front.length / 2
								i_part(1, i_index, k1, k2, j1, j2)
					for i, i_index in i_lst_back
						do (i) ->
							if i_index <= i_lst_front.length / 2
								i_part(0, i_index, k1, k2, j1, j2)
				else

					for i, i_index in i_lst_front
						do (i) ->
							if i_index >= i_lst_front.length / 2
								i_part(1, i_index, k1, k2, j1, j2)
					for i, i_index in i_lst_back
						do (i) ->
							if i_index > i_lst_front.length / 2
								i_part(0, i_index, k1, k2, j1, j2)

	k_part = (dir, k_index) ->
		
		if dir != 0 and k_index > 0
			k1 = k_lst_front[k_index - 1]
			k2 = k_lst_front[k_index]

			if k_index >= k_lst_front.length / 2
				for j, j_index in j_lst_front
					do (j) ->
						j_part(0, j_lst_front.length - 1 - j_index, k1, k2)
						j_part(1, j_index, k1, k2)

		k = k_lst_front[k_index]

		if dir == 0
			get_face_0 = (a, b) -> new THREE.Face3(b, a + 1, a)
			get_face_1 = (a, b) -> new THREE.Face3(b + 1, a + 1, b)	
		else
			get_face_0 = (a, b) -> new THREE.Face3(a, a + 1, b)
			get_face_1 = (a, b) -> new THREE.Face3(b, a + 1, b + 1)

		if j_first != j_last and i_first != i_last
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
									
							face_0 = get_face_0(a, b)
							face_1 = get_face_1(a, b)

							if filter_internal and
							k >= filter[0][0] and k <= filter[0][1]
								if internal_area(0, k, j, i)
									if k in k_lst_filter
										faces_internal.push(face_0, face_1)
								else if k in k_lst_main
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and directions[0]
				add_surface(vertices, scale_coeff, faces, materials[0], 0)

			if filter_internal and faces_internal.length > 0 and 
			filter_directions[0]
				add_surface(vertices, scale_coeff, faces_internal, 
					filter_materials[0], 3)

		if dir != 1 and k_index > 0
			k1 = k_lst_front[k_index - 1]
			k2 = k_lst_front[k_index]

			if k_index < k_lst_front.length / 2

				for j, j_index in j_lst_front
					do (j) ->
						j_part(0, j_lst_front.length - 1 - j_index, k1, k2)
						j_part(1, j_index, k1, k2)

	for k, k_index in k_lst_front
		do (k) ->
			k_part(1, k_index)
			k_part(0, k_lst_front.length - 1 - k_index)


root.add_line = (pnts, scale_coeff, material, name) ->
	
	geometry = new THREE.BufferGeometry()
	
	geometry.addAttribute( 'position', new THREE.BufferAttribute( 
			new Float32Array(pnts), 3 
		) )
	
	geometry.computeBoundingSphere()
	geometry.computeLineDistances();
	
	sceneObject = new THREE.Line( geometry, material )

	sceneObject.name = name
	
	sceneObject.scale.x = scale_coeff
	sceneObject.scale.y = scale_coeff
	sceneObject.scale.z = scale_coeff

	root.lines.add( sceneObject )

root.add_border_line = (vertices, scale_coeff, faces, material, name) ->
	
	geometry = new THREE.Geometry()

	geometry.vertices = vertices
	geometry.faces = faces

	geometry.computeBoundingSphere()

	sceneObject = new THREE.Mesh(geometry, material)

	sceneObject.name = name

	root.lines.add( sceneObject )
	
root.add_surface = (vertices, scale_coeff, faces, material, name) ->
	
	geometry = new THREE.Geometry()

	geometry.vertices = vertices
	geometry.faces = faces

	geometry.computeBoundingSphere()

	sceneObject = new THREE.Mesh(geometry, material)

	sceneObject.name = name

	sceneObject.scale.x = scale_coeff
	sceneObject.scale.y = scale_coeff
	sceneObject.scale.z = scale_coeff

	root.faces.add( sceneObject )

root.GridLines =

	init: (data, scale_coeff, detail, directions, materials, 
		filter, filter_directions, filter_materials) ->

		root.lines = new THREE.Object3D()

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

		get_tail_segment = (l, r, step) ->
			lst = [l]
			for x in [0..r] by step
				do (x) ->
					if x > l then lst.push(x)
			lst.push(r) if lst[lst.length - 1] != r
			lst

		if filter.length < 3
			k_all = get_segment(0, k_last, detail[0])
			j_all = get_segment(0, j_last, detail[1])
			i_all = get_segment(0, i_last, detail[2])

			gen_lines(data, scale_coeff, 
				[k_all, j_all, i_all], directions, materials)

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

			k_tmp = get_segment(filter[0][0], filter[0][1], detail[0])
			j_tmp = get_segment(filter[1][0], filter[1][1], detail[1])

			if filter[2][0] != 0
				i_tmp = get_segment(0, filter[2][0], detail[2])

				if k_tmp.length and j_tmp.length and i_tmp.length
					gen_lines(data, scale_coeff, 
						[k_tmp, j_tmp, i_tmp], directions, materials)

			if filter[2][1] != i_last
				i_tmp = get_tail_segment(filter[2][1], i_last, detail[2])

				if k_tmp.length and j_tmp.length and i_tmp.length
					gen_lines(data, scale_coeff, 
						[k_tmp, j_tmp, i_tmp], directions, materials)

			if filter[1][0] != 0
				j_tmp = get_segment(0, filter[1][0], detail[1])

				if k_tmp.length and j_tmp.length
					gen_lines(data, scale_coeff, 
						[k_tmp, j_tmp, i_all], directions, materials)

			if filter[1][1] != j_last
				j_tmp = get_tail_segment(filter[1][1], j_last, detail[1])

				if k_tmp.length and j_tmp.length
					gen_lines(data, scale_coeff, 
						[k_tmp, j_tmp, i_all], directions, materials)

			if filter[0][0] != 0
				k_tmp = get_segment(0, filter[0][0], detail[0])

				if k_tmp.length
					gen_lines(data, scale_coeff, 
						[k_tmp, j_all, i_all], directions, materials)

			if filter[0][1] != k_last
				k_tmp = get_tail_segment(filter[0][1], k_last, detail[0])

				if k_tmp.length
					gen_lines(data, scale_coeff, 
						[k_tmp, j_all, i_all], directions, materials) 

			k_tmp = get_segment(filter[0][0], filter[0][1], filter[0][2])
			j_tmp = get_segment(filter[1][0], filter[1][1], filter[1][2])
			i_tmp = get_segment(filter[2][0], filter[2][1], filter[2][2])

			if k_tmp.length and j_tmp.length and i_tmp.length
				gen_lines(data, scale_coeff, 
					[k_tmp, j_tmp, i_tmp], 
					filter_directions, filter_materials, true)

		root.lines

root.GridFaces = 
	init: (data, scale_coeff, detail, directions, materials, 
		filter, filter_directions, filter_materials) ->

		root.faces = new THREE.Object3D()

		if directions.length < 3
			directions = [false, false, false]

		if filter_directions.length < 3
			filter_directions = [true, true, true]

		if filter.length == 0
			gen_surfaces(data, scale_coeff, detail, directions, materials)
			
		else if filter.length > 2
			
			n1 = if (filter[0][0] != filter[0][1]) then true else false 
			n2 = if (filter[1][0] != filter[1][1]) then true else false 
			n3 = if (filter[2][0] != filter[2][1]) then true else false 

			if (n1 && n2) or (n1 && n3) or (n2 && n3)

				if directions[0] || directions[1] || directions[2]
					gen_surfaces(data, scale_coeff, 
						detail, directions, materials, 
						filter, filter_directions, filter_materials)
				else
					gen_surfaces(data, scale_coeff, detail, 
						filter_directions, filter_materials, filter)

		root.faces

root.GridPoints = 
	init: (data, scale_coeff, variable, min, max, index, color, radius, options, types) ->

		geometry = new THREE.BufferGeometry()

		root.cubes = new THREE.Object3D()

		paletter = []

		for i in [0..color.length - 1]
			do (i) ->
				paletter.push(parseInt(color[i].substring(1), 16))

		variable = parseInt(variable) + 2
		
		v0 = min[variable]
		v1 = max[variable]

		if types.length > variable - 3 and !!types[variable - 3]
			h = types[variable - 3]
			keys = Object.keys(h)
			for key, key_index in keys
				do (key) ->
					h[key] = paletter[key_index]
			
			calc_color = (value) ->
				c = h[value]
				r = c >> 16
				g = (c & 0x00ff00) >> 8
				b = c & 0x0000ff
				[r, g, b]
		else
			calc_color = (value) ->
				coeff = (value - v0) / (v1 - v0)

				coeff_int = Math.floor(coeff * (paletter.length - 1))
									
				r0 = paletter[coeff_int] >> 16
				g0 = (paletter[coeff_int] & 0x00ff00) >> 8
				b0 = paletter[coeff_int] & 0x0000ff

				if coeff_int == paletter.length - 1
					r = r0
					g = g0
					b = b0
				else
					r1 = paletter[coeff_int + 1] >> 16
					g1 = (paletter[coeff_int + 1] & 0x00ff00) >> 8
					b1 = paletter[coeff_int + 1] & 0x0000ff

					coeff_0 = coeff * (paletter.length - 1) - coeff_int

					r = (r1 - r0) * coeff_0 + r0
					g = (g1 - g0) * coeff_0 + g0
					b = (b1 - b0) * coeff_0 + b0

				[r, g, b]

		positions = []
		colors = []

		for k, k_index in data
			do (k) ->
				for j, j_index in k
					do (j) ->
						for i, i_index in j
							do (i) ->

								if options[0] or k_index == 0 or k_index == data.length - 1 or
								j_index == 0 or j_index == k.length - 1 or 
								i_index == 0 or i_index == j.length - 1

									positions.push(i[0], i[1], i[2])

									[r, g, b] = calc_color(i[variable])

									colors.push(r / 255, g / 255, b / 255)

									sprite_material = new THREE.SpriteMaterial( 
										{ color: ((r << 16) + (g << 8) +  b) } )
									
									sprite = new THREE.Sprite( sprite_material )
									
									sprite.position.x = i[0] * scale_coeff
									sprite.position.y = i[1] * scale_coeff
									sprite.position.z = i[2] * scale_coeff
									
									sprite.scale.set( radius * 0.7, radius * 0.7, 1 )
									
									root.cubes.add( sprite )

		geometry.addAttribute('position', 
			new THREE.BufferAttribute( new Float32Array(positions), 3 ) );

		geometry.addAttribute('color', 
			new THREE.BufferAttribute( new Float32Array(colors), 3 ) );

		material = new THREE.PointCloudMaterial({vertexColors: THREE.VertexColors, size: radius * 2, sizeAttenuation: true})

		root.points = new THREE.PointCloud( geometry, material )

		root.points.scale.set(scale_coeff, scale_coeff, scale_coeff)
		root.points.sortParticles = true;

		[root.points, root.cubes]