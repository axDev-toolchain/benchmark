var localJSVersion='07122007';

var MainLocalObj = {
	eventHandlers:[],
	data:
	{
		userSpecificData:false,
		weatherLoc:{
			locCode:'',
			zip:'',
			name:''
		},
		newsLoc:{
			zip:'',
			name:''
		}
	},
	internationalUser:false,
	setUserSpecificData:function(flag) { this.data.userSpecificData = flag; },
	setInternationalUser:function(flag) { this.internationalUser = flag; },
	setLocationZip:function(type, zip)
	{
		if(type=='weather' || type=='all')
		{
			this.data.weatherLoc.zip = zip;
		}
		if(type=='news' || type=='all')
		{
			this.data.newsLoc.zip = zip;
		}

	},
	setLocationName:function(type, name)
	{
		if(type=='weather' || type=='all')
		{
			this.data.weatherLoc.name = name;
		}
		if(type=='news' || type=='all')
		{
			this.data.newsLoc.name = name;
		}

	},
	setLocationLocCode:function(type, code)
	{
		if(type=='weather' || type=='all')
		{
			this.data.weatherLoc.locCode = code;
		}
	},
	loadDefaultData:function(edition)
	{
		var allCookies = CNN_getCookies();
		var lwpCookie = allCookies[ "lwp.weather" ] || null;
		var lwpLocCode='';
		var lwpZip='';

		if(edition)
		{
			if(edition == 'cnnIntl')
			{
				this.internationalUser = true;
			}
		}
		else
		{
			this.internationalUser = false;
		}
		if(lwpCookie)
		{
			var locationArr=unescape(lwpCookie).split('|');
			var weatherLocParse = locationArr[0];
			if(lwpCookie.indexOf('~')==-1)
			{
				weatherLocParse=lwpCookie.replace('|','~');
			}
			var lwpDataArr = locationArr[0].split('~');
			lwpLocCode=lwpDataArr[0];
			lwpZip=lwpDataArr[1];
		}
		if(cnnLocalStorage.contains('localData'))
		{
			this.data = cnnLocalStorage.get('localData');
			if(lwpZip && lwpLocCode) {
				this.data.weatherLoc.locCode = lwpLocCode;
    			this.data.weatherLoc.zip = lwpZip;
			}
			this.data.userSpecificData = true;
			this.triggerEvent('all/update');
		}
		else if(lwpZip)
		{
			if(checkZip(lwpZip))
			{
				this.data.userSpecificData = true;
				this.setLocationZip('all', lwpZip);
				this.setLocationLocCode('all', lwpLocCode);
				this.triggerEvent('all/update');
			}
			else
			{
				requestInternationalCityLookup(lwpZip,lwpLocCode,'all');
			}
		}
		else if(!this.internationalUser)
		{
			var randomCityData=
			[
				{
					name:'Welcome, NC',
					zip:'27374'
				},
				{
					name:'Cool, CA',
					zip:'95614'
				},
				{
					name:'Truth or Consequences, NM',
					zip:'87901'
				},
				{
					name:'Okay, OK',
					zip:'74446'
				},
				{
					name:'Ideal, GA',
					zip:'31041'
				},
				{
					name:'Success, MO',
					zip:'65570'
				},
				{
					name:'North, SC',
					zip:'29112'
				},
				{
					name:'Earth, TX',
					zip:'79031'
				},
				{
					name:'Odd, WV',
					zip:'25902'
				} 
  			];
			var randNum=Math.floor(Math.random()*randomCityData.length);

			var randomObj = randomCityData[randNum];
			this.setLocationZip('all', randomObj.zip);
			this.setLocationName('all', randomObj.name);
			this.triggerEvent('all/update');
		}
		this.triggerEvent('main/start');
		
	},
	save:function()
	{
		var expDate=new Date(1292112000000); //Sun, 12 Dec 2010 00:00:00 GMT
		var newVal = this.data.weatherLoc.locCode + '~' + this.data.weatherLoc.zip;
		var cookieValue = "";

	if(lwpCookie)
	{
			var weatherCookie = '';
	        var locationArr=unescape(lwpCookie).split('|');
	        locationArr.unshift(newVal);
			for (var i=0; i<locationArr.length; i++) {
				if (locationArr[i] != newVal && (weatherCookie.indexOf(locationArr[i]) == -1) || i == 0) {
					weatherCookie += locationArr[i];
					if (i < (locationArr.length - 1)) {
						weatherCookie += "|";
					}
				}			
			}
	} else {
		weatherCookie = newVal;
	}
		
	        	CNN_setCookie('lwp.weather', weatherCookie, 24*30*12, '/', document.domain);

		lwpQueryStr = 'weather='+this.data.weatherLoc.zip + '.' + this.data.weatherLoc.locCode + '&celcius='+allCookies[ "default.temp.units" ]; 
		CSIManager.getInstance().call('http:/\/svcs.cnn.com/weather/wrapper.jsp',lwpQueryStr,'cnnLWPWeather');	 
		
		cnnLocalStorage.put('localData', this.data, expDate);
		if(!cnnLocalStorage.save())
		{
			alert('unable to save data');
		}
	},
	addEventHandler:function(event, funcObj)
	{
		var eventHandlerArr = this.eventHandlers[event];
		if(!eventHandlerArr)
		{
			eventHandlerArr = new Array();
		}
		eventHandlerArr.push(funcObj);
		this.eventHandlers[event] = eventHandlerArr;
	},
	triggerEvent:function(event, args1, args2, args3)
	{
		var eventHandlerArr = this.eventHandlers[event];
		if(!eventHandlerArr)
		{
			eventHandlerArr = new Array();
		}
		for(var i=0;i<eventHandlerArr.length;i++)
		{
			var configObj = this.data;
			if(eventHandlerArr[i])
			{
				var funcObj = eventHandlerArr[i];
				if(args3)
				{
					funcObj( configObj, event, args1, args2, args3 );
				}
				else if(args2)
				{
					funcObj( configObj, event, args1, args2 );
				}else if(args1)
				{
					funcObj( configObj, event, args1 );
				}
				else
				{
					funcObj( configObj, event );
				}
			}
		}
	}
}

