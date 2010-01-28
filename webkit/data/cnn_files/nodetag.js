(function(){
var pfs={ "http://www.cnn.com/test/index.sc.html":{"nid":17647,"tr":1},
"http://www.cnn.com/POLITICS/":{"nid":4486,"tr":1},
"http://www.cnn.com/SHOWBIZ/":{"nid":17569,"tr":1},
"http://www.cnn.com/LIVING/":{"nid":17570,"tr":1},
"http://www.cnn.com/TRAVEL/":{"nid":4485,"tr":1},
"http://www.cnn.com/HEALTH/":{"nid":12187,"tr":1},
"http://www.cnn.com/WORLD/":{"nid":4481,"tr":1},
"http://www.cnn.com/CRIME/":{"nid":17568,"tr":1},
"http://www.cnn.com/TECH/":{"nid":4487,"tr":1},
"http://www.cnn.com/US/":{"nid":4482,"tr":1},
"http://weather.cnn.com":{"nid":4483,"tr":1} },d=document,w=window,u=(w.gm_fake_href)?w.gm_fake_href:w.location.href;

function z(n){
var s;

if (Math.random()>=n['tr']) return;

s=d.createElement('SCRIPT');
s.src='http://content.dl-rms.com/dt/s/'+n['nid']+'/s.js';
s.type='text/javascript';
d.getElementsByTagName('head')[0].appendChild(s);
}
function r(){
var n="",p;

while (1) {
	try {
	for (p in pfs)
	  if (u.substring(0,p.length)==p && p.length > n.length) 
		n=p;

	if (n.length > 0) {z(pfs[n]);return;}
	} catch (e) {}

	if (w==top) break;

	if (w==window&&u!=d.referrer)u=d.referrer;
	else w=w.parent;
}
}

if (d.readyState=="complete"){
	r();
} else if (w.addEventListener){ 
	w.addEventListener("load", r, false);
} else if (w.attachEvent){ 
	w.attachEvent("onload", r);
}
})();