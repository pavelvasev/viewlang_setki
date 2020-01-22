
root = exports ? this

root.gen_lines = (data, scale_coeff, detail, directions, materials, borders, dashed
	filtered, filter_detail, filter_directions, filter_materials, filter_dashed) ->
	
	if directions.length < 4
		directions = [true, true, true, true]

	if filter_directions.length < 4
		filter_directions = [true, true, true, true]

	coeff = 0
	border_color = "#000000"

	border_material = [ new THREE.LineBasicMaterial({ 
		color: border_color, linewidth: 1 }), coeff + 3 ]

	filter_borders = [
		[filter_detail[0][0], filter_detail[0][ filter_detail[0].length - 1 ]], 
		[filter_detail[1][0], filter_detail[1][ filter_detail[1].length - 1 ]], 
		[filter_detail[2][0], filter_detail[2][ filter_detail[2].length - 1 ]]]

	coeff = 5
	filter_border_color = "#0000ff"

	filter_border_material = [ new THREE.LineBasicMaterial({ 
		color: filter_border_color, linewidth: 1 }), coeff + 3 ]

	if borders.length > 5
		filter_last_border_line = (dir, k, j, i) ->
			if dir == 0
				r = if k in borders[3] and j in borders[4] then true else false
			else if dir == 1
				r = if k in borders[3] and i in borders[5] then true else false
			else if dir == 2
				r = if j in borders[4] and i in borders[5] then true else false
			r
	else
		filter_last_border_line = (dir, k, j, i) ->
			false

	filter_border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in filter_borders[0] or j in filter_borders[1] then true else false
		else if dir == 1
			r = if k in filter_borders[0] or i in filter_borders[2] then true else false
		else if dir == 2
			r = if j in filter_borders[1] or i in filter_borders[2] then true else false
		r

	last_border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in borders[0] and j in borders[1] then true else false
		else if dir == 1
			r = if k in borders[0] and i in borders[2] then true else false
		else if dir == 2
			r = if j in borders[1] and i in borders[2] then true else false

		if filter_last_border_line(dir, k, j, i)
			if dir == 2
				if borders[0][0] == filter_borders[0][0] and borders[0][1] == filter_borders[0][1]
					r = false
			else if dir == 1
				if borders[1][0] == filter_borders[1][0] and borders[1][1] == filter_borders[1][1]
					r = false
			else if dir == 0
				if borders[2][0] == filter_borders[2][0] and borders[2][1] == filter_borders[2][1]
					r = false

		r

	border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in borders[0] or j in borders[1] then true else false
		else if dir == 1
			r = if k in borders[0] or i in borders[2] then true else false
		else if dir == 2
			r = if j in borders[1] or i in borders[2] then true else false
		r

	[k_first, j_first, i_first] = [0, 0, 0]
	[k_size, j_size, i_size] = [k_last, j_last, i_last]

	calc_material = (dir, k, j, i, filter=false) -> 

		if filter == true
			coeff = 5
			if filter_materials.length < 4
				if filter_border_line(dir, k, j, i)
					m = filter_border_material
				else
					mid = 0x55
						
					i_coeff = if dir == 0 then mid else (i - i_first) / i_size * 0xff
					j_coeff = if dir == 1 then mid else (j - j_first) / j_size * 0xff
					k_coeff = if dir == 2 then mid else (k - k_first) / k_size * 0xff

					color = (i_coeff << 16) + (k_coeff << 8) + j_coeff

					m = [ new THREE.LineBasicMaterial(
						{ color: color, linewidth: 1 }), dir + coeff ]
			else
				if filter_border_line(dir, k, j, i)
					m = [ filter_materials[3], coeff + 3 ]
				else 
					m = if filter_directions[3] then [ filter_materials[dir], dir + coeff ] else []
		else
			coeff = 0
			if materials.length < 4
				if border_line(dir, k, j, i)
					m = border_material
				else
					mid = 0x45

					i_coeff = if dir == 0 then mid else (i - i_first) / i_size * 0xff
					j_coeff = if dir == 1 then mid else (j - j_first) / j_size * 0xff
					k_coeff = if dir == 2 then mid else (k - k_first) / k_size * 0xff

					color = (i_coeff << 16) + (j_coeff << 8) + k_coeff

					m = [ new THREE.LineBasicMaterial(
						{ color: color, linewidth: 1 }), dir + coeff ]
			else
				if last_border_line(dir, k, j, i) 
					m = [ materials[4], coeff + 4 ]
				else if border_line(dir, k, j, i)
					m = [ materials[3], coeff + 3 ]
				else 
					m = if directions[3] then [ materials[dir], dir + coeff ] else []
		m

	last_border = 0x000000

	if materials.length > 3
		last_border = materials[3].color.getHex()

	last_border_material = new THREE.MeshBasicMaterial( 
		{ color: last_border, side: THREE.DoubleSide } )

	filter_last_border = 0x0000ff

	if filter_materials.length > 3
		filter_last_border = filter_materials[3].color.getHex()

	filter_last_border_material = new THREE.MeshBasicMaterial( 
		{ color: filter_last_border, side: THREE.DoubleSide } )

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
	
	add_seg = (p, dir, k, j, i, filter=false) ->
		if filter == true
			if filter_directions[dir] and p.length > 1
				m = calc_material(dir, k, j, i, true)
				if m.length > 1
					if filter_border_line(dir, k, j, i)
						add_line(p, scale_coeff, m[0], m[1])
					else
						add_line(p, scale_coeff, m[0], m[1], filter_dashed)
		else
			if directions[dir] and p.length > 1
				m = calc_material(dir, k, j, i)
				if m.length > 1
					if border_line(dir, k, j, i)
						add_line(p, scale_coeff, m[0], m[1])
					else
						add_line(p, scale_coeff, m[0], m[1], dashed)

	for k in [0..k_last]
		do (k) ->
				
			for j in [0..j_last]
				do (j) ->

					if directions[0] and last_border_line(0, k, j, 0)
						pnts = []
						faces = []
						
						border_points(0, k, j, [0..i_last], pnts, faces)
						add_border_line(pnts, scale_coeff, faces, 
							last_border_material, 100500)

					else 
						if filter_directions[0] and filter_last_border_line(0, k, j, 0) and \	
						borders[5][0] != borders[5][1]
							pnts = []
							faces = []

							border_points(0, k, j, [borders[5][0]..borders[5][1]], pnts, faces)
							add_border_line(pnts, scale_coeff, faces, 
								filter_last_border_material, 100500)

						pnts = []
						filter_pnts = []
						flag = -1

						for i in [0..i_last]
							do (i) ->
								if filtered(-1, k, j, i)
									if flag == 1
										pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
										add_seg(pnts, 0, k, j, 0)
										pnts = []
									if k in filter_detail[0] and j in filter_detail[1]
										filter_pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
									flag = 0
								else
									if flag == 0
										add_seg(filter_pnts, 0, k, j, 0, true)
										filter_pnts = []
										pnts.push(data[k][j][i - 1][0], 
											data[k][j][i - 1][1], data[k][j][i - 1][2])
									if k in detail[0] and j in detail[1]
										pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
									flag = 1

						add_seg(pnts, 0, k, j, 0)
						add_seg(filter_pnts, 0, k, j, 0, true)

	for k in [0..k_last]
		do (k) ->
				
			for i in [0..i_last]
				do (i) ->

					if directions[1] and last_border_line(1, k, 0, i)
						pnts = []
						faces = []
						
						border_points(1, k, i, [0..j_last], pnts, faces)
						add_border_line(pnts, scale_coeff, faces, 
							last_border_material, 100500)
					else
						if filter_directions[1] and filter_last_border_line(1, k, 0, i) and \
						borders[4][0] != borders[4][1]
							pnts = []
							faces = []
							
							border_points(1, k, i, [borders[4][0]..borders[4][1]], pnts, faces)
							add_border_line(pnts, scale_coeff, faces, 
								filter_last_border_material, 100500)

						pnts = []
						filter_pnts = []
						flag = -1

						for j in [0..j_last]
							do (j) ->
								if filtered(-1, k, j, i)
									if flag == 1
										pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
										add_seg(pnts, 1, k, 0, i)
										pnts = []
									if k in filter_detail[0] and i in filter_detail[2]
										filter_pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
									flag = 0
								else
									if flag == 0
										add_seg(filter_pnts, 1, k, 0, i, true)
										filter_pnts = []
										pnts.push(data[k][j - 1][i][0], 
											data[k][j - 1][i][1], data[k][j - 1][i][2])
									if k in detail[0] and i in detail[2]
										pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
									flag = 1

						add_seg(pnts, 1, k, 0, i)
						add_seg(filter_pnts, 1, k, 0, i, true)

	for j in [0..j_last]
		do (j) ->
				
			for i in [0..i_last]
				do (i) ->

					if directions[2] and last_border_line(2, 0, j, i)
						pnts = []
						faces = []

						border_points(2, j, i, [0..k_last], pnts, faces)
						add_border_line(pnts, scale_coeff, faces, 
							last_border_material, 100500)
					else
						if filter_directions[2] and filter_last_border_line(2, 0, j, i) and \
						borders[3][0] != borders[3][1] 
							pnts = []
							faces = []
							
							border_points(2, j, i, [borders[3][0]..borders[3][1]], pnts, faces)
							add_border_line(pnts, scale_coeff, faces, 
								filter_last_border_material, 100500)

						pnts = []
						filter_pnts = []
						flag = -1

						for k in [0..k_last]
							do (k) ->
								if filtered(-1, k, j, i)
									if flag == 1
										pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
										add_seg(pnts, 2, 0, j, i)
										pnts = []
									if j in filter_detail[1] and i in filter_detail[2]
										filter_pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
									flag = 0
								else
									if flag == 0
										add_seg(filter_pnts, 2, 0, j, i, true)
										filter_pnts = []
										pnts.push(data[k - 1][j][i][0], 
											data[k - 1][j][i][1], data[k - 1][j][i][2])
									if j in detail[1] and i in detail[2]
										pnts.push(data[k][j][i][0], 
											data[k][j][i][1], data[k][j][i][2])
									flag = 1

						add_seg(pnts, 2, 0, j, i)
						add_seg(filter_pnts, 2, 0, j, i, true)

