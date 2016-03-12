// Объединятель результатов нескольких загрузчиков
Item 
{
  id: joiner
	property var loaders

	property var grid: []
	property var scale_coeff: 1
	property var min: []
	property var max: []

	property var types: []

	//property var q: join();
	onLoadersChanged: setTimeout( function() { join(); }, 200 );

	// и надо еще к каждому loader прицепиться с сигналом
	
	function join() {
	  console.log("joiner called, loaders=",loaders );
	  if (!loaders || loaders.length <= 0) return;

	  var l0 = loaders[0];
	  console.log("l0=",l0);

	  scale_coeff = l0.scale_coeff;
	  min = l0.min;
	  max = l0.max;
	  types = l0.types;

	  var rgrid = [];
	  var ll = loaders;
	  for (var i=0; i<ll.length; i++) {
	    var lo = ll[i];
	    //debugger;
	    lo.gridChanged.connect( joiner,loadersChanged );
	    for (var j=0; j<lo.grid.length; j++ )
	      rgrid.push( lo.grid[j] );
	  }
	  //grid = [];
	  grid = rgrid;
	  //console.log("joiner grid=",l0.grid.length );
	}
}