var omnitureStr = "var s=s_gi(s_account);s.linkTrackVars='events,products';s.linkTrackEvents='event2';s.events='event2';s.products=';Topix:Local;;;event2=1;';void(s.tl(this,'o','Topix Local Clickthrough'));";

function localUpdateData(name, zip, code, type)
{
	MainLocalObj.setLocationZip(type, zip);
	MainLocalObj.setLocationName(type, name);
	MainLocalObj.setLocationLocCode(type, code);
	MainLocalObj.setUserSpecificData(true);
	MainLocalObj.save();
	MainLocalObj.triggerEvent(type+'/update');
}

function requestLocalWeather(configObj)
{
	var weatherUrl='http://svcs.cnn.com/weather/getForecast';
	var weatherArgs='mode=json_html&zipCode='+configObj.weatherLoc.zip;
	if(configObj.weatherLoc.locCode)
	{
		weatherArgs+='&locCode='+configObj.weatherLoc.locCode;
	}
	if(MainLocalObj.internationalUser || allCookies[ "default.temp.units" ] == "true")
	{
		weatherArgs+='&celcius=true';
	}
	CSIManager.getInstance().call( weatherUrl, weatherArgs,'cnnWeatherDetailsToday', updateLocalWeather, false);

}
MainLocalObj.addEventHandler('weather/update',requestLocalWeather);
MainLocalObj.addEventHandler('all/update',requestLocalWeather);


function requestLocalNews(configObj)
{
	var newsUrl='http://local.cnn.com/local/cnn/json';
	if(checkZip(configObj.newsLoc.zip)){ var newsArgs='q='+configObj.newsLoc.zip; }
	else{ var newsArgs='q='+urlEncode(configObj.newsLoc.name); }
	CSIManager.getInstance().call( newsUrl, newsArgs,'cnnLocalNewsList', updateLocalNews, false);

}
MainLocalObj.addEventHandler('news/update',requestLocalNews);
MainLocalObj.addEventHandler('all/update',requestLocalNews);