root.gen_lines_seg = (data, scale_coeff, detail, directions, mat, borders
	filtered, filter_detail, filter_directions, filter_mat, dashed=false) ->
	
	if directions.length < 4
		directions = [true, true, true, true]

	if filter_directions.length < 4
		filter_directions = [true, true, true, true]

	coeff = 0
	
	border_color = [ 0, 0, 0 ]

	filter_borders = [
		[filter_detail[0][0], filter_detail[0][ filter_detail[0].length - 1 ]], 
		[filter_detail[1][0], filter_detail[1][ filter_detail[1].length - 1 ]], 
		[filter_detail[2][0], filter_detail[2][ filter_detail[2].length - 1 ]]]

	coeff = 5

	filter_border_color = [ 0, 0, 1 ]

	if borders.length > 5
		filter_last_border_line = (dir, k, j, i) ->
			if dir == 0
				r = if k in borders[3] and j in borders[4] then true else false
			else if dir == 1
				r = if k in borders[3] and i in borders[5] then true else false
			else if dir == 2
				r = if j in borders[4] and i in borders[5] then true else false
			r
	else
		filter_last_border_line = (dir, k, j, i) ->
			false

	filter_border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in filter_borders[0] or j in filter_borders[1] then true else false
		else if dir == 1
			r = if k in filter_borders[0] or i in filter_borders[2] then true else false
		else if dir == 2
			r = if j in filter_borders[1] or i in filter_borders[2] then true else false
		r

	last_border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in borders[0] and j in borders[1] then true else false
		else if dir == 1
			r = if k in borders[0] and i in borders[2] then true else false
		else if dir == 2
			r = if j in borders[1] and i in borders[2] then true else false

		if filter_last_border_line(dir, k, j, i)
			if dir == 2
				if borders[0][0] == filter_borders[0][0] and borders[0][1] == filter_borders[0][1]
					r = false
			else if dir == 1
				if borders[1][0] == filter_borders[1][0] and borders[1][1] == filter_borders[1][1]
					r = false
			else if dir == 0
				if borders[2][0] == filter_borders[2][0] and borders[2][1] == filter_borders[2][1]
					r = false
		r

	border_line = (dir, k, j, i) ->
		if dir == 0
			r = if k in borders[0] or j in borders[1] then true else false
		else if dir == 1
			r = if k in borders[0] or i in borders[2] then true else false
		else if dir == 2
			r = if j in borders[1] or i in borders[2] then true else false
		r

	[k_first, j_first, i_first] = [0, 0, 0]
	[k_size, j_size, i_size] = [k_last, j_last, i_last]

	convert_color = (tag) ->
		value = parseInt(tag.substring(1), 16)
		[(value >> 16) / 255, ((value & 0x00ff00) >> 8) / 255, (value & 0x0000ff) / 255]

	materials = []
	filter_materials = []

	last_border = "#000000"

	if mat.length > 3
		for i in [0..3]
			materials.push(convert_color(mat[i]))
		last_border = mat[3]

	filter_last_border = "#0000ff"

	if filter_mat.length > 3
		for i in [0..3]
			filter_materials.push(convert_color(filter_mat[i]))
		filter_last_border = filter_mat[3]

	calc_color = (dir, k, j, i, filter=false) -> 

		if filter == true
			coeff = 5
			if filter_materials.length < 4
				if filter_border_line(dir, k, j, i)
					color = filter_border_color
				else
					mid = 0x55 / 255
						
					i_coeff = if dir == 0 then mid else (i - i_first) / i_size 
					j_coeff = if dir == 1 then mid else (j - j_first) / j_size 
					k_coeff = if dir == 2 then mid else (k - k_first) / k_size 

					color = [i_coeff, k_coeff, j_coeff]
			else
				if filter_border_line(dir, k, j, i)
					color = filter_materials[3]
				else 
					color = if filter_directions[3] then filter_materials[dir] else []
		else
			coeff = 0
			if materials.length < 4
				if border_line(dir, k, j, i)
					color = border_color
				else
					mid = 0x45 / 255

					i_coeff = if dir == 0 then mid else (i - i_first) / i_size
					j_coeff = if dir == 1 then mid else (j - j_first) / j_size
					k_coeff = if dir == 2 then mid else (k - k_first) / k_size

					color = [i_coeff, j_coeff, k_coeff]
			else
				if last_border_line(dir, k, j, i) 
					color = border_color
				else if border_line(dir, k, j, i)
					color = materials[3]
				else 
					color = if directions[3] then materials[dir] else []
		color

	last_border_material = new THREE.MeshBasicMaterial( 
		{ color: parseInt(last_border.substring(1), 16), side: THREE.DoubleSide } )

	filter_last_border_material = new THREE.MeshBasicMaterial( 
		{ color: parseInt(filter_last_border.substring(1), 16), side: THREE.DoubleSide } )

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

	geometry_pnts = []
	seg_colors = []

	add_seg = (dir, k, j, i, geometry, seg_colors, detail, directions, color) ->
		if ((dir == 0 and k in detail[0] and j in detail[1]) \
		or (dir == 1 and k in detail[0] and i in detail[2]) \
		or (dir == 2 and j in detail[1] and i in detail[2])) \
		and (directions[3] or border_line(dir, k, j, i))
			if directions[dir]
				geometry_pnts.push(data[k][j][i][0], 
					data[k][j][i][1], data[k][j][i][2])
				seg_colors.push(color[0], color[1], color[2])
	
	for k in [0..k_last]
		do (k) ->
				
			for j in [0..j_last]
				do (j) ->

					color = calc_color(0, k, j, 0)
					filter_color = calc_color(0, k, j, 0, true)

					if directions[0] and last_border_line(0, k, j, 0)
						pnts = []
						faces = []
						
						border_points(0, k, j, [0..i_last], pnts, faces)
						add_border_line_seg(pnts, scale_coeff, faces, 
							last_border_material, 100500)

					else 
						if filter_directions[0] and filter_last_border_line(0, k, j, 0) and \	
						borders[5][0] != borders[5][1]
							pnts = []
							faces = []

							border_points(0, k, j, [borders[5][0]..borders[5][1]], pnts, faces)
							add_border_line_seg(pnts, scale_coeff, faces, 
								filter_last_border_material, 100500)

						flag = -1

						for i in [0..i_last - 1]
							do (i) ->

								if filtered(0, k, j, i)
									add_seg(0, k, j, i, geometry, seg_colors,
											filter_detail, filter_directions, filter_color)
									add_seg(0, k, j, i + 1, geometry, seg_colors,
											filter_detail, filter_directions, filter_color)
								else
									add_seg(0, k, j, i, geometry, seg_colors,
										detail, directions, color)
									add_seg(0, k, j, i + 1, geometry, seg_colors,
										detail, directions, color)

	for k in [0..k_last]
		do (k) ->
				
			for i in [0..i_last]
				do (i) ->

					color = calc_color(1, k, 0, i)
					filter_color = calc_color(1, k, 0, i, true)

					if directions[1] and last_border_line(1, k, 0, i)
						pnts = []
						faces = []
						
						border_points(1, k, i, [0..j_last], pnts, faces)
						add_border_line_seg(pnts, scale_coeff, faces, 
							last_border_material, 100500)
					else
						if filter_directions[1] and filter_last_border_line(1, k, 0, i) and \
						borders[4][0] != borders[4][1]
							pnts = []
							faces = []
							
							border_points(1, k, i, [borders[4][0]..borders[4][1]], pnts, faces)
							add_border_line_seg(pnts, scale_coeff, faces, 
								filter_last_border_material, 100500)

						flag = -1

						for j in [0..j_last - 1]
							do (j) ->

								if filtered(1, k, j, i)
									add_seg(1, k, j, i, geometry, seg_colors,
											filter_detail, filter_directions, filter_color)
									add_seg(1, k, j + 1, i, geometry, seg_colors,
											filter_detail, filter_directions, filter_color)
								else
									add_seg(1, k, j, i, geometry, seg_colors,
										detail, directions, color)
									add_seg(1, k, j + 1, i, geometry, seg_colors,
										detail, directions, color)

	for j in [0..j_last]
		do (j) ->
				
			for i in [0..i_last]
				do (i) ->

					color = calc_color(2, 0, j, i)
					filter_color = calc_color(2, 0, j, i, true)

					if directions[2] and last_border_line(2, 0, j, i)
						pnts = []
						faces = []

						border_points(2, j, i, [0..k_last], pnts, faces)
						add_border_line_seg(pnts, scale_coeff, faces, 
							last_border_material, 100500)
					else
						if filter_directions[2] and filter_last_border_line(2, 0, j, i) and \
						borders[3][0] != borders[3][1] 
							pnts = []
							faces = []
							
							border_points(2, j, i, [borders[3][0]..borders[3][1]], pnts, faces)
							add_border_line_seg(pnts, scale_coeff, faces, 
								filter_last_border_material, 100500)

						flag = -1

						for k in [0..k_last - 1]
							do (k) ->

								if filtered(2, k, j, i)
									add_seg(2, k, j, i, geometry, seg_colors,
											filter_detail, filter_directions, filter_color)
									add_seg(2, k + 1, j, i, geometry, seg_colors,
											filter_detail, filter_directions, filter_color)
								else
									add_seg(2, k, j, i, geometry, seg_colors,
										detail, directions, color)
									add_seg(2, k + 1, j, i, geometry, seg_colors,
										detail, directions, color)

	if geometry_pnts.length

		geometry = new THREE.BufferGeometry()

		geometry.setAttribute( 'position', new THREE.BufferAttribute( 
				new Float32Array(geometry_pnts), 3 
			) )

		geometry.setAttribute( 'color', new THREE.BufferAttribute( 
				new Float32Array(seg_colors), 3 
			) )

		geometry.computeBoundingSphere()
		

		if not dashed
			material = new THREE.LineBasicMaterial(
				{ linewidth: 1, vertexColors: THREE.VertexColors })
		else
			material = new THREE.LineDashedMaterial(
				{ linewidth: 1, vertexColors: THREE.VertexColors, dashSize: 0.02, gapSize: 0.01 })
		
		sceneObject = new THREE.LineSegments( geometry, material )
		
		sceneObject.scale.x = scale_coeff
		sceneObject.scale.y = scale_coeff
		sceneObject.scale.z = scale_coeff
		sceneObject.computeLineDistances()

		root.lines_seg.add( sceneObject )

