
var v_gui = new dat.GUI({ autoPlace: false, width: 450 });
var f_options = v_gui.addFolder('Viewlang');

var controls = {}
var name;

name = "viewlang.ru";
controls[ name ] = function() { window.location.href = "http://viewlang.ru"; }
f_options.add(controls, name);

if (!!$(".bottomWidgetsA > Button")[0]) {
	name = $(".bottomWidgetsA > Button")[0].innerHTML;
	controls[ name ] = function() { $(".bottomWidgetsA > Button")[0].click(); }
	f_options.add(controls, name);
}

if (!!$(".bottomWidgetsA > Button")[1]) {
	name = $(".bottomWidgetsA > Button")[1].innerHTML;
	controls[ name ] = function() { $(".bottomWidgetsA > Button")[1].click(); }
	f_options.add(controls, name);
}

if (!!$(".bottomWidgetsA > Button")[2]) {
	name = $(".bottomWidgetsA > Button")[2].innerHTML;
	controls[ name ] = function() {	$(".bottomWidgetsA > Button")[2].click(); }
	f_options.add(controls, name);
}

if (!!$(".bottomWidgetsA > Button")[3]) {
	name = $(".bottomWidgetsA > Button")[3].innerHTML;
	controls[ name ] = function() {	$(".bottomWidgetsA > Button")[3].click(); }
	f_options.add(controls, name);
}

if (!! $(".bottomWidgetsA > .CheckBox > span")[2]) {
	name = $(".bottomWidgetsA > .CheckBox > span")[2].innerHTML;
	controls[ name ] = false;
	f_options.add(controls, name).onFinishChange(
		function() { $(".bottomWidgetsA > .CheckBox")[2].click(); });
}

if (!! $(".bottomWidgetsA > .CheckBox > span")[3]) {
	name = $(".bottomWidgetsA > .CheckBox > span")[3].innerHTML;
	controls[ name ] = false;
	f_options.add(controls, name).onFinishChange(
		function() { $(".bottomWidgetsA > .CheckBox")[3].click(); });
}

if (!! $(".bottomWidgetsA > .CheckBox > span")[4]) {
	name = $(".bottomWidgetsA > .CheckBox > span")[4].innerHTML;
	controls[ name ] = false;
	f_options.add(controls, name).onFinishChange(
		function() { $(".bottomWidgetsA > .CheckBox")[4].click(); });
}

if (!!$(".bottomWidgetsA > .CheckBox > span")[5]) {
	name = $(".bottomWidgetsA > .CheckBox > span")[5].innerHTML;
	controls[ name ] = false;
	f_options.add(controls, name).onFinishChange(
		function() { $(".bottomWidgetsA > .CheckBox")[5].click(); });
}

try {
	$(".bottomWidgetsA").css("width", "0");
	$(".bottomWidgetsA").css("display", "none");
	$(".bottomWidgetsA").next().eq(0).css("height", "0");

	$("#viewlanglink").children()[0].remove();
	$("#viewlanglink")[0].appendChild(v_gui.domElement);
	$("#viewlanglink > div > div")[0].remove();

	$("#viewlanglink > div").eq(0).attr("style");
	$("#viewlanglink > div").eq(0).css("zIndex", 2000);
	$("#qmlSpace").css("zIndex", 1000);

} catch (e) {
}

try {
	var ss = document.styleSheets;

	for (var i = 0; i < ss.length; i++) {

		if (ss[i].cssRules) {
			var rules = ss[i].cssRules;

			var old_rules = [];
			var new_rules = [];

			for (var j = 0; j < rules.length; j++) {
				var st = rules[j].selectorText;

				if (st == ".dg li.title") {
					if ( rules[j].cssText.indexOf("background") > -1 ) {
						var text = rules[j].cssText.replace(
							/black/, "rgba(0, 0, 0, 0.85)").replace(
							/}/, "background-color: rgba(0, 0, 0, 0.85); }");
						
						old_rules.push(j);
						new_rules.push(text);

						new_rules.push(
							".dg .cr.boolean, .dg .cr.function, .dg .cr.string, .dg .cr.number " + 
							"{background: rgba(0, 0, 0, 0.7); }" );
					}
				}
			}

			for (var j = old_rules.length - 1; j >= 0; j--) {
				ss[i].deleteRule(old_rules[j]);
			}

			for (var j = 0; j < new_rules.length; j++) {
				ss[i].insertRule(new_rules[j], ss[i].cssRules.length);
			}
		}
	}
} catch (e) {
}