function displayAppropriateSearchBoxes()
{
	if(!MainLocalObj.data.userSpecificData)
	{
		Element.show('cnnGetLocalBox');
	}
}
MainLocalObj.addEventHandler('main/start',displayAppropriateSearchBoxes);

function hideAppropriateSearchBoxes( type )
{
	if(MainLocalObj.data.userSpecificData)
	{
		Element.hide('cnnGetLocalBox');
	}
	if(type=='all'||type=='news')
	{
		Element.hide('cnnCustomNewsBox');
	}
	if(type=='all'||type=='weather')
	{
		Element.hide('cnnCustomWeatherBox');
	}
}


function updateLocalWeather(obj)
{
	var weatherLink='http://weather.cnn.com/weather/';
	if(MainLocalObj.internationalUser)
	{
		weatherLink='http://weather.edition.cnn.com/weather/intl/';
	}
	weatherLink += 'forecast.jsp?zipCode='+MainLocalObj.data.weatherLoc.zip;

	if(MainLocalObj.data.weatherLoc.locCode)
	{
		weatherLink+='&locCode='+MainLocalObj.data.weatherLoc.locCode;
	}
	var locStr= MainLocalObj.data.weatherLoc.name;
	var detailsToday='';
	var detailsTomorrow='';
	var chgStr = '';
	var degScale = (MainLocalObj.internationalUser || allCookies[ "default.temp.units" ] == "true" ? 'C' : 'F');

	if(obj.length>-1)
	{
		locStr= obj[0].location.city;
		if(obj[0].location.stateOrCountry)
		{
			locStr+= ', '+obj[0].location.stateOrCountry;
		}
	}
	if(MainLocalObj.data.userSpecificData)
	{
		chgStr = ' (<a href="javascript:changeLoc(\'weather\')">change</a>)';
	}

	for(var counter=0;counter<obj.length;counter++)
	{
		if(obj[counter] && obj[counter].forecast && obj[counter].forecast.days)
		{
			if(obj[counter].forecast.days.length>-1)
			{
				var today=obj[counter].forecast.days[0];
				detailsToday+='<a class="cnnDate" href="'+weatherLink+'&iref=wxtodayicon">'
					+'<img src="http://i.cdn.turner.com/cnn/.element/img/2.0/weather/03/'+today.icon+'" width="60" height="51" alt=""/></a>'
					+'<br/><a class="cnnDate" href="'+weatherLink+'&iref=wxtoday"><b>Today</b></a><br/>'
					+'<span class="cnnTemperature">HI '+today.high+'&deg;'+degScale+' '
					+'<span class="cnnVerticalBar">|</span> LO '+today.low+'&deg;'+degScale+'</span>';
			}
			if(obj[counter].forecast.days.length>0)
			{
				var tomorrow=obj[counter].forecast.days[1];
				detailsTomorrow+='<a class="cnnDate" href="'+weatherLink+'&iref=wxtomorrowicon">'
					+'<img src="http://i.cdn.turner.com/cnn/.element/img/2.0/weather/03/'+tomorrow.icon+'" width="60" height="51" alt=""/></a>'
					+'<br/><a class="cnnDate" href="'+weatherLink+'&iref=wxtomorrow"><b>Tomorrow</b></a><br/>'
					+'<span class="cnnTemperature">HI '+tomorrow.high+'&deg;'+degScale+' '
					+'<span class="cnnVerticalBar">|</span> LO '+tomorrow.low+'&deg;'+degScale+'</span>';
			}
		}
	}
	Element.update('cnnWeatherDetailsHeader','<p><span class="cnnHeaderLnk"><a href="'+weatherLink+'&iref=wxheader"><span>Weather</span> &raquo;</a></span></p>');
	Element.update('cnnWeatherDetailsTomorrow',detailsTomorrow);
	Element.update('cnnWeatherLocationMore','<span><b><a href="'+weatherLink+'&iref=wxcityname">'+locStr+'</a></b>'+chgStr+'</span><a href="'+weatherLink+'&iref=wxmorecities" class="cnnWeatherMoreCities">10 day forecast&nbsp;&raquo;</a><br/>');
	Element.show('cnnWeatherDetails');
	hideAppropriateSearchBoxes('weather');
	return detailsToday;
}


