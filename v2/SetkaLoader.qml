// chunk-загрузчик сетки (простая версия)

Item {
  /// вход
  property var file // строка или объект File
  property var mult: 20
  property var order: 0
  
  /// выход
  property var zones // массив вершин точек по зонам. Первая зона это zones[0] -> массив вершин [x,y,z,x,y,z,...], вторая zones[1] -> [x,y,z,x,y,z,...]
  property var scalars // массив скалярных значений в узлах. Данные по первой зоне это scalars[0] 
                       // -> массив массивов: [ [s1,s2,s3,...,sN], .. ] - в первом подмассиве значения по первому скаляру,
                       // во втором - по второму и т.д
  property var zonesCount: zones.length
  
  /// внутренность
  property var q: load()
  
  property var minmax: []
  property var diff: [minmax[1]-minmax[0], minmax[3]-minmax[2], minmax[5]-minmax[4]]
  property var radii: Math.max( Math.max( diff[0], diff[1] ), diff[2] ) // макс значение стороны ограничиваюего прямоугольника

  onRadiiChanged: {
//    if (typeof(radii) === "undefined")
//     debugger;
    console.log("radii=",radii,"diff=",diff,"minmax=",minmax);
  }

/*  
  
//  Merger { IDEA объект обединяющий output-ы своих детев
//    id: merg
    property var minmax: [xsize.min,xsize.max,ysize.min,ysize.max,zsize.min,zsize.max]
  property var diff: [xsize.max-xsize.min,ysize.max-ysize.min,zsize.max-zsize.min]    
    MinMax {
      input: zones
      step: 3
      start: 0
      id: xsize
    }  

    MinMax {
      input: zones
      step: 3
      start: 1
      id: ysize      
    }    

    MinMax {
      input: zones
      step: 3
      start: 2
      id: zsize      
    }
  
//  }
  
  /*
  MinMaxInnerFind {
    mask: [1,0,3] /// только 1й уровень (нумерация с 0), старт с 0, шаг 3
  }

  //////
  MinMax { // MinMaxInside..? а не слишком ли много компонент?
    input: zones
    curprop: 2
    function prefilter(v,acc,i,len,depth) {
      if (depth) != 1) return false;
      if (i % 3 != curprop) return false; //z curprop=2
      return true;
    }
  } но вопрос - как это еще обобщить? или можно было бы может генерить prefilter, чтобы к свойству curprop не обращаться.

  MinMax {
    input: zones
    step: 3
    start: 1
  }  

    // Вопрос. Это встроенные start/step, то есть префильтр такой. Это не красиво так как это встроенность. Как бы нам так указывать пре-фильтры,
       чтобы это был и префильтр, и не встроенность, и краткость? Вариант - явно выстраивать цепочки наследования.. типа в глубине FilterNumbers посадили
       надкласс, дающий префильтр. Другой вариант какой-то такой
    
    ArrayStep {
      input: zones
      start: 1
      step: 3
      MinMax {
      }

    } выглядит уже натуральнее. Но. Как бы тут обойтись без копирования данных? Типа какие-то ленивые потоки должны тут возникать.
    А как бы я сделал это в жуже? ВЫкусил бы первую размерность и посчитал минмакс не задумываясь..
    Но реально уже хочется потоков без копирования каких-то. Итераторов каких-то.
    В принципе можно переопределить/посчитать заранее значение length, и наверное можно переопределить [].
  */

  function load() {
    var result = [];
    var zonedata = [];

    var resultscal  = [];
    var scalardata = [];

    var currTail = "";
    
    var mmax = [1e10,-1e10, 1e10,-1e10, 1e10,-1e10];
    var oorder = order;

    loadFileC( file, function(data, first, last, acc ) {

      if (currTail.length > 0) 
         data = currTail + data;
    
      var lines = data.split(/\r*\n+/);
      // http://stackoverflow.com/questions/4964484/why-does-split-on-an-empty-string-return-a-non-empty-array
      if (lines.length == 1 && lines[0] == "") lines.pop();

      currTail = last ? "" : lines.pop();

      console.log("chunk loaded, byte count=",data.length,"lines count=",lines.length);
      
      for (var i=0; i<lines.length; i++) {
        var line = lines[i];

        if (/["]/.test(line)) continue; // пропускаем если есть "

        if (/^\s*ZONE\s+/.test(line)) {
          if (zonedata.length > 0) { 
            //debugger;
            result.push( zonedata ); 
            resultscal.push( scalardata ); 
          }
          zonedata = []; scalardata = [];
          console.log("found new zone: ",line );
          continue;
        }

          var myRe = /\s*([0-9e+-.]+)/g;
          var rr,xx,yy,zz;
          rr = myRe.exec(line);
          if (!rr) continue; // не пропарсилось 1 число в строке - пропускаем
          xx = rr ? parseFloat(rr) : 0;
          rr = myRe.exec(line);
          yy = rr ? parseFloat(rr) : 0;
          rr = myRe.exec(line);
          zz = rr ? parseFloat(rr) : 0;          
          
          if (oorder === 0) {
	          zonedata.push( xx*mult );
	          zonedata.push( yy*mult );
	          zonedata.push( zz*mult );
	        }
	        else
	        {
	          zonedata.push( yy*mult );
	          zonedata.push( zz*mult );
	          zonedata.push( xx*mult );
	        }

          if (mmax[0] > xx) mmax[0] = xx;
          if (mmax[1] < xx) mmax[1] = xx;
          if (mmax[2] > yy) mmax[2] = yy;
          if (mmax[3] < yy) mmax[3] = yy;
          if (mmax[4] > zz) mmax[4] = zz;
          if (mmax[5] < zz) mmax[5] = zz;                    

          //zonedata.push( parseFloat( (myRe.exec(line) || "0.0") [0] ) * mult );
          //zonedata.push( parseFloat( (myRe.exec(line) || "0.0") [0] ) * mult );
          //zonedata.push( parseFloat( (myRe.exec(line) || "0.0") [0] ) * mult );
          
          var next;
          var tt=0;
          while (next = myRe.exec(line)) {
            if (typeof(scalardata[tt])==="undefined") scalardata[tt] = [];
            var d = parseFloat(next[0]);
            scalardata[tt].push( d );
            tt++;
          }
      }
      
      if (last) {
        if (zonedata.length > 0) { 
          //debugger;
          result.push( zonedata ); 
          resultscal.push( scalardata ); 
        }
        
        console.log( "v2/SetkaLoader.qml: last chunk parse complete" );
        scalars = resultscal;
        zones = result;
        minmax = mmax;
      }

    }); // обработчик чанка
  } // load




  //////////////////////////////////////////////////////////////////////////////
  // сервисные функции загрузки файлов по-блочно, потом уберем в движок


  // обработчик handler( data, first, last, acc );
  // first = true|false -- первый чанк
  // last = true|false -- последний чанк
  // acc = аккумулятор. но вообще вместо него удобнее контекстом пользоваться

  
  function loadFileC( file_or_path, handler ) {
      return loadFileBaseC( Qt.resolvedUrl(file_or_path), true, handler );
    }

  function loadFileBinaryC( file_or_path, handler ) {
      return loadFileBaseC( Qt.resolvedUrl(file_or_path), false, handler );
    }    


  ////////////////////////////////////////////////////////////////////////////////
    
    function loadFileBaseC( file_or_path, istext, handler ) {
      if (!file_or_path) return handler("",true,true,{} );

      if (file_or_path instanceof File) {
        parseLocalFile( file_or_path,istext,handler );
      }
      else
      {
	  	  return loadFileBase( file_or_path, istext, function(data) { 
  		     handler(data, true, true, {} );
  		  } ); 
	  	  // вызов загрузчика из вьюланга


        /* 
        if (file_or_path.length == 0) return handler("",true,true,{} );
        
        setFileProgress( file_or_path,"loading",5);

        jQuery.get( file_or_path, function(data) {
          setFileProgress( file_or_path,"parsing",50);
          handler(data,true,true,{} );
          setFileProgress( file_or_path);
        } );
        */
      }
    }
    


function parseLocalFile(file, istext, callback) 
{
	var fileSize = file.size;
	//var chunkSize = 16 * 1024 * 1024; // FIX
	var chunkSize = 2 * 1024 * 1024; // FIX
	
	var offset = 0;
	var block = null;
	var firstChunk = true;

	var accumulator = {}; 

	function updateProgress(evt,msg) {
		var percentLoaded = Math.round((offset / fileSize) * 100);
		setFileProgress( file.name,msg || "loading", percentLoaded ); // функция движка
	}

	var blockLoaded = function(evt) {

		if (evt.target.error == null) {
			offset += evt.target.result.length;
			updateProgress( 0,"parsing" );
			
			//if (offset < fileSize) blockLoad(offset, chunkSize, file);

			callback(evt.target.result, firstChunk, offset >= fileSize, accumulator );

			firstChunk = false;
		} else {
			console.log("Read error: " + evt.target.error);
			setFileProgress( file.name,"read error", -1 );
			return;
		}
			
		if (offset >= fileSize) { 
		    setFileProgress( file.name,"", -1 );
		    return;
		}
		
		blockLoad(offset, chunkSize, file);

		// TODO замерить: 1. Скорости загрузки при разных chunk-size. 2. Как влияет вынос blockload перед обработкой по callback.
	}

	var blockLoad = function(_offset, length, _file) {
		var r = new FileReader();
		var blob = _file.slice(_offset, length + _offset);
		
		r.onload = blockLoaded;
		r.onprogress = updateProgress;

		r.onerror = function(e) {
      setFileProgress( file.name,"LOCAL FILE READ ERROR");
      console.error("Local file read error. _file=",_file);
		}

		if (_offset == 0) {
		    setFileProgress( file.name,"loading", 0 );
			r.onloadstart = function(e) {
			    setFileProgress( file.name,"loading", 1 );
			};
		};
	  
    if (istext)
			r.readAsText(blob);
		else
	    r.readAsArrayBuffer(blob);
	}

	blockLoad(offset, chunkSize, file);
}
  
  
}