root.gen_surfaces = (data, scale_coeff, det, dir, mat,
	filter=[], filter_directions=[], filter_materials=[], 
	filter_scalar=[], filter_list=[]) ->
	
	if filter.length < 3 and filter_directions.length < 3
		filter_directions = [false, false, false, true]

	k_first = 0
	j_first = 0
	i_first = 0

	if filter.length < 3 and not filter_scalar.length and not filter_list.length and \
	(!dir[0] and !dir[1] and dir[2])
		vec = (k, j, i) -> 
			new THREE.Vector3(data[j][i][k][0], data[j][i][k][1], data[j][i][k][2])

		detail = [det[2], det[0], det[1]]
		directions = [dir[2], dir[0], dir[1], dir[3]]
		materials = [mat[2], mat[0], mat[1]] 

		k_last = data[0][0].length - 1
		j_last = data.length - 1
		i_last = data[0].length - 1	

	else if filter.length < 3 and not filter_scalar.length and not filter_list.length and \
	((!dir[0] and dir[1] and !dir[2]) or (!dir[0] and dir[1] and dir[2]))
		vec = (k, j, i) -> 
			new THREE.Vector3(data[i][k][j][0], data[i][k][j][1], data[i][k][j][2])

		detail = [det[1], det[2], det[0]]
		directions = [dir[1], dir[2], dir[0], dir[3]] 
		materials = [mat[1], mat[2], mat[0]] 

		k_last = data[0].length - 1
		j_last = data[0][0].length - 1
		i_last = data.length - 1

	else
		vec = (k, j, i) -> 
			new THREE.Vector3(data[k][j][i][0], data[k][j][i][1], data[k][j][i][2])

		detail = [det[0], det[1], det[2]]
		directions = [dir[0], dir[1], dir[2], dir[3]]
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

	if filter_scalar.length
		root.scalar = filter_scalar[0] + 2

		internal_area = (dir, k, j, i) ->
			res = false
			
			if k > data.length - 1 or \
			j > data[0].length - 1 or \
			i > data[0][0].length - 1
				return res

			ck_lst = if dir == 0 and k > 0 then [-1, 0] else [0]
			cj_lst = if dir == 1 and j > 0 then [-1, 0] else [0]
			ci_lst = if dir == 2 and i > 0 then [-1, 0] else [0]

			ck_lst.push(1) if (k + 1 == data.length - 1)
			cj_lst.push(1) if (j + 1 == data[0].length - 1)
			ci_lst.push(1) if (i + 1 == data[0][0].length - 1)

			if not res then for ck in ck_lst
				do (ck) ->
					if not res then for cj in cj_lst
						do (cj) ->
							if not res then for ci in ci_lst
								do (ci) ->
									value = data[k + ck][j + cj][i + ci][scalar]
									if (value >= filter_scalar[1][0] and \
									value <= filter_scalar[1][1]) 
										res = true
			res

		k_lst_main = get_segment(k_first, k_last, detail[0])
		j_lst_main = get_segment(j_first, j_last, detail[1])
		i_lst_main = get_segment(i_first, i_last, detail[2])

		k_lst_front = get_segment(k_first, k_last, 1)
		j_lst_front = get_segment(j_first, j_last, 1)
		i_lst_front = get_segment(i_first, i_last, 1)

		k_lst_back = get_segment(k_first, k_last, 1)
		j_lst_back = get_segment(j_first, j_last, 1)
		i_lst_back = get_segment(i_first, i_last, 1)

	else if filter_list.length
		
		mask = ([] for x in [0...data.length])

		for xk in [0...data.length]
			do (xk) ->
				mask[xk] = ([] for x in [0...data[0].length])
				for xj in [0...data[0].length]
					do (xj) -> 
						mask[xk][xj] = (false for [0...data[0][0].length])

		for ind in filter_list
			do (ind) ->
				if ind.length and mask.length > ind[2] and \
				mask[ ind[2] ].length > ind[1] and \
				mask[ ind[2] ][ ind[1] ].length > ind[0]
					mask[ ind[2] ][ ind[1] ][ ind[0] ] = true

		internal_area = (dir, k, j, i) ->
			res = false

			if k > data.length - 1 or \
			j > data[0].length - 1 or \
			i > data[0][0].length - 1
				return res
				
			ck_lst = if (dir != 1 and dir != 2 and k > 0) then [-1, 0] else [0]
			cj_lst = if (dir != 0 and dir != 2 and j > 0) then [-1, 0] else [0]
			ci_lst = if (dir != 0 and dir != 1 and i > 0) then [-1, 0] else [0]

			ck_lst.push(1) if (k + 1 == data.length - 1)
			cj_lst.push(1) if (j + 1 == data[0].length - 1)
			ci_lst.push(1) if (i + 1 == data[0][0].length - 1)

			if not res then for ck in ck_lst
				do (ck) ->
					if not res then for cj in cj_lst
						do (cj) ->
							if not res then for ci in ci_lst
								do (ci) ->
									if mask[k + ck][j + cj][i + ci]
										res = true
			res

		k_lst_main = get_segment(k_first, k_last, detail[0])
		j_lst_main = get_segment(j_first, j_last, detail[1])
		i_lst_main = get_segment(i_first, i_last, detail[2])

		k_lst_front = get_segment(k_first, k_last, 1)
		j_lst_front = get_segment(j_first, j_last, 1)
		i_lst_front = get_segment(i_first, i_last, 1)

		k_lst_back = get_segment(k_first, k_last, 1)
		j_lst_back = get_segment(j_first, j_last, 1)
		i_lst_back = get_segment(i_first, i_last, 1)

	filter_cells = if filter_list.length or filter_scalar.length then true else false

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

							if (filter_internal and
							i >= filter[2][0] and i <= filter[2][1]) or \
							filter_cells
								
								k0 = k + k1
								j0 = j + j1
												
								if internal_area(2, k0, j0, i)
									if filter_cells or (i in i_lst_filter)
										faces_internal.push(face_0, face_1)
								else if (i in i_lst_main)
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and directions[2] and
			(directions[3] or i_index == 0 or i_index == i_lst_front.length - 1)
				add_surface(vertices, scale_coeff, 
					faces, materials[2], 2)

			if (filter_internal or filter_cells) and faces_internal.length > 0 and 
			filter_directions[2] and (filter_directions[3] or i == i_lst_filter[0] or 
			i == i_lst_filter[i_lst_filter.length - 1])
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
							j >= filter[1][0] and j <= filter[1][1] or \
							filter_cells
								
								k0 = k + k1
												
								if internal_area(1, k0, j, i)
									if filter_cells or (j in j_lst_filter)
										faces_internal.push(face_0, face_1)
								else if (j in j_lst_main)
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and directions[1] and
			(directions[3] or j_index == 0 or j_index == j_lst_front.length - 1)
				add_surface(vertices, scale_coeff, 
					faces, materials[1], 1)

			if (filter_internal or filter_cells) and faces_internal.length > 0 and 
			filter_directions[1] and (filter_directions[3] or j == j_lst_filter[0] or 
			j == j_lst_filter[j_lst_filter.length - 1])
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
							k >= filter[0][0] and k <= filter[0][1] or \
							filter_cells
								if internal_area(0, k, j, i)
									if filter_cells or (k in k_lst_filter)
										faces_internal.push(face_0, face_1)
								else if (k in k_lst_main)
									faces.push(face_0, face_1)
							else
								faces.push(face_0, face_1)

			if faces.length > 0 and directions[0] and 
			(directions[3] or k_index == 0 or k_index == k_lst_front.length - 1)
				add_surface(vertices, scale_coeff, faces, materials[0], 0)

			if (filter_internal or filter_cells) and faces_internal.length > 0 and 
			filter_directions[0] and (filter_directions[3] or k == k_lst_filter[0] or 
			k == k_lst_filter[k_lst_filter.length - 1])
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