function updateLocalNews(obj)
{
	var ret='';
	var max=4;
	var chgStr = '';
	var displayStr='';
	if(MainLocalObj.data.userSpecificData)
	{
		chgStr = ' (<a href="javascript:changeLoc(\'news\')">change</a>)';
		if(!MainLocalObj.internationalUser) { max = 5; }
	}
	for(var counter=0;counter<obj.length;counter++)
	{
		var resultSet=obj[counter].ResultSet;
		if(parseInt(resultSet.statusCode) != 200 || resultSet.Result.length < 1)
		{
			ret+='<li>Sorry, we are unable to find any headlines for that location. Please try widening your search to a larger area</li>';
		}
		else
		{
			if(resultSet.country=="United States")
			{
				var displayStr=resultSet.city+', '+resultSet.state;
			}
			else
			{
				var displayStr=resultSet.country;
			}
			var result=resultSet.Result;
			for(var i=0;i<result.length;i++)
			{
				if(i<max)
				{
					ret+='<li><div class="cnnLocalSource">'
						+ '<a target="new" href="'+result[i].sourceurl+'" ';
					if(!MainLocalObj.internationalUser)
					{ 
						ret+='onclick="'+omnitureStr+'" ';
					}
					ret+='><span>'+result[i].source+'</span>'
						+ ' &raquo;</a></div>'
						+ '<div><a target="new" href="'+result[i].link+'" ';
					if(!MainLocalObj.internationalUser)
					{
						ret+=' onclick="'+omnitureStr+'"';
					}
					ret+= '>'+result[i].headline+'</a></div></li>';
				}
			}
		}
	}

	var htmlStr = '<span><b>'+displayStr+'</b>'+chgStr+'</span><div class="cnnWeatherMoreCities"><b>'+'from <a target="new" href="http://www.topix.com/redir/loc=prss-cnnlogo/http://www.topix.com/"';

	if(!MainLocalObj.internationalUser)
	{
		htmlStr += ' onclick="'+omnitureStr+'"';
	}
	htmlStr += '>Topix.com'+'</a></b></div><br/>';

	Element.update('cnnWeatherLocation', htmlStr);
	Element.show('cnnLocalNews');
	hideAppropriateSearchBoxes('news');
	return ret;

}

function requestInternationalCityLookup(zip, loc, type)
{
	var weatherUrl='http://svcs.cnn.com/weather/getForecast';
	var weatherArgs='mode=json_html&zipCode='+zip;
	if(loc)
	{
		weatherArgs+='&locCode='+loc;
	}
	if(MainLocalObj.internationalUser)
	{
		weatherArgs+='&celcius=true';
	}
	CSIManager.getInstance().call( weatherUrl, weatherArgs,type, updateInternationalCityData, true);
}

function updateInternationalCityData(obj, type)
{
	var locCode = '';
	var zip = '';
	var locationName = '';
	if(obj && (obj.length>-1) && obj[0].location && obj[0].location.city)
	{
		locCode = obj[0].location.locCode;
		locationName = obj[0].location.city;
		if(obj[0].location.stateOrCountry)
		{
			locationName+=', '+obj[0].location.stateOrCountry;
		}
		zip = obj[0].location.zip;
	}
	
	if(zip && locationName)
	{
		MainLocalObj.setLocationZip(type, zip);
		MainLocalObj.setLocationName(type, locationName);
		MainLocalObj.setLocationLocCode(type, locCode);
		MainLocalObj.setUserSpecificData(true);
		MainLocalObj.triggerEvent(type+'/update');
	}
	
}

