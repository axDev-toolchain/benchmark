var cnnad_tileID = cnnad_getID();
var cnnad_enabled = true;
var cnnad_adIframes = new Array();
var cnnad_adVault = new Array();
var cnnad_adCache = new Array();
var cnnad_interstitialPID = null;
var cnnad_interstitialPlaying = false;

// flag for geo targetting image
var alreadySwappedDETargetImage = false;
var cnnDEadDEonCookie = false;

// document domain security issues
var cnnDocDomain = cnnad_getTld(location.hostname);
if(cnnDocDomain) {document.domain = cnnDocDomain;}

function cnnad_debug (m)
{
	if (typeof(console) != 'undefined' && typeof(console.debug) != 'undefined')
	{
		console.debug(m);
	}
}

function cnnad_error (m)
{
	if (typeof(console) != 'undefined' && typeof(console.error) != 'undefined')
	{
		console.error(m);
	}
}

function cnnad_reverseString (input)
{
	// convert everything to a string
	input = "" + input;
	var output = '';

	if (input.length)
	{
		var i;
		for (i = input.length; i > 0; i--)
		{
			output += input.charAt(i-1);
		}
	}
	return(output);
}

function cnnad_getID() {
	return (cnnad_reverseString(new Date().getTime()));
}

function cnnad_renderAd(cnnad_url) {
	if(cnnad_enabled == true) {
		document.write("<script type=\"text/javascript\"");
		document.write(" src=\""+cnnad_url+"&tile="+cnnad_tileID+"\"></scr");
		document.write("ipt>");
	}
}

function cnnad_preview(cnnad_adstring) {
	if ( location.host.indexOf("turner.com") > -1) {
		// we are on preview (or on local subnet, so we have to use internal names)
		cnnad_adstring = cnnad_adstring.replace(new RegExp("ads\..*?\.com","gi"),"ads.turner.com");
	}
	return cnnad_adstring;
}

function cnnad_isBlocking (id)
{
	var blocking = false;

	if(document.getElementById('ad-'+id).style.display === 'none')
	{
		blocking = true;
	}

	else if (cnnad_interstitialPlaying === true)
	{
		blocking = true;
	}

	return blocking;
}

function cnnad_createIframe (id, url)
{
	var iframe = document.createElement('iframe');
	iframe.id = id;
	iframe.name = id;
	iframe.width = 0;
	iframe.height = 0;
	iframe.style.position = 'absolute';
	iframe.style.top = '-20px';
	iframe.style.left = '-20px';
	iframe.marginWidth = 0;
	iframe.marginHeight = 0;
	iframe.frameBorder = 0;
	iframe.scrolling = "no";
	iframe.allowTransparency = 'true';
	iframe.src = url;

	return iframe;
}

function cnnad_createAdHelper (adId, cnnad_url, cnnad_height, cnnad_width, target)
{
	if (cnnad_isBlocking(adId))
	{
		window.setTimeout(function(){cnnad_createAdHelper(adId,cnnad_url,cnnad_height,cnnad_width,target);},1000);
	}
	else
	{
		var d = document.getElementById('ad-' + adId);
		if (d)
		{
			d.appendChild(cnnad_createIframe(adId,cnnad_url));
		}
		else
		{
			if (!target) {
				document.write('<iframe ALLOWTRANSPARENCY="true" hspace="0" vspace="0" marginHeight="0" marginWidth="0" src="' + cnnad_url + '" border="0" frameBorder="0" height="0" width="0" scrolling="no"  id="'+adId+'" style="position: absolute; top: -20px; left: -20px;" ></iframe>');
			} else {
				document.getElementById(target).innerHTML = '<iframe ALLOWTRANSPARENCY="true" hspace="0" vspace="0" marginHeight="0" marginWidth="0" src="' + cnnad_url + '" border="0" frameBorder="0" height="0" width="0" scrolling="no"  id="'+adId+'" style="position: absolute; top: -20px; left: -20px;" ></iframe>';
			}
		}
	}
}

function cnnad_createAdNoTileId(adId,cnnad_url,cnnad_height,cnnad_width,target) {
	cnnad_url = cnnad_preview(cnnad_url);
	cnnad_url += 'domId=' + adId;
	cnnad_createAdHelper(adId,cnnad_url,cnnad_height,cnnad_width,target,false);
}

function cnnad_createAd(adId,cnnad_url,cnnad_height,cnnad_width,target) {
	cnnad_url = cnnad_preview(cnnad_url);
	cnnad_url += '&tile=' + cnnad_tileID + '&domId=' + adId;
	cnnad_createAdHelper(adId,cnnad_url,cnnad_height,cnnad_width,target,false);
}

