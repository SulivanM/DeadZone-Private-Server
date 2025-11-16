package mx.rpc.http
{
   import flash.utils.getQualifiedClassName;
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   import mx.collections.ArrayCollection;
   import mx.core.mx_internal;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.managers.CursorManager;
   import mx.messaging.ChannelSet;
   import mx.messaging.channels.DirectHTTPChannel;
   import mx.messaging.config.LoaderConfig;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.messages.AsyncMessage;
   import mx.messaging.messages.HTTPRequestMessage;
   import mx.messaging.messages.IMessage;
   import mx.netmon.NetworkMonitor;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.rpc.AbstractOperation;
   import mx.rpc.AbstractService;
   import mx.rpc.AsyncDispatcher;
   import mx.rpc.AsyncToken;
   import mx.rpc.Fault;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.mxml.Concurrency;
   import mx.rpc.xml.SimpleXMLDecoder;
   import mx.rpc.xml.SimpleXMLEncoder;
   import mx.utils.ObjectProxy;
   import mx.utils.ObjectUtil;
   import mx.utils.StringUtil;
   import mx.utils.URLUtil;
   
   use namespace mx_internal;
   
   public class AbstractOperation extends mx.rpc.AbstractOperation
   {
      
      private static var _directChannelSet:ChannelSet;
      
      mx_internal static const RESULT_FORMAT_E4X:String = "e4x";
      
      mx_internal static const RESULT_FORMAT_FLASHVARS:String = "flashvars";
      
      mx_internal static const RESULT_FORMAT_OBJECT:String = "object";
      
      mx_internal static const RESULT_FORMAT_ARRAY:String = "array";
      
      mx_internal static const RESULT_FORMAT_TEXT:String = "text";
      
      mx_internal static const RESULT_FORMAT_XML:String = "xml";
      
      mx_internal static const CONTENT_TYPE_XML:String = "application/xml";
      
      mx_internal static const CONTENT_TYPE_FORM:String = "application/x-www-form-urlencoded";
      
      private static const ERROR_URL_REQUIRED:String = "Client.URLRequired";
      
      private static const ERROR_DECODING:String = "Client.CouldNotDecode";
      
      private static const ERROR_ENCODING:String = "Client.CouldNotEncode";
      
      public var argumentNames:Array;
      
      private var _requestTimeout:int = -1;
      
      private var _resultFormat:String = "object";
      
      public var serializationFilter:SerializationFilter;
      
      public var request:Object = {};
      
      private var _url:String;
      
      private var _useProxy:Boolean = false;
      
      public var xmlDecode:Function;
      
      public var xmlEncode:Function;
      
      public var headers:Object = {};
      
      private var _contentType:String = "application/x-www-form-urlencoded";
      
      mx_internal var _rootURL:String;
      
      mx_internal var _log:ILogger;
      
      mx_internal var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _concurrency:String;
      
      private var _method:String = "GET";
      
      private var _showBusyCursor:Boolean = false;
      
      public function AbstractOperation(param1:AbstractService = null, param2:String = null)
      {
         super(param1,param2);
         this.mx_internal::_log = Log.getLogger("mx.rpc.http.HTTPService");
         this.concurrency = Concurrency.MULTIPLE;
      }
      
      public function get method() : String
      {
         return this._method;
      }
      
      public function set method(param1:String) : void
      {
         this._method = param1;
      }
      
      public function get concurrency() : String
      {
         return this._concurrency;
      }
      
      public function set concurrency(param1:String) : void
      {
         this._concurrency = param1;
      }
      
      public function get requestTimeout() : int
      {
         return this._requestTimeout;
      }
      
      public function set requestTimeout(param1:int) : void
      {
         if(this._requestTimeout != param1)
         {
            this._requestTimeout = param1;
         }
      }
      
      public function get resultFormat() : String
      {
         return this._resultFormat;
      }
      
      public function set resultFormat(param1:String) : void
      {
         var _loc2_:SerializationFilter = null;
         var _loc3_:String = null;
         switch(param1)
         {
            case mx_internal::RESULT_FORMAT_OBJECT:
            case mx_internal::RESULT_FORMAT_ARRAY:
            case mx_internal::RESULT_FORMAT_XML:
            case mx_internal::RESULT_FORMAT_E4X:
            case mx_internal::RESULT_FORMAT_TEXT:
            case mx_internal::RESULT_FORMAT_FLASHVARS:
               break;
            default:
               if(param1 != null && (_loc2_ = SerializationFilter.mx_internal::filterForResultFormatTable[param1]) == null)
               {
                  _loc3_ = this.mx_internal::resourceManager.getString("rpc","invalidResultFormat",[param1,mx_internal::RESULT_FORMAT_OBJECT,mx_internal::RESULT_FORMAT_ARRAY,mx_internal::RESULT_FORMAT_XML,mx_internal::RESULT_FORMAT_E4X,mx_internal::RESULT_FORMAT_TEXT,mx_internal::RESULT_FORMAT_FLASHVARS]);
                  throw new ArgumentError(_loc3_);
               }
               this.serializationFilter = _loc2_;
         }
         this._resultFormat = param1;
      }
      
      protected function getSerializationFilter() : SerializationFilter
      {
         return this.serializationFilter;
      }
      
      public function get url() : String
      {
         return this._url;
      }
      
      public function set url(param1:String) : void
      {
         this._url = param1;
      }
      
      public function get useProxy() : Boolean
      {
         return this._useProxy;
      }
      
      public function set useProxy(param1:Boolean) : void
      {
         var _loc2_:ChannelSet = null;
         if(param1 != this._useProxy)
         {
            this._useProxy = param1;
            _loc2_ = this.getDirectChannelSet();
            if(!this.useProxy)
            {
               if(_loc2_ != mx_internal::asyncRequest.channelSet)
               {
                  mx_internal::asyncRequest.channelSet = _loc2_;
               }
            }
            else if(mx_internal::asyncRequest.channelSet == _loc2_)
            {
               mx_internal::asyncRequest.channelSet = null;
            }
         }
      }
      
      public function get contentType() : String
      {
         return this._contentType;
      }
      
      public function set contentType(param1:String) : void
      {
         this._contentType = param1;
      }
      
      public function get showBusyCursor() : Boolean
      {
         return this._showBusyCursor;
      }
      
      public function set showBusyCursor(param1:Boolean) : void
      {
         this._showBusyCursor = param1;
      }
      
      public function get rootURL() : String
      {
         if(this.mx_internal::_rootURL == null)
         {
            this.mx_internal::_rootURL = LoaderConfig.url;
         }
         return this.mx_internal::_rootURL;
      }
      
      public function set rootURL(param1:String) : void
      {
         this.mx_internal::_rootURL = param1;
      }
      
      override public function cancel(param1:String = null) : AsyncToken
      {
         if(this.showBusyCursor)
         {
            CursorManager.removeBusyCursor();
         }
         return super.cancel(param1);
      }
      
      public function sendBody(param1:Object) : AsyncToken
      {
         var _loc3_:Object = null;
         var _loc4_:AsyncToken = null;
         var _loc5_:Fault = null;
         var _loc6_:FaultEvent = null;
         var _loc7_:String = null;
         var _loc11_:String = null;
         var _loc12_:Object = null;
         var _loc13_:SimpleXMLEncoder = null;
         var _loc14_:XMLDocument = null;
         var _loc15_:Array = null;
         var _loc16_:int = 0;
         var _loc17_:Object = null;
         var _loc18_:Object = null;
         var _loc19_:* = undefined;
         var _loc20_:ChannelSet = null;
         var _loc2_:SerializationFilter = this.getSerializationFilter();
         if(Concurrency.SINGLE == this.concurrency && Boolean(mx_internal::activeCalls.hasActiveCalls()))
         {
            _loc4_ = new AsyncToken(null);
            _loc11_ = this.mx_internal::resourceManager.getString("rpc","pendingCallExists");
            _loc5_ = new Fault("ConcurrencyError",_loc11_);
            _loc6_ = FaultEvent.createEvent(_loc5_,_loc4_);
            new AsyncDispatcher(mx_internal::dispatchRpcEvent,[_loc6_],10);
            return _loc4_;
         }
         var _loc8_:String = this.contentType;
         var _loc9_:String = this.url;
         if((Boolean(_loc9_)) && _loc9_ != "")
         {
            _loc9_ = URLUtil.getFullURL(this.rootURL,_loc9_);
         }
         if(_loc2_ != null)
         {
            _loc8_ = _loc2_.getRequestContentType(this,param1,_loc8_);
            _loc9_ = _loc2_.serializeURL(this,param1,_loc9_);
            param1 = _loc2_.serializeBody(this,param1);
         }
         if(_loc8_ == mx_internal::CONTENT_TYPE_XML)
         {
            if(param1 is String && this.xmlEncode == null)
            {
               _loc3_ = param1 as String;
            }
            else if(!(param1 is XMLNode) && !(param1 is XML))
            {
               if(this.xmlEncode != null)
               {
                  _loc12_ = this.xmlEncode(param1);
                  if(null == _loc12_)
                  {
                     _loc4_ = new AsyncToken(null);
                     _loc7_ = this.mx_internal::resourceManager.getString("rpc","xmlEncodeReturnNull");
                     _loc5_ = new Fault(ERROR_ENCODING,_loc7_);
                     _loc6_ = FaultEvent.createEvent(_loc5_,_loc4_);
                     new AsyncDispatcher(mx_internal::dispatchRpcEvent,[_loc6_],10);
                     return _loc4_;
                  }
                  if(!(_loc12_ is XMLNode))
                  {
                     _loc4_ = new AsyncToken(null);
                     _loc7_ = this.mx_internal::resourceManager.getString("rpc","xmlEncodeReturnNoXMLNode");
                     _loc5_ = new Fault(ERROR_ENCODING,_loc7_);
                     _loc6_ = FaultEvent.createEvent(_loc5_,_loc4_);
                     new AsyncDispatcher(mx_internal::dispatchRpcEvent,[_loc6_],10);
                     return _loc4_;
                  }
                  _loc3_ = XMLNode(_loc12_).toString();
               }
               else
               {
                  _loc13_ = new SimpleXMLEncoder(null);
                  _loc14_ = new XMLDocument();
                  _loc15_ = _loc13_.encodeValue(param1,new QName(null,"encoded"),new XMLNode(1,"top")).childNodes.concat();
                  _loc16_ = 0;
                  while(_loc16_ < _loc15_.length)
                  {
                     _loc14_.appendChild(_loc15_[_loc16_]);
                     _loc16_++;
                  }
                  _loc3_ = _loc14_.toString();
               }
            }
            else
            {
               _loc3_ = XML(param1).toXMLString();
            }
         }
         else if(_loc8_ == mx_internal::CONTENT_TYPE_FORM)
         {
            _loc3_ = {};
            if(typeof param1 == "object")
            {
               _loc18_ = ObjectUtil.getClassInfo(param1);
               for each(_loc19_ in _loc18_.properties)
               {
                  _loc17_ = param1[_loc19_];
                  if(_loc17_ != null)
                  {
                     if(_loc17_ is Array)
                     {
                        _loc3_[_loc19_] = _loc17_;
                     }
                     else
                     {
                        _loc3_[_loc19_] = _loc17_.toString();
                     }
                  }
               }
            }
            else
            {
               _loc3_ = param1;
            }
         }
         else
         {
            _loc3_ = param1;
         }
         var _loc10_:HTTPRequestMessage = new HTTPRequestMessage();
         if(this.useProxy)
         {
            if(Boolean(_loc9_) && _loc9_ != "")
            {
               _loc10_.url = _loc9_;
            }
            if(NetworkMonitor.isMonitoring())
            {
               _loc10_.recordHeaders = true;
            }
         }
         else
         {
            if(!_loc9_)
            {
               _loc4_ = new AsyncToken(null);
               _loc7_ = this.mx_internal::resourceManager.getString("rpc","urlNotSpecified");
               _loc5_ = new Fault(ERROR_URL_REQUIRED,_loc7_);
               _loc6_ = FaultEvent.createEvent(_loc5_,_loc4_);
               new AsyncDispatcher(mx_internal::dispatchRpcEvent,[_loc6_],10);
               return _loc4_;
            }
            if(!this.useProxy)
            {
               _loc20_ = this.getDirectChannelSet();
               if(_loc20_ != mx_internal::asyncRequest.channelSet)
               {
                  mx_internal::asyncRequest.channelSet = _loc20_;
               }
            }
            if(NetworkMonitor.isMonitoring())
            {
               _loc10_.recordHeaders = true;
            }
            _loc10_.url = _loc9_;
         }
         _loc10_.contentType = _loc8_;
         _loc10_.method = this.method.toUpperCase();
         if(_loc8_ == mx_internal::CONTENT_TYPE_XML && _loc10_.method == HTTPRequestMessage.GET_METHOD)
         {
            _loc10_.method = HTTPRequestMessage.POST_METHOD;
         }
         _loc10_.body = _loc3_;
         _loc10_.httpHeaders = this.getHeaders();
         return this.mx_internal::invoke(_loc10_);
      }
      
      protected function getHeaders() : Object
      {
         return this.headers;
      }
      
      override mx_internal function processResult(param1:IMessage, param2:AsyncToken) : Boolean
      {
         var filter:SerializationFilter;
         var tmp:Object = null;
         var fault:Fault = null;
         var decoded:Object = null;
         var msg:String = null;
         var fault1:Fault = null;
         var decoder:SimpleXMLDecoder = null;
         var fault2:Fault = null;
         var fault3:Fault = null;
         var message:IMessage = param1;
         var token:AsyncToken = param2;
         var body:Object = message.body;
         this.mx_internal::_log.info("Decoding HTTPService response");
         this.mx_internal::_log.debug("Processing HTTPService response message:\n{0}",message);
         filter = this.getSerializationFilter();
         if(filter != null)
         {
            body = filter.deserializeResult(this,body);
         }
         if(body == null || body != null && body is String && StringUtil.trim(String(body)) == "")
         {
            mx_internal::_result = body;
            return true;
         }
         if(body is String)
         {
            if(this.resultFormat == mx_internal::RESULT_FORMAT_XML || this.resultFormat == mx_internal::RESULT_FORMAT_OBJECT || this.resultFormat == mx_internal::RESULT_FORMAT_ARRAY)
            {
               tmp = new XMLDocument();
               XMLDocument(tmp).ignoreWhite = true;
               try
               {
                  XMLDocument(tmp).parseXML(String(body));
               }
               catch(parseError:Error)
               {
                  fault = new Fault(ERROR_DECODING,parseError.message);
                  mx_internal::dispatchRpcEvent(FaultEvent.createEvent(fault,token,message));
                  return false;
               }
               if(this.resultFormat == mx_internal::RESULT_FORMAT_OBJECT || this.resultFormat == mx_internal::RESULT_FORMAT_ARRAY)
               {
                  if(this.xmlDecode != null)
                  {
                     decoded = this.xmlDecode(tmp);
                     if(decoded == null)
                     {
                        msg = this.mx_internal::resourceManager.getString("rpc","xmlDecodeReturnNull");
                        fault1 = new Fault(ERROR_DECODING,msg);
                        mx_internal::dispatchRpcEvent(FaultEvent.createEvent(fault1,token,message));
                     }
                  }
                  else
                  {
                     decoder = new SimpleXMLDecoder(makeObjectsBindable);
                     decoded = decoder.decodeXML(XMLNode(tmp));
                     if(decoded == null)
                     {
                        msg = this.mx_internal::resourceManager.getString("rpc","defaultDecoderFailed");
                        fault2 = new Fault(ERROR_DECODING,msg);
                        mx_internal::dispatchRpcEvent(FaultEvent.createEvent(fault2,token,message));
                     }
                  }
                  if(decoded == null)
                  {
                     return false;
                  }
                  if(makeObjectsBindable && getQualifiedClassName(decoded) == "Object")
                  {
                     decoded = new ObjectProxy(decoded);
                  }
                  else
                  {
                     ;
                  }
                  if(this.resultFormat == mx_internal::RESULT_FORMAT_ARRAY)
                  {
                     decoded = this.decodeArray(decoded);
                  }
                  mx_internal::_result = decoded;
               }
               else
               {
                  if(tmp.childNodes.length == 1)
                  {
                     tmp = tmp.firstChild;
                  }
                  mx_internal::_result = tmp;
               }
            }
            else if(this.resultFormat == mx_internal::RESULT_FORMAT_E4X)
            {
               try
               {
                  mx_internal::_result = new XML(String(body));
               }
               catch(error:Error)
               {
                  fault3 = new Fault(ERROR_DECODING,error.message);
                  mx_internal::dispatchRpcEvent(FaultEvent.createEvent(fault3,token,message));
                  return false;
               }
            }
            else if(this.resultFormat == mx_internal::RESULT_FORMAT_FLASHVARS)
            {
               mx_internal::_result = this.decodeParameterString(String(body));
            }
            else
            {
               mx_internal::_result = body;
            }
         }
         else
         {
            if(this.resultFormat == mx_internal::RESULT_FORMAT_ARRAY)
            {
               body = this.decodeArray(body);
            }
            mx_internal::_result = body;
         }
         return true;
      }
      
      override mx_internal function invoke(param1:IMessage, param2:AsyncToken = null) : AsyncToken
      {
         if(this.showBusyCursor)
         {
            CursorManager.setBusyCursor();
         }
         return super.mx_internal::invoke(param1,param2);
      }
      
      override mx_internal function preHandle(param1:MessageEvent) : AsyncToken
      {
         if(this.showBusyCursor)
         {
            CursorManager.removeBusyCursor();
         }
         var _loc2_:Boolean = Boolean(mx_internal::activeCalls.wasLastCall(AsyncMessage(param1.message).correlationId));
         var _loc3_:AsyncToken = super.mx_internal::preHandle(param1);
         if(Concurrency.LAST == this.concurrency && !_loc2_)
         {
            return null;
         }
         return _loc3_;
      }
      
      private function decodeArray(param1:Object) : Object
      {
         var _loc2_:Array = null;
         if(param1 is Array)
         {
            _loc2_ = param1 as Array;
         }
         else
         {
            if(param1 is ArrayCollection)
            {
               return param1;
            }
            _loc2_ = [];
            _loc2_.push(param1);
         }
         if(makeObjectsBindable)
         {
            return new ArrayCollection(_loc2_);
         }
         return _loc2_;
      }
      
      private function decodeParameterString(param1:String) : Object
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc2_:String = StringUtil.trim(param1);
         var _loc3_:Array = _loc2_.split("&");
         var _loc4_:Object = {};
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            _loc7_ = int(_loc6_.indexOf("="));
            if(_loc7_ != -1)
            {
               _loc8_ = _loc6_.substr(0,_loc7_);
               _loc8_ = _loc8_.split("+").join(" ");
               _loc8_ = unescape(_loc8_);
               _loc9_ = _loc6_.substr(_loc7_ + 1);
               _loc9_ = _loc9_.split("+").join(" ");
               _loc9_ = unescape(_loc9_);
               _loc4_[_loc8_] = _loc9_;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function getDirectChannelSet() : ChannelSet
      {
         var _loc1_:ChannelSet = null;
         var _loc2_:DirectHTTPChannel = null;
         if(_directChannelSet == null)
         {
            _loc1_ = new ChannelSet();
            _loc2_ = new DirectHTTPChannel("direct_http_channel");
            _loc2_.requestTimeout = this.requestTimeout;
            _loc1_.addChannel(_loc2_);
            _directChannelSet = _loc1_;
         }
         return _directChannelSet;
      }
   }
}

