function StorageManager() {
	if (StorageManager.caller != StorageManager.getInstance) {
		if((navigator.userAgent.indexOf('Safari')==-1) && (navigator.userAgent.indexOf('Opera')==-1)) {
			throw new Error("There is no public constructor for StorageManager.");
		}
	}
	this.currentStorageMechanism = false;
	this.getStorage = function(cookieOnly) {
		if (!this.currentStorageMechanism) {
			if (document.cookie || document.cookie=='') {
				this.currentStorageMechanism = new CookieStorageMechanism();
			}
			if (window.globalStorage && (window.globalStorage!=null)) {
				this.currentStorageMechanism = new DOMStorageMechanism();
			}
			if (navigator.userAgent.indexOf('MSIE')!=-1) {
				this.currentStorageMechanism = new IEStorageMechanism();
			}
			this.currentStorageMechanism.initialize();
		}
		return this.currentStorageMechanism;
	}
}

StorageManager.__instance__ = null; // static property

StorageManager.getInstance = function () {
	if (this.__instance__ == null) {
		this.__instance__ = new StorageManager();
	}
	return this.__instance__;
}

function AbstractStorageMechanism() {
	this.name = 'AbstractStorage';
	this.dataObjects = new Array();
	this.keysExpireDates = new Array();
	this.maxCapacity = Number.MAX_VALUE;
	this.singleEntrymaxCapacity = Number.MAX_VALUE;
	this.allKeys = new Array();
	this.onload = function(){}
	this.initialize = function() {
		this.dataObjects = new Array();
		this.allKeys = new Array();
		this.keysExpireDates = new Array();
	}
	this.setOnload = function(func) { 
		this.onload = func;
	}
	this.put = function(key, obj, expirationDate) {
		if(!this.dataObjects[key]) {
			if(!expirationDate) { expirationDate=new Date(new Date().getTime() + 7*24*3600000 ); } // setting default to expire in 7 days
			this.keysExpireDates[ key ] = expirationDate;
			this.allKeys.push(key);
		}
		this.dataObjects[key] = obj;
		return true;
	}
	this.get = function(key) {
		return this.dataObjects[key];
	}
	this.remove = function(key) {
		if(this.contains( key )) {
			var newArray = new Array();
			for(var i=0;i<this.allKeys.length;i++) {
				if(this.allKeys[i]!=key) {
					newArray.push(this.allKeys[i]);
				}
			}
			this.allKeys = newArray;
			this.dataObjects[key] = false;
		}
	}
	this.contains =function(key) {
		if(this.dataObjects[key]) { return true;} else { return false;}
	}
	this.getAllKeys = function(key) {
		return this.allKeys;
	}
	this.save = function() {}
	this.load = function(){this.onload();}	
	this.clear = function() {}
}

function CookieStorageMechanism() {
	this.name = 'CookieStorage';
	this.maxCapacity = 20480; // 20k
	this.path = '/';
	this.domain = '';
	this.secure = false;	
	this.createCookie = function(key,value,expiration) {
			document.cookie = key + '=' + value + ((expiration)?(';expires=' + expiration):'') + ((this.path)?';path=' + this.path:'') + ((this.domain)?';domain=' + this.domain:'') + ((this.secure && (this.secure == true))?'; secure':'');
	}
	this.save = function() {
		this.clear();
		var allKeys = this.getAllKeys();
		var lengthCount = 0;
		for(var i=0;i<allKeys.length;i++) {
			var currentKey = allKeys[i];
			var value = this.get(currentKey);
			var newObject = new Object();
			newObject.value = value;
			newObject.expireDate = (this.keysExpireDates[currentKey]).getTime();
			dataString = escape(JSON.stringify(newObject));
			if ((lengthCount + dataString.length) > this.maxCapacity)
				return false;
			else {
				lengthCount += dataString.length;
				this.createCookie('js_'+currentKey,dataString,(this.keysExpireDates[currentKey]).toGMTString());
			}
		}	
		return true;
	}
	this.load = function() {
		if ( document.cookie != '' ) {
			var cookieArr = document.cookie.split('; ');
			for(var i=0;i<cookieArr.length;i++) {
				var key = cookieArr[i].substring(0,cookieArr[i].indexOf('='));
				if(key.indexOf('js_')==0) {
					storedObject = eval('('+(unescape(cookieArr[i].substring(cookieArr[i].indexOf('=')+1)))+')');
					key = key.substring(3);
					this.put(key, storedObject.value, new Date(storedObject.expireDate) );
				}
			}
		}
		this.onload();
	}
	this.clear = function() {
		if (document.cookie != '') {
			var cookieArr = document.cookie.split('; ');
			for (var i = 0; i < cookieArr.length; i++) {
				var key = cookieArr[i].substring(0,cookieArr[i].indexOf('='));
				if (key.indexOf('js_') == 0) {
					toExpireDateString = (new Date((new Date()).getTime() - (24*60*60*60*1000))).toGMTString();
					this.createCookie(key,'clear this',toExpireDateString);
				}
			}
		}
	}
}