function cnnad_writeAd(cnnad_callid,cnnad_url) {
        if(cnnad_enabled == true) {
                document.write("<script id=\"" + cnnad_callid + "\" type=\"text/javascript\" onload=\"cnnSendData();\"");
                document.write(" src=\""+cnnad_url+"&tile="+cnnad_tileID+"\"></scr");
                document.write("ipt>");
        }
}

function cnnad_showAd(cnnad_id) {
	var e = document.getElementById(cnnad_id);
	if (e)
	{
		e.style.position = 'relative';
		e.style.left = '0px';
		e.style.top = '0px';

		if (e.style.visibility === 'hidden')
		{
			e.style.visibility = 'visible';
		}
		if (e.style.display === 'none')
		{
			e.style.display = 'block';
		}
	}
	else 
	{
		cnnad_error("Could not find element by id: " + cnnad_id);
	}
}

function cnnad_setAdSize(docId,height,width) {
	var i = document.getElementById(docId);
        if (i)
	{
                i.height = height;
                i.width = width;
        }
	else 
	{
		cnnad_error("Could not find element by id: " + cnnad_id);
	}
}

function cnnad_readCookie( name ) {
        if ( document.cookie == '' ) { // there is no cookie, so go no further
            return false;
        } else { // there is a cookie
            var firstChar, lastChar;
                var theBigCookie = document.cookie;
                firstChar = theBigCookie.indexOf(name); // find the start of 'name'
                var NN2Hack = firstChar + name.length;
                if ( (firstChar != -1) && (theBigCookie.charAt(NN2Hack) == '=') ) { // if you found the cookie
                        firstChar += name.length + 1; // skip 'name' and '='
                        lastChar = theBigCookie.indexOf(';', firstChar); // Find the end of the value string (i.e. the next ';').
                        if (lastChar == -1) lastChar = theBigCookie.length;
                        return unescape( theBigCookie.substring(firstChar, lastChar) );
                } else { // If there was no cookie of that name, return false.
                        return false;
                }
        }
}

function cnnad_getTld (hostname)
{
	var data = hostname.split(".");
	if (data.length >= 2)
	{
		return (data[data.length-2] + "." + data[data.length-1]);
	}
	return(null);
}

function cnnad_refreshAds (type)
{
    if (! cnnad_adIframes)
    {
        return;
    }

    for (var i = 0; i < cnnad_adIframes.length; i++)
    {
		var targetAd = cnnad_adIframes[i];
		var newAdLoc = cnnad_findAd(type,targetAd.getWidth(),targetAd.getHeight());
		cnnad_swapAd(targetAd.getId(), newAdLoc);
    }
}

function cnnad_swapAd (id, newAdLoc)
{

	var elem = document.getElementById(id);
	if (elem)
	{
		elem.width = 0;
		elem.height = 0;
//		elem.style.position = 'absolute';
		elem.style.display = 'none';

		// if we find our ad in the cache, then use it
		if (cnnad_adCache[newAdLoc])
		{
			//alert("found ad via cache: " + cnnad_adCache[newAdLoc]);
			//elem.src = cnnad_adCache[newAdLoc];

		for (var j = 0; j < window.frames.length; j++) {
			try {
					if (window.frames[j].location.href.indexOf('domId='+id) > -1) {
						window.frames[j].location.replace(cnnad_adCache[newAdLoc]);
					}
 		} catch(e) {}
		}		

			return;
		}

		// if not in cache, we fetch it using an Ajax call
		// first we try Prototype
		if ((typeof Ajax != 'undefined') && (typeof Ajax.Request != 'undefined'))
		{
			var temp = new Ajax.Request(
								newAdLoc,
								{
									method:'get',
									onSuccess: function (req) {
										var newLoc = cnnad_parseResponse(req.responseText,id);
										newLoc = cnnad_preview(newLoc);
										if (newLoc)
										{
											cnnad_adCache[newAdLoc] = newLoc;
											//elem.src = newLoc;
		for (var j = 0; j < window.frames.length; j++) {
			try {
					if (window.frames[j].location.href.indexOf('domId='+id) > -1) {
						window.frames[j].location.replace(newLoc);
					}
 		} catch(e) {}
		}		

			return;
										}
									}
								});
		}
		// next try Dojo
		else if (typeof dojo != 'undefined')
		{
			if (typeof dojo.io == 'undefined')
			{
				dojo.require("dojo.io.*");
			}

			dojo.io.bind({
				url: newAdLoc,
				load: function (type, data, evt) {
							var newLoc = cnnad_parseResponse(data,id);
							newLoc = cnnad_preview(newLoc);
							if (newLoc)
							{
								cnnad_adCache[newAdLoc] = newLoc;
								elem.src = newLoc;
							}
					}
			});

		}
		// neither worked, we just give up and not do anything
		else
		{
			// do nothing 
			// alert("No way to fetch " + newAdLoc);
		}
	}
}