function checkInput(inputMode, value)
{
	//First remove any html/script tags
	value = value.replace(/<[^>]*?>/g,'');
	var qryArg = value.toUpperCase();

	var validatorUrl='http://weather.cnn.com/weather/citySearch';
	var validatorArgs='search_term='+urlEncode(qryArg)+'&mode=json_html&filter=true';
	CSIManager.getInstance().call(validatorUrl, validatorArgs, urlEncode(inputMode+'|'+value), updateValidationData, true);
}

function updateValidationData(obj, idString)
{
	var rawData = urlDecode(idString).split('|');
	var cleanValue = trimWS(rawData[1]);
	//Capitalize, buffer with spaces to match on whole words
	var preparedValue = ' '+cleanValue.toUpperCase()+' ';
	
	var locationObj = '';
	
	if(obj.length>1) // There are multiple matches. Weed out the one we want.
	{
		var done=obj.length;
		var exactMatch=false;
		var noMatch=true;

		var possibleLocations = new Array();
		
		if(done>50) { done = 50;} // Max cap of 50

		for(var i=0;i<done;i++)
		{
			var match=obj[i].city+', '+obj[i].stateOrCountry;
			var objZip=obj[i].zip.toString();
			var objLocCode=obj[i].locCode;

			var preparedMatch=' '+trimWS(match.toUpperCase() )+' ';
	
			if( ( checkZip(cleanValue) && cleanValue == objZip ) || ( preparedValue == preparedMatch ) )
			{
				var newLocationObj = new Object();
				newLocationObj.zip = objZip;
				newLocationObj.locCode = objLocCode;
				newLocationObj.name = match;
				possibleLocations.push(newLocationObj);
				noMatch=false;
				exactMatch=newLocationObj;
				i=done;
			}
			else 
			{
				if(preparedMatch.indexOf(preparedValue) != -1)
				{
					var newLocationObj = new Object();
					newLocationObj.zip = objZip;
					newLocationObj.locCode = objLocCode;
					newLocationObj.name = match;
					possibleLocations.push(newLocationObj);
					noMatch=false;
				}
			}
		}//end for loop
		if(noMatch)
		{
			displayNoMatch(rawData[0], cleanValue);
		}
		else if(possibleLocations.length==1 || exactMatch)
		{
			if(!exactMatch)
			{
				exactMatch = possibleLocations[0];
			}
			locationObj = new Object();
			locationObj.name=exactMatch.city+', '+exactMatch.stateOrCountry;
			locationObj.zip=exactMatch.zip.toString();
			locationObj.locCode=exactMatch.locCode;

			localUpdateData(locationObj.name, locationObj.zip, locationObj.locCode, rawData[0]);
			hideAppropriateSearchBoxes(rawData[0]);
		}
		else
		{
			// We have a bunch of possible locations.
			displayMultipleMatches( possibleLocations, urlDecode( rawData[1] ), rawData[0]);
		}		
	}
	else if((obj.length==1) && (obj[0] && obj[0].locCode && obj[0].locCode!=''))
	{
		var tmpObj = obj[0];
		locationObj = new Object();
		locationObj.name=tmpObj.city+', '+tmpObj.stateOrCountry;
		locationObj.zip=tmpObj.zip.toString();
		locationObj.locCode=tmpObj.locCode;

		localUpdateData(locationObj.name, locationObj.zip, locationObj.locCode, rawData[0]);
		hideAppropriateSearchBoxes( rawData[0] );
	}
	else
	{
		displayNoMatch(rawData[0], cleanValue);
	}
	return '';
}