function DOMStorageMechanism() {
	this.name = 'DOMStorage';
	this.maxCapacity = 3145728; // 3M
	this.save = function() {
		var allKeys = this.getAllKeys();
		var storedObject = new Array();
		for(var i=0;i<allKeys.length;i++) {
			var currentKey = allKeys[i];
			var value = this.get(currentKey);
			var newObject = new Object();
			newObject.key = currentKey;
			newObject.value = value;
			newObject.expireDate = (this.keysExpireDates[currentKey]).toGMTString();
			storedObject.push(newObject);
		}	
		dataString = JSON.stringify(storedObject);
		if (dataString.length > this.maxCapacity)
			return false;
		else
			window.globalStorage[document.domain].storage = dataString;
		return true;
	}
	this.load = function() {
		var storedDataObjectsStr = window.globalStorage[document.domain].storage+'';
		if(storedDataObjectsStr)
		{
			storedDataObjects = eval('('+storedDataObjectsStr+')');
			if(storedDataObjects && storedDataObjects!='')
			{
				for(var i=0;i<storedDataObjects.length;i++) 
				{
					var storedObject = storedDataObjects[i];
					if ((new Date(storedObject.expireDate)).getTime() > (new Date().getTime())) 
					{
						this.put(storedObject.key, storedObject.value, new Date(storedObject.expireDate));
					}					
				}
			}
		}
		this.onload();
	}
	this.clear = function() {
		window.globalStorage[document.domain].storage = JSON.stringify(new Object());
	}	
}

function IEStorageMechanism() {
	this.name = 'IEStorage';
	this.maxCapacity = 65536;
	this.initialize = function() {
		this.dataObjects = new Array();
		this.allKeys = new Array();
		this.keysExpireDates = new Array();
		this.dataHook = false;
		var newIframeNode = document.createElement('iframe');
		newIframeNode.setAttribute('src','/.element/js/2.0/scripts/IEPersistence.html');
		newIframeNode.setAttribute('name','IEPersistence');
		document.documentElement.appendChild(newIframeNode);
	}
	this.load = function() {}
	this.save = function () {
		var allKeys = this.getAllKeys();
		var storedObject = new Array();
		for(var i=0;i<allKeys.length;i++) {
			var currentKey = allKeys[i];
			var value = this.get(currentKey);
			var newObject = new Object();
			newObject.key = currentKey;
			newObject.value = value;
			newObject.expireDate = (this.keysExpireDates[currentKey]).toGMTString();
			storedObject.push(newObject);
		}	
		dataString = JSON.stringify(storedObject);
		if (dataString.length > this.maxCapacity)
			return false;
		else
			this.dataHook.saveData(JSON.stringify( storedObject ));
		return true;
	}
	this.clear = function () {
		this.dataHook.saveData('');
	}
}

CookieStorageMechanism.prototype = new AbstractStorageMechanism;
DOMStorageMechanism.prototype = new AbstractStorageMechanism;
IEStorageMechanism.prototype = new AbstractStorageMechanism;

