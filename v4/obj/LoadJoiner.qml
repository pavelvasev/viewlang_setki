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

	onLoadersChanged: {
	  var ll = loaders;
	  for (var i=0; i<ll.length; i++) {
	    ll[i].gridChanged.disconnect( joinTimer, joinTimer.restart );
	    ll[i].gridChanged.connect( joinTimer, joinTimer.restart );
	  }
	  joinTimer.restart()
	}

	Timer {
	  id: joinTimer
	  interval: 250
	  repeat: false	  
	  onTriggered: join()
	}
	
	function join() {
	  console.log("joiner called, loaders=",loaders );
	  if (!loaders || loaders.length <= 0) {
	    grid = [];
  	  return;
	  }

	  // без обнуления grid, проводимого именно в этом месте, в сцене 
	  // почему-то остается 6-й блок от сетки ris5.dat, загружаемой по умолчанию.
	  grid = [];

	  var l0 = loaders[0];

	  types = l0.types;
	  scale_coeff = l0.scale_coeff;
	  min = l0.min;
	  max = l0.max;

	  var rgrid = [];
	  var ll = loaders;
	  for (var i=0; i<ll.length; i++) {
	    var lo = ll[i];
	    for (var j=0; j<lo.grid.length; j++ )
	      rgrid.push( lo.grid[j] );
	  }

	  grid = rgrid;
	}
}