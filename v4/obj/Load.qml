
Item 
{
	property var files
	property var grid: []
	property var scale_coeff: 1
	property var min: []
	property var max: []

	property var types: []

	property var status: 0

	onFilesChanged: { 
	  console.log( "@@@@@@@@@@@@@@@@@ onFilesChanged => reloadTimer.start();" );
	  console.trace();
	  reloadTimer.start();
	}

	Timer {
	  id: reloadTimer
	  interval: 250 // ms
	  onTriggered: load()
	}

	function load() {
	  console.log( "@@@@@@@@@@@@@@@@@ Load::load(), files=",files );
		status = 0;

		var blocks = [];
		
		for (var i = 0; i < files.length; i++)
			blocks.push(1);

		var file_names = [];

		for (var i = 0; i < files.length; i++)
			file_names.push(files[i].name || files[i].split("/").pop());
		
		var result = [];

		var currTail = "";

		var I = 0;
		var J = 0;
		var K = 0;

		var currI = [];
		var currJ = [];
		var currK = [];

		var Min = [];
		var Max = [];

		types = [];

		var re_zone = /.*ZONE I=\s*(\d+),\s*J=\s*(\d+),\s*K=\s*(\d+),.*/i;

		var files_counter = 0;

		for (var fi = 0; fi < files.length; ++fi) {
			var file = files[fi];

			loadFileC( file, fi, function(data, first, last, acc, id) {
				if (currTail.length > 0) data = currTail + data;
				
				var lines = data.split(/\r*\n+/);
				
				if (lines.length == 1 && lines[0] == "") lines.pop();

				currTail = last ? "" : lines.pop();

				for (var i = 0; i < lines.length; i++) {
					var line = lines[i];

					if (line == '') continue;
					if (/["]/.test(line)) continue;

					var z = line.match(re_zone);

					if (!!z) {

						if (currK.length > 0) {

							result.push( currK );
							currK = [];
						}

						I = z[1]; J = z[2]; K = z[3];
						
						continue;
					}

					var numb = line.match(/(\-?\d\S+)/g);

					if (!!numb) { //

						for (var j = 0; j < numb.length; j++) {

							numb[j] = parseFloat(numb[j]); 

							if (Min.length == j) { Min.push(numb[j]); } 
								else if(Min[j] > numb[j]) { Min[j] = numb[j]; };

							if (Max.length == j) { Max.push(numb[j])} 
								else if(Max[j] < numb[j]) { Max[j] = numb[j]; };

							if (j > 2)	{
								if (types.length == j - 3) types.push({});

								if (!!types[j - 3])
								{
									n = numb[j];

									if (Number(n) === n && n % 1 !== 0)
										types[j - 3] = null;
									else
										types[j - 3][n] = 1;
								}
							}
						};

						currI.push(numb);
						if (currI.length == I) {

							currJ.push(currI);

							if (currJ.length == J) {

								currK.push(currJ);

								if (currK.length == K) {
									currK.blockname = "[" + blocks[id].toString() + 
										"," + file_names[id] + "]";

									blocks[id] ++;

									result.push(currK); 
									
									currK = [];
								};
								currJ = [];
							};
							currI = [];
						};
					};
				}

				if (last) {
					currK.blockname = "[" + blocks[id].toString() + 
						"," + file_names[id] + "]";
					
					blocks[id] ++;

					if (currK.length > 0) result.push( currK );
					currK = [];

					scale_coeff = calc_scale_coeff(Min, Max);
					
					grid = result;
					min = Min;
					max = Max;

					files_counter ++;

					if(files_counter == files.length) {
						status = grid.length;
					}
				}

			});
		}
	}

	function calc_scale_coeff(Min, Max) {
		var m = Math.max(
				Math.abs(Min[0]), Math.abs(Min[1]), Math.abs(Min[2]),
				Max[0], Max[1], Max[2]
			);

		return Math.round(25 / m);
	}

	///////////////////////////////////////////////////////////////////////////
	
	function loadFileC( file_or_path, id, handler ) {
		return loadFileBaseC( Qt.resolvedUrl(file_or_path), id, true, handler );
	}

	function loadFileBinaryC( file_or_path, id, handler ) {
		return loadFileBaseC( Qt.resolvedUrl(file_or_path), id, false, handler );
	} 

	///////////////////////////////////////////////////////////////////////////
	
	function loadFileBaseC( file_or_path, id, istext, handler ) {
		if (!file_or_path) return handler( "", true, true, {}, id );

		if (file_or_path instanceof File) {
			parseLocalFile( file_or_path, id, istext, handler );
		} else {
			return loadFileBase( file_or_path, istext, function(data) { 
				handler( data, true, true, {}, id );
			} ); 
		
			if (file_or_path.length == 0) return handler("", true, true, {}, id );

			setFileProgress( file_or_path, "loading", 5 ); // ?

			jQuery.get( file_or_path, function(data) {
				setFileProgress( file_or_path, "parsing", 50);
				handler( data, true, true, {}, id );
				setFileProgress( file_or_path);
			} );
		}
	}
	
	function parseLocalFile(file, id, istext, callback) {
		var fileSize = file.size;
		var chunkSize = 20 * 1024 * 1024;
	
		var offset = 0;
		var block = null;
		var firstChunk = true;

		var accumulator = {}; 

		function updateProgress(evt, msg) {
			var percentLoaded = Math.round((offset / fileSize) * 100);

			setFileProgress( file.name, msg || "loading", percentLoaded );
		}

		var blockLoaded = function(evt) {
			if (evt.target.error == null) {
				offset += evt.target.result.length;
				updateProgress( 0, "parsing" );

				callback(evt.target.result, firstChunk, offset >= fileSize, 
					accumulator, id );
				firstChunk = false;

			} else {
				console.log("Read error: " + evt.target.error);
				setFileProgress( file.name, "read error", -1 );
				
				return;
			}
			
			if (offset >= fileSize) { 
				setFileProgress( file.name, "", -1 );
				
				return;
			}

			blockLoad(offset, chunkSize, file);
		}

		var blockLoad = function(_offset, length, _file) {
			var r = new FileReader();
			var blob = _file.slice(_offset, length + _offset);
		
			r.onload = blockLoaded;
			r.onprogress = updateProgress;

			if (_offset == 0) {
				setFileProgress( file.name, "loading", 0 );
				r.onloadstart = function(e) {
					setFileProgress( file.name, "loading", 1 );
				};
			};

			r.onerror = function(e) {
				setFileProgress( file.name,"LOCAL FILE READ ERROR");
				console.error("Local file read error. _file=",_file);
			}

			if (istext)
				r.readAsText(blob);
			else
				r.readAsArrayBuffer(blob);
		}

		blockLoad(offset, chunkSize, file);
	}

}