root.add_line = (pnts, scale_coeff, material, name, dashed=false) ->
	
	geometry = new THREE.BufferGeometry()
	
	geometry.setAttribute( 'position', new THREE.BufferAttribute( 
			new Float32Array(pnts), 3 
		) )
	
	geometry.computeBoundingSphere()
	
	
	if not dashed
		sceneObject = new THREE.Line( geometry, material )
	else
		sceneObject = new THREE.LineSegments( geometry, material )

	sceneObject.name = name
	
	sceneObject.scale.x = scale_coeff
	sceneObject.scale.y = scale_coeff
	sceneObject.scale.z = scale_coeff
	sceneObject.computeLineDistances();

	root.lines.add( sceneObject )

root.add_border_line = (vertices, scale_coeff, faces, material, name) ->
	
	geometry = new THREE.Geometry()

	geometry.vertices = vertices
	geometry.faces = faces

	geometry.computeBoundingSphere()

	sceneObject = new THREE.Mesh(geometry, material)

	sceneObject.name = name

	root.lines.add( sceneObject )

root.add_border_line_seg = (vertices, scale_coeff, faces, material, name) ->
	
	geometry = new THREE.Geometry()

	geometry.vertices = vertices
	geometry.faces = faces

	geometry.computeBoundingSphere()

	sceneObject = new THREE.Mesh(geometry, material)

	sceneObject.name = name

	root.lines_seg.add( sceneObject )
	