/*
Copyright (c) 2005 JSON.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The Software shall be used for Good, not Evil.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

Array.prototype.______array = '______array';

var JSON = {
    org: 'http://www.JSON.org',
    copyright: '(c)2005 JSON.org',
    license: 'http://www.crockford.com/JSON/license.html',

    stringify: function (arg, namedValue) {
        var c, i, l, s = '', v;

        switch (typeof arg) {
        case 'object':
            if (arg) {
                if (arg.______array == '______array') {
                    for (i = 0; i < arg.length; ++i) {
                        v = this.stringify(arg[i]);
                        if (s) {
                            s += ',';
                        }
                        s += v;
                    }
                    return '[' + s + ']';
                } else if (typeof arg.toString != 'undefined') {
                    for (i in arg) {
                        v = arg[i];
                        if (typeof v != 'undefined' && typeof v != 'function') {
                            v = this.stringify(v);
                            if (s) {
                                s += ',';
                            }
                            s += this.stringify(i, true) + ':' + v;
                        }
                    }
                    return '{' + s + '}';
                }
            }
            return 'null';
        case 'number':
            return isFinite(arg) ? String(arg) : 'null';
        case 'string':
            l = arg.length;
			if(!namedValue)
			{
	            s = '"';
			}
            for (i = 0; i < l; i += 1) {
                c = arg.charAt(i);
                if (c >= ' ') {
                    if (c == '\\' || c == '"') {
                        s += '\\';
                    }
                    s += c;
                } else {
                    switch (c) {
                        case '\b':
                            s += '\\b';
                            break;
                        case '\f':
                            s += '\\f';
                            break;
                        case '\n':
                            s += '\\n';
                            break;
                        case '\r':
                            s += '\\r';
                            break;
                        case '\t':
                            s += '\\t';
                            break;
                        default:
                            c = c.charCodeAt();
                            s += '\\u00' + Math.floor(c / 16).toString(16) +
                                (c % 16).toString(16);
                    }
                }
            }
			if(!namedValue)
			{
	            return s + '"';
			}
			else
			{
            return s;
			}
        case 'boolean':
            return String(arg);
        default:
            return 'null';
        }
    },
    parse: function (text) {
        var at = 0;
        var ch = ' ';

        function error(m) {
            throw {
                name: 'JSONError',
                message: m,
                at: at - 1,
                text: text
            };
        }

        function next() {
            ch = text.charAt(at);
            at += 1;
            return ch;
        }

        function white() {
            while (ch != '' && ch <= ' ') {
                next();
            }
        }

        function str() {
            var i, s = '', t, u;

            if (ch == '"') {
outer:          while (next()) {
                    if (ch == '"') {
                        next();
                        return s;
                    } else if (ch == '\\') {
                        switch (next()) {
                        case 'b':
                            s += '\b';
                            break;
                        case 'f':
                            s += '\f';
                            break;
                        case 'n':
                            s += '\n';
                            break;
                        case 'r':
                            s += '\r';
                            break;
                        case 't':
                            s += '\t';
                            break;
                        case 'u':
                            u = 0;
                            for (i = 0; i < 4; i += 1) {
                                t = parseInt(next(), 16);
                                if (!isFinite(t)) {
                                    break outer;
                                }
                                u = u * 16 + t;
                            }
                            s += String.fromCharCode(u);
                            break;
                        default:
                            s += ch;
                        }
                    } else {
                        s += ch;
                    }
                }
            }
            error("Bad string");
        }

        function arr() {
            var a = [];

            if (ch == '[') {
                next();
                white();
                if (ch == ']') {
                    next();
                    return a;
                }
                while (ch) {
                    a.push(val());
                    white();
                    if (ch == ']') {
                        next();
                        return a;
                    } else if (ch != ',') {
                        break;
                    }
                    next();
                    white();
                }
            }
            error("Bad array");
        }

        function obj() {
            var k, o = {};

            if (ch == '{') {
                next();
                white();
                if (ch == '}') {
                    next();
                    return o;
                }
                while (ch) {
                    k = str();
                    white();
                    if (ch != ':') {
                        break;
                    }
                    next();
                    o[k] = val();
                    white();
                    if (ch == '}') {
                        next();
                        return o;
                    } else if (ch != ',') {
                        break;
                    }
                    next();
                    white();
                }
            }
            error("Bad object");
        }

        function num() {
            var n = '', v;
            if (ch == '-') {
                n = '-';
                next();
            }
            while (ch >= '0' && ch <= '9') {
                n += ch;
                next();
            }
            if (ch == '.') {
                n += '.';
                while (next() && ch >= '0' && ch <= '9') {
                    n += ch;
                }
            }
            if (ch == 'e' || ch == 'E') {
                n += 'e';
                next();
                if (ch == '-' || ch == '+') {
                    n += ch;
                    next();
                }
                while (ch >= '0' && ch <= '9') {
                    n += ch;
                    next();
                }
            }
            v = +n;
            if (!isFinite(v)) {
                error("Bad number");
            } else {
                return v;
            }
        }

        function word() {
            switch (ch) {
                case 't':
                    if (next() == 'r' && next() == 'u' && next() == 'e') {
                        next();
                        return true;
                    }
                    break;
                case 'f':
                    if (next() == 'a' && next() == 'l' && next() == 's' &&
                            next() == 'e') {
                        next();
                        return false;
                    }
                    break;
                case 'n':
                    if (next() == 'u' && next() == 'l' && next() == 'l') {
                        next();
                        return null;
                    }
                    break;
            }
            error("Syntax error");
        }

        function val() {
            white();
            switch (ch) {
                case '{':
                    return obj();
                case '[':
                    return arr();
                case '"':
                    return str();
                case '-':
                    return num();
                default:
                    return ch >= '0' && ch <= '9' ? num() : word();
            }
        }

        return val();
    }
};