function displayMultipleMatches(matches, origVal, type)
{
	var val = '';
	var container = '';

	switch(type)
	{
		case 'news':
			val=$F('cnnCustomNewsInput');
			container='cnnCustomNewsContainer';
			break;
		case 'weather':
			val=$F('cnnCustomWeatherInput');
			container = 'cnnCustomWeatherContainer';
			break;
		default:
			val=$F('cnnGetLocalInput');
			container='cnnGetLocalContainer';
	}

	var htmlStr = '<b>We found '+matches.length+' results for "'+origVal+'"</b>'
		+'<ul id="cnnFindWeatherList" style="list-style:none">';

	for(var j=0;j<matches.length;j++)
	{
		htmlStr+= '<li><a href="javascript:void(0)" onclick="resetSearch(\''+type+'\');'
			+ 'localUpdateData(\''+matches[j].name+'\',\''+matches[j].zip
			+ '\',\''+matches[j].locCode + '\',\''+type+'\');">'
			+ matches[j].name+'</a></li>';
	}
	htmlStr+='</ul><div class="cnnPad3Top"> </div>';
	if( type=='all' && MainLocalObj.internationalUser )
	{
		htmlStr = '<div style="height:156px;">'+htmlStr+'</div>';
	}
	Element.update(container, htmlStr);
}

function displayNoMatch(type,val)
{
	var container='cnnGetLocalContainer';

	switch(type)
	{
		case 'news':
			container='cnnCustomNewsContainer';
			break;
		case 'weather':
			container = 'cnnCustomWeatherContainer';
			break;
		default:
			container='cnnGetLocalContainer';
	}

	var htmlStr='<b>We didn\'t find results for "'+val+'"</b>'
		+'<ul id="cnnWeatherErrorList"><li style="color:#727272">Check your spelling of the city name</li>'
		+'<li style="color:#727272">Make sure the U.S. ZIP code is accurate</li><li style="color:#727272">Use the '
		+'<a href="http://www.usps.com" target="new" class="cnnFindWeather">USPS</a> '
		+'for U.S. zip codes / city names</li></ul><div id="cnnFindWeatherSkip">'
		+'<a href="javascript:void(0)" class="skip" onclick="skipThis(\''+type+'\')">'
		+'skip this&nbsp;&raquo;</a></div>';

	if(type == 'all' && MainLocalObj.internationalUser)
	{
		htmlStr = '<div style="height:156px;">'+htmlStr+'</div>';
	}
	else if(type=='news')
	{
		htmlStr+='<div class="cnnPad70Top"> </div>';
	}
	Element.update(container, htmlStr);
}

function skipThis(type)
{
	resetSearch(type);
	if(type=='news')
	{
		Element.show('cnnLocalNews');
		Element.hide('cnnCustomNewsBox');
	}
	else if(type=='weather')
	{
		Element.show('cnnWeatherDetails');
		Element.hide('cnnCustomWeatherBox');
	}
}


function changeLoc(mode)
{
	if(mode=='news')
	{
		Element.hide('cnnLocalNews');
		Element.show('cnnCustomNewsBox');
	}
	else if(mode=='weather')
	{
		Element.hide('cnnWeatherDetails');
		Element.show('cnnCustomWeatherBox');
	}
}

function resetSearch(type)
{
	var container='';
	var fieldName='';
	var htmlStr = '';

	switch(type)
	{
		case 'news':
			fieldName='cnnCustomNewsInput';
			container='cnnCustomNewsContainer';
			break;
		case 'weather':
			fieldName='cnnCustomWeatherInput';
			container = 'cnnCustomWeatherContainer';
			break;
		default:
			if(type == 'all' && MainLocalObj.internationalUser)
			{
				htmlStr = '<div class="cnnPad156Top"> </div>';
			}
			fieldName='cnnGetLocalInput';
			container='cnnGetLocalContainer';
	}
	Element.update(container, htmlStr);
	$(fieldName).value='Enter a U.S./Intl city or ZIP code';
}


function trimWS(str)
{
	str=str.replace(/,/g,' ');
	str=str.replace(/^\s*(\S+)*\s*$/,"$1");
	str=str.replace(/(\s{1})\s*/g,"$1");
	return str;
}
function urlEncode(str)
{
	str=trimWS(str);
	str=str.replace(/st\./i,'saint');
	str=str.replace(/mt\./i,'mount');
	str=escape(str);
	return str;
}
function urlDecode(str)
{
	return unescape(str);
}

function checkZip(str)
{
	str=trimWS(str.toString());
	var bool=(str.match(/^\d{5}$/)!=null && str!='00000'?true:false);
	return bool;
}