function cnnad_parseResponse (resp, id)
{
	// chop off everything before callout marker
	var startMarker = "<!-- CALLOUT|";
	var endMarker = "|CALLOUT -->";
	var start = resp.indexOf(startMarker);
	var end = resp.indexOf(endMarker);
	var loc = null;
	
	if (start >= 0 && end > start)
	{
		loc = resp.substring(start + startMarker.length ,end);
	}

	if (loc)
	{
		return(loc + "&domId=" + id + "&page.allowcompete=yes");
	}
	else
	{
		//alert("Parsing failed!");
		return null;
	}
}

function cnnad_findAd (type, width, height)
{
	var ret = null;
	for (var i = 0; i < cnnad_adVault.length; i++)
	{
		var ad = cnnad_adVault[i];
		if (ad.getType() == type && ad.getHeight() == height && ad.getWidth() == width)
		{
			ret = ad.getUrl();
			break;
		}
	}
	return ret;
}

function cnnad_getDEAdHeadCookie( imageRef ) {
	if (typeof(cnnad_readCookie) != "undefined") {
		cnnDEadDEonCookie = cnnad_readCookie( 'adDEon' );
	}
	var newSrc = "http://gdyn." + cnnad_getTld(location.hostname) + "/1.1/1.gif?" + new Date().getTime();
	if ( !alreadySwappedDETargetImage && !cnnDEadDEonCookie) {
		imageRef.src = newSrc;
		alreadySwappedDETargetImage = true;
	}
}

function cnnad_registerAd (type, width, height, url)
{
	var ad = new cnnad_AdObject (null, width, height, type, url);
	cnnad_adVault[cnnad_adVault.length] = ad;
}

function cnnad_registerSpace (id, width, height)
{
	var ad = new cnnad_AdObject(id, width, height, null, null);
	cnnad_adIframes[cnnad_adIframes.length] = ad;
}

function cnnad_endInterstitial(adId)
{
	// remove the interstitial node
	var adNode = document.getElementById('interstitial'+adId);
	if(adNode && adNode.parentNode)
	{
		adNode.parentNode.removeChild(adNode);
	}

	// remove the interstitial related CSS node
	var styleNode = document.getElementById('interstitialcss' + adId);
	if (styleNode && styleNode.parentNode)
	{
		styleNode.parentNode.removeChild(styleNode);
	}

	// for IE, we need to add another style to make sure tables show up
	if (typeof(document.createStyleSheet) != 'undefined')
	{
		var cssNode = document.createStyleSheet();
		cssNode.addRule('table','{display:inline}');
	}

	cnnad_interstitialPlaying = false;
}

function cnnad_startInterstitial(adId,cnnad_url,timeout) 
{
	cnnad_interstitialPlaying = true;
	var adUrl =  cnnad_url + '&tile=' + cnnad_tileID + '&page.allowcompete=yes&domId=' + adId;
	document.write('<div id="interstitial'+adId+'" class="interstitial" align="center"><iframe ALLOWTRANSPARENCY="true" hspace="0" vspace="0" marginHeight="0" marginWidth="0" src="'+adUrl+'" border="0" frameBorder="0" height="0" width="0" scrolling="no" id="'+adId+'"></iframe></div>');
	if(!timeout) { timeout = 1500;}
	cnnad_interstitialPID = window.setTimeout('cnnad_endInterstitial("'+adId+'");',timeout);
}

function cnnad_resetInterstitial(adId,timeout)
{
	cnnad_interstitialPlaying = true;
	var elem = document.getElementById(adId)
	if (null != elem && elem.height > 20 && elem.width > 20)
	{
		if(cnnad_interstitialPID)
		{
			window.clearTimeout(cnnad_interstitialPID);
		}
		if(!timeout) { timeout = 15000;}
		cnnad_interstitialPID = window.setTimeout('cnnad_endInterstitial("'+adId+'");',timeout);
	}
}

// ----- THE CNN ADS OBJECT ----- //
function cnnad_AdObject (id,width,height,type,url)
{
	this.id = id;
	this.width = width;
	this.height = height;
	this.type = type;
	this.url = url;

	this.getId = function () { return this.id; };
	this.setId = function (id) { this.id = id };

	this.getWidth = function () { return this.width; };
	this.setWidth = function (width) { this.width = width; };

	this.getHeight = function () { return this.height; };
	this.setHeight = function (height) { this.height = height; };

	this.getType = function () { return this.type; };
	this.setType = function (type) { this.type = type; };

	this.getUrl = function () { return this.url; };
	this.setUrl = function (url) { this.url = url; };

	this.toString = function () { return "[AD|ID=" + this.id + "|WIDTH=" + this.width + "|HEIGHT=" + this.height + "]"; };
}
// ------ /CNN ADS OBJECT ----- //