root.add_surface = (vertices, scale_coeff, faces, material, name) ->
	
	geometry = new THREE.Geometry()

	geometry.vertices = vertices
	geometry.faces = faces

	geometry.computeBoundingSphere()

	sceneObject = new THREE.Mesh(geometry)

	sceneObject.name = name

	sceneObject.scale.x = scale_coeff
	sceneObject.scale.y = scale_coeff
	sceneObject.scale.z = scale_coeff

	sceneObject.updateMatrix()

	root.faces_materials.push(material)
	root.faces_names.push(name)

	root.faces_geometry.merge(sceneObject.geometry, sceneObject.matrix, 
		root.faces_materials.length - 1)

root.GridLines =

	init: (data, scale_coeff, detail, directions, materials, colors, options,
		filter, filter_directions, filter_materials, filter_colors, 
		filter_options, filter_scalar, filter_list) ->

		root.lines_seg = new THREE.Object3D()
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

		d = [
			get_segment(0, k_last, detail[0]),
			get_segment(0, j_last, detail[1]),
			get_segment(0, i_last, detail[2])]

		if filter.length > 0

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

			root.filter_k_segment = get_segment(filter[0][0], filter[0][1], filter[0][2])
			root.filter_j_segment = get_segment(filter[1][0], filter[1][1], filter[1][2])
			root.filter_i_segment = get_segment(filter[2][0], filter[2][1], filter[2][2])

			filtered = (dir, k, j, i) ->
				res = if k >= filter[0][0] and k <= filter[0][1] and \
					j >= filter[1][0] and j <= filter[1][1] and \
					i >= filter[2][0] and i <= filter[2][1] then true else false
				
				if dir == 0 
					res = if i + 1 >= filter[2][0] and i + 1 <= filter[2][1] then \
						res else false
				if dir == 1 
					res = if j + 1 >= filter[1][0] and j + 1 <= filter[1][1] then \
						res else false
				if dir == 2 
					res = if k + 1 >= filter[0][0] and k + 1 <= filter[0][1] then \
						res else false

				res

			filter_d = [filter_k_segment, filter_j_segment, filter_i_segment]

			borders = [
				[0, data.length - 1], 
				[0, data[0].length - 1], 
				[0, data[0][0].length - 1],
				[filter[0][0], filter[0][1]], 
				[filter[1][0], filter[1][1]], 
				[filter[2][0], filter[2][1]]]

		else if filter_scalar.length 

			root.scalar = filter_scalar[0] + 2
			
			filtered = (dir, k, j, i) -> 
				res = false
				
				ck_lst = if (dir != 2 and k > 0) then [-1, 0] else [0]
				cj_lst = if (dir != 1 and j > 0) then [-1, 0] else [0]
				ci_lst = if (dir != 0 and i > 0) then [-1, 0] else [0]

				ck_lst.push(1) if (k + 1 == k_last)
				cj_lst.push(1) if (j + 1 == j_last)
				ci_lst.push(1) if (i + 1 == i_last)
				
				if not res then for ck in ck_lst
					do (ck) ->
						if not res then for cj in cj_lst
							do (cj) ->
								if not res then for ci in ci_lst
									do (ci) ->
										value = data[k + ck][j + cj][i + ci][scalar]
										if (value >= filter_scalar[1][0] and \
										value <= filter_scalar[1][1]) 
											res = true
				res

			filter_d = [
				get_segment(0, k_last, 1),
				get_segment(0, j_last, 1),
				get_segment(0, i_last, 1)]

			borders = [
				[0, data.length - 1], 
				[0, data[0].length - 1], 
				[0, data[0][0].length - 1]]

		else if filter_list.length

			mask = ([] for x in [0...data.length])

			for xk in [0...data.length]
				do (xk) ->
					mask[xk] = ([] for x in [0...data[0].length])
					for xj in [0...data[0].length]
						do (xj) -> 
							mask[xk][xj] = (false for [0...data[0][0].length])

			for ind in filter_list
				do (ind) ->
					if ind.length and mask.length > ind[2] and \
					mask[ ind[2] ].length > ind[1] and \
					mask[ ind[2] ][ ind[1] ].length > ind[0]
						mask[ ind[2] ][ ind[1] ][ ind[0] ] = true

			filtered = (dir, k, j, i) -> 
				res = false

				ck_lst = if (dir != 2 and k > 0) then [-1, 0] else [0]
				cj_lst = if (dir != 1 and j > 0) then [-1, 0] else [0]
				ci_lst = if (dir != 0 and i > 0) then [-1, 0] else [0]

				ck_lst.push(1) if (k + 1 == k_last)
				cj_lst.push(1) if (j + 1 == j_last)
				ci_lst.push(1) if (i + 1 == i_last)
				
				if not res then for ck in ck_lst
					do (ck) ->
						if not res then for cj in cj_lst
							do (cj) ->
								if not res then for ci in ci_lst
									do (ci) ->
										if mask[k + ck][j + cj][i + ci]
											res = true
				res

			filter_d = [
				get_segment(0, k_last, 1),
				get_segment(0, j_last, 1),
				get_segment(0, i_last, 1)]

			borders = [
				[0, data.length - 1], 
				[0, data[0].length - 1], 
				[0, data[0][0].length - 1]]
		else
			filtered = (k, j, i) -> false
			filter_d = [[], [], []]
			borders = [
				[0, data.length - 1], 
				[0, data[0].length - 1], 
				[0, data[0][0].length - 1]]

		if options.length < 1
			options = [false]
		if filter_options.length < 1
			filter_options = [false]
		
		gen_lines(data, scale_coeff, d, directions, materials, borders, options[0]
			filtered, filter_d, filter_directions, filter_materials, filter_options[0])

		if not options[0] and not filter_options[0]
			gen_lines_seg(data, scale_coeff, d, directions, colors, borders,
				filtered, filter_d, filter_directions, filter_colors)
		else
			gen_lines_seg(data, scale_coeff, d, directions, 
				colors, borders, filtered, filter_d, [
					false, false, false, false], 
				filter_colors, options[0])
			gen_lines_seg(data, scale_coeff, d, [
					directions[0], directions[1], directions[2], false], 
				colors, borders, filtered, filter_d, [
					false, false, false, false], 
				filter_colors)
			gen_lines_seg(data, scale_coeff, d, [
					false, false, false, false], 
				colors, borders, filtered, filter_d, filter_directions, 
				filter_colors, filter_options[0])
			gen_lines_seg(data, scale_coeff, d, [
					false, false, false, false], 
				colors, borders, filtered, filter_d, [
					filter_directions[0], filter_directions[1], filter_directions[2], false], 
				filter_colors, filter_options[0])

		[root.lines_seg, root.lines]

