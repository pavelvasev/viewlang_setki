// Имя файла не Loader.qml так как Loader зарезервированное имя в qml
// также оно не SetkaLoader.qml так как в qmlweb есть баг, что не должно быть qml-файлов с одинаковыми именами.
Item 
{
	property var file
	property var coeff_scale: 15
	property var grid: []

	property var q: load()

	function getHex(i,j,k,z) {
	}

	function load() {
		
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

		var re_zone = /.*ZONE I=\s*(\d+),\s*J=\s*(\d+),\s*K=\s*(\d+),.*/i;

		loadFileC( file, function(data, first, last, acc ) {
			if (currTail.length > 0) data = currTail + data;
    
			var lines = data.split(/\r*\n+/);
			
			if (lines.length == 1 && lines[0] == "") lines.pop();

			currTail = last ? "" : lines.pop();

			for (var i = 0; i < lines.length; i++) {
				var line = lines[i];

				if (/["]/.test(line)) continue;

				var z = line.match(re_zone);

				if (!!z) {

					if (currK.length > 0) result.push( currK );
					currK = [];
					
					I = z[1]; J = z[2]; K = z[3];
					
					continue;
				}

				var myRe = /\s*([0-9e+-.]+)/g;

				var numb = [
					parseFloat( (myRe.exec(line) || "0.0") [0] ) * coeff_scale,
					parseFloat( (myRe.exec(line) || "0.0") [0] ) * coeff_scale,
					parseFloat( (myRe.exec(line) || "0.0") [0] ) * coeff_scale
				];

				for (var j = 0; j < numb.length; j++) {

					numb[j] =	parseFloat(numb[j]); 

					if (Min.length == j) { Min.push(numb[j]); } 
						else if(Min[j] > numb[j]) { Min[j] = numb[j]; };

					if (Max.length == j) { Max.push(numb[j])} 
						else if(Max[j] < numb[j]) { Max[j] = numb[j]; };
				};

				currI.push(numb);
				if (currI.length == I) {

					currJ.push(currI);

					if (currJ.length == J) {

						currK.push(currJ);

						if (currK.length == K) {
							result.push(currK); 
							
							currK = [];
						};
						currJ = [];
					};
					currI = [];
				};
			}
      
			if (last) {
				if (currK.length > 0) result.push( currK );
				currK = [];

				grid = result;
			}

		});
	
	}

	////////////////////////////////////////////////////////////////////////////
  
	function loadFileC( file_or_path, handler ) {
		return loadFileBaseC( Qt.resolvedUrl(file_or_path), true, handler );
    }

	function loadFileBinaryC( file_or_path, handler ) {
		return loadFileBaseC( Qt.resolvedUrl(file_or_path), false, handler );
	} 

	////////////////////////////////////////////////////////////////////////////
    
  function loadFileBaseC( file_or_path, istext, handler ) {
		if (!file_or_path) return handler("", true, true, {} );

		if (file_or_path instanceof File) {
			parseLocalFile( file_or_path, istext, handler );
		} else {
		  return loadFileBase( file_or_path, istext, function(data) { 
		     handler(data, true, true, {} );
		  } ); 
		  // вызов загрузчика из вьюланга
		
			if (file_or_path.length == 0) return handler("", true, true, {} );

			setFileProgress( file_or_path, "loading", 5 ); // ?

			jQuery.get( file_or_path, function(data) {
				setFileProgress( file_or_path, "parsing", 50);
				handler(data, true, true, {} );
				setFileProgress( file_or_path);
			} );
		}
	}
	
	function parseLocalFile(file, istext, callback) {
		var fileSize = file.size;
		var chunkSize = 2 * 1024 * 1024;
	
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
					accumulator );
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