root.GridFaces = 
	init: (data, scale_coeff, detail, directions, materials, 
		filter, filter_directions, filter_materials, filter_scalar, filter_list) ->

		root.faces_geometry = new THREE.Geometry()

		root.faces_materials = []
		root.faces_names = []

		if directions.length < 3
			directions = [false, false, false, false]

		if filter_directions.length < 3
			filter_directions = [true, true, true, true]

		if filter.length == 0 and filter_scalar.length == 0 and \
		filter_list.length == 0

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
		else
			gen_surfaces(data, scale_coeff, detail, directions, materials, 
				filter, filter_directions, filter_materials, 
				filter_scalar, filter_list)


		root.faces = new THREE.Mesh(root.faces_geometry, new THREE.MeshFaceMaterial(
			root.faces_materials))

		[root.faces, root.faces_names]

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

		geometry.setAttribute('position', 
			new THREE.BufferAttribute( new Float32Array(positions), 3 ) );

		geometry.setAttribute('color', 
			new THREE.BufferAttribute( new Float32Array(colors), 3 ) );

		material = new THREE.PointsMaterial({vertexColors: THREE.VertexColors, size: radius * 2, sizeAttenuation: true})

		root.points = new THREE.Points( geometry, material )

		root.points.scale.set(scale_coeff, scale_coeff, scale_coeff)
		root.points.sortParticles = true;

		[root.points, root.cubes]