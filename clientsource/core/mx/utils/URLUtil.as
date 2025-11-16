package mx.utils
{
   import mx.messaging.config.LoaderConfig;
   
   public class URLUtil
   {
      
      private static const SQUARE_BRACKET_LEFT:String = "]";
      
      private static const SQUARE_BRACKET_RIGHT:String = "[";
      
      private static const SQUARE_BRACKET_LEFT_ENCODED:String = encodeURIComponent(SQUARE_BRACKET_LEFT);
      
      private static const SQUARE_BRACKET_RIGHT_ENCODED:String = encodeURIComponent(SQUARE_BRACKET_RIGHT);
      
      public static const SERVER_NAME_TOKEN:String = "{server.name}";
      
      public static const SERVER_PORT_TOKEN:String = "{server.port}";
      
      private static const SERVER_NAME_REGEX:RegExp = /\{server.name\}/g;
      
      private static const SERVER_PORT_REGEX:RegExp = /\{server.port\}/g;
      
      public function URLUtil()
      {
         super();
      }
      
      public static function getServerNameWithPort(param1:String) : String
      {
         var _loc2_:int = param1.indexOf("/") + 2;
         var _loc3_:int = int(param1.indexOf("/",_loc2_));
         return _loc3_ == -1 ? param1.substring(_loc2_) : param1.substring(_loc2_,_loc3_);
      }
      
      public static function getServerName(param1:String) : String
      {
         var _loc2_:String = getServerNameWithPort(param1);
         var _loc3_:int = URLUtil.indexOfLeftSquareBracket(_loc2_);
         _loc3_ = _loc3_ > -1 ? int(_loc2_.indexOf(":",_loc3_)) : int(_loc2_.indexOf(":"));
         if(_loc3_ > 0)
         {
            _loc2_ = _loc2_.substring(0,_loc3_);
         }
         return _loc2_;
      }
      
      public static function getPort(param1:String) : uint
      {
         var _loc5_:Number = NaN;
         var _loc2_:String = getServerNameWithPort(param1);
         var _loc3_:int = URLUtil.indexOfLeftSquareBracket(_loc2_);
         _loc3_ = _loc3_ > -1 ? int(_loc2_.indexOf(":",_loc3_)) : int(_loc2_.indexOf(":"));
         var _loc4_:uint = 0;
         if(_loc3_ > 0)
         {
            _loc5_ = Number(_loc2_.substring(_loc3_ + 1));
            if(!isNaN(_loc5_))
            {
               _loc4_ = uint(int(_loc5_));
            }
         }
         return _loc4_;
      }
      
      public static function getFullURL(param1:String, param2:String) : String
      {
         var _loc3_:Number = NaN;
         if(param2 != null && !URLUtil.isHttpURL(param2))
         {
            if(param2.indexOf("./") == 0)
            {
               param2 = param2.substring(2);
            }
            if(URLUtil.isHttpURL(param1))
            {
               if(param2.charAt(0) == "/")
               {
                  _loc3_ = Number(param1.indexOf("/",8));
                  if(_loc3_ == -1)
                  {
                     _loc3_ = param1.length;
                  }
               }
               else
               {
                  _loc3_ = param1.lastIndexOf("/") + 1;
                  if(_loc3_ <= 8)
                  {
                     param1 += "/";
                     _loc3_ = param1.length;
                  }
               }
               if(_loc3_ > 0)
               {
                  param2 = param1.substring(0,_loc3_) + param2;
               }
            }
         }
         return param2;
      }
      
      public static function isHttpURL(param1:String) : Boolean
      {
         return param1 != null && (param1.indexOf("http://") == 0 || param1.indexOf("https://") == 0);
      }
      
      public static function isHttpsURL(param1:String) : Boolean
      {
         return param1 != null && param1.indexOf("https://") == 0;
      }
      
      public static function getProtocol(param1:String) : String
      {
         var _loc2_:int = int(param1.indexOf("/"));
         var _loc3_:int = int(param1.indexOf(":/"));
         if(_loc3_ > -1 && _loc3_ < _loc2_)
         {
            return param1.substring(0,_loc3_);
         }
         _loc3_ = int(param1.indexOf("::"));
         if(_loc3_ > -1 && _loc3_ < _loc2_)
         {
            return param1.substring(0,_loc3_);
         }
         return "";
      }
      
      public static function replaceProtocol(param1:String, param2:String) : String
      {
         return param1.replace(getProtocol(param1),param2);
      }
      
      public static function replacePort(param1:String, param2:uint) : String
      {
         var _loc6_:int = 0;
         var _loc3_:String = "";
         var _loc4_:int = int(param1.indexOf("]"));
         if(_loc4_ == -1)
         {
            _loc4_ = int(param1.indexOf(":"));
         }
         var _loc5_:int = int(param1.indexOf(":",_loc4_ + 1));
         if(_loc5_ > -1)
         {
            _loc5_++;
            _loc6_ = int(param1.indexOf("/",_loc5_));
            _loc3_ = param1.substring(0,_loc5_) + param2.toString() + param1.substring(_loc6_,param1.length);
         }
         else
         {
            _loc6_ = int(param1.indexOf("/",_loc4_));
            if(_loc6_ > -1)
            {
               if(param1.charAt(_loc6_ + 1) == "/")
               {
                  _loc6_ = int(param1.indexOf("/",_loc6_ + 2));
               }
               if(_loc6_ > 0)
               {
                  _loc3_ = param1.substring(0,_loc6_) + ":" + param2.toString() + param1.substring(_loc6_,param1.length);
               }
               else
               {
                  _loc3_ = param1 + ":" + param2.toString();
               }
            }
            else
            {
               _loc3_ = param1 + ":" + param2.toString();
            }
         }
         return _loc3_;
      }
      
      public static function replaceTokens(param1:String) : String
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc2_:String = LoaderConfig.url == null ? "" : LoaderConfig.url;
         if(param1.indexOf(SERVER_NAME_TOKEN) > 0)
         {
            _loc2_ = URLUtil.replaceEncodedSquareBrackets(_loc2_);
            _loc4_ = URLUtil.getProtocol(_loc2_);
            _loc5_ = "localhost";
            if(_loc4_.toLowerCase() != "file")
            {
               _loc5_ = URLUtil.getServerName(_loc2_);
            }
            param1 = param1.replace(SERVER_NAME_REGEX,_loc5_);
         }
         var _loc3_:int = int(param1.indexOf(SERVER_PORT_TOKEN));
         if(_loc3_ > 0)
         {
            _loc6_ = URLUtil.getPort(_loc2_);
            if(_loc6_ > 0)
            {
               param1 = param1.replace(SERVER_PORT_REGEX,_loc6_);
            }
            else
            {
               if(param1.charAt(_loc3_ - 1) == ":")
               {
                  param1 = param1.substring(0,_loc3_ - 1) + param1.substring(_loc3_);
               }
               param1 = param1.replace(SERVER_PORT_REGEX,"");
            }
         }
         return param1;
      }
      
      public static function urisEqual(param1:String, param2:String) : Boolean
      {
         if(param1 != null && param2 != null)
         {
            param1 = StringUtil.trim(param1).toLowerCase();
            param2 = StringUtil.trim(param2).toLowerCase();
            if(param1.charAt(param1.length - 1) != "/")
            {
               param1 += "/";
            }
            if(param2.charAt(param2.length - 1) != "/")
            {
               param2 += "/";
            }
         }
         return param1 == param2;
      }
      
      public static function hasTokens(param1:String) : Boolean
      {
         if(param1 == null || param1 == "")
         {
            return false;
         }
         if(param1.indexOf(SERVER_NAME_TOKEN) > 0)
         {
            return true;
         }
         if(param1.indexOf(SERVER_PORT_TOKEN) > 0)
         {
            return true;
         }
         return false;
      }
      
      public static function hasUnresolvableTokens() : Boolean
      {
         return LoaderConfig.url != null;
      }
      
      public static function objectToString(param1:Object, param2:String = ";", param3:Boolean = true) : String
      {
         return internalObjectToString(param1,param2,null,param3);
      }
      
      private static function indexOfLeftSquareBracket(param1:String) : int
      {
         var _loc2_:int = int(param1.indexOf(SQUARE_BRACKET_LEFT));
         if(_loc2_ == -1)
         {
            _loc2_ = int(param1.indexOf(SQUARE_BRACKET_LEFT_ENCODED));
         }
         return _loc2_;
      }
      
      private static function internalObjectToString(param1:Object, param2:String, param3:String, param4:Boolean) : String
      {
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc5_:String = "";
         var _loc6_:Boolean = true;
         for(_loc7_ in param1)
         {
            if(_loc6_)
            {
               _loc6_ = false;
            }
            else
            {
               _loc5_ += param2;
            }
            _loc8_ = param1[_loc7_];
            _loc9_ = param3 ? param3 + "." + _loc7_ : _loc7_;
            if(param4)
            {
               _loc9_ = encodeURIComponent(_loc9_);
            }
            if(_loc8_ is String)
            {
               _loc5_ += _loc9_ + "=" + (param4 ? encodeURIComponent(_loc8_ as String) : _loc8_);
            }
            else if(_loc8_ is Number)
            {
               _loc8_ = _loc8_.toString();
               if(param4)
               {
                  _loc8_ = encodeURIComponent(_loc8_ as String);
               }
               _loc5_ += _loc9_ + "=" + _loc8_;
            }
            else if(_loc8_ is Boolean)
            {
               _loc5_ += _loc9_ + "=" + (_loc8_ ? "true" : "false");
            }
            else if(_loc8_ is Array)
            {
               _loc5_ += internalArrayToString(_loc8_ as Array,param2,_loc9_,param4);
            }
            else
            {
               _loc5_ += internalObjectToString(_loc8_,param2,_loc9_,param4);
            }
         }
         return _loc5_;
      }
      
      private static function replaceEncodedSquareBrackets(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(param1.indexOf(SQUARE_BRACKET_RIGHT_ENCODED));
         if(_loc2_ > -1)
         {
            param1 = param1.replace(SQUARE_BRACKET_RIGHT_ENCODED,SQUARE_BRACKET_RIGHT);
            _loc3_ = int(param1.indexOf(SQUARE_BRACKET_LEFT_ENCODED));
            if(_loc3_ > -1)
            {
               param1 = param1.replace(SQUARE_BRACKET_LEFT_ENCODED,SQUARE_BRACKET_LEFT);
            }
         }
         return param1;
      }
      
      private static function internalArrayToString(param1:Array, param2:String, param3:String, param4:Boolean) : String
      {
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc5_:String = "";
         var _loc6_:Boolean = true;
         var _loc7_:int = int(param1.length);
         var _loc8_:int = 0;
         while(_loc8_ < _loc7_)
         {
            if(_loc6_)
            {
               _loc6_ = false;
            }
            else
            {
               _loc5_ += param2;
            }
            _loc9_ = param1[_loc8_];
            _loc10_ = param3 + "." + _loc8_;
            if(param4)
            {
               _loc10_ = encodeURIComponent(_loc10_);
            }
            if(_loc9_ is String)
            {
               _loc5_ += _loc10_ + "=" + (param4 ? encodeURIComponent(_loc9_ as String) : _loc9_);
            }
            else if(_loc9_ is Number)
            {
               _loc9_ = _loc9_.toString();
               if(param4)
               {
                  _loc9_ = encodeURIComponent(_loc9_ as String);
               }
               _loc5_ += _loc10_ + "=" + _loc9_;
            }
            else if(_loc9_ is Boolean)
            {
               _loc5_ += _loc10_ + "=" + (_loc9_ ? "true" : "false");
            }
            else if(_loc9_ is Array)
            {
               _loc5_ += internalArrayToString(_loc9_ as Array,param2,_loc10_,param4);
            }
            else
            {
               _loc5_ += internalObjectToString(_loc9_,param2,_loc10_,param4);
            }
            _loc8_++;
         }
         return _loc5_;
      }
      
      public static function stringToObject(param1:String, param2:String = ";", param3:Boolean = true) : Object
      {
         var _loc8_:Array = null;
         var _loc9_:String = null;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Object = null;
         var _loc15_:String = null;
         var _loc16_:String = null;
         var _loc17_:Object = null;
         var _loc4_:Object = {};
         var _loc5_:Array = param1.split(param2);
         var _loc6_:int = int(_loc5_.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = _loc5_[_loc7_].split("=");
            _loc9_ = _loc8_[0];
            if(param3)
            {
               _loc9_ = decodeURIComponent(_loc9_);
            }
            _loc10_ = _loc8_[1];
            if(param3)
            {
               _loc10_ = decodeURIComponent(_loc10_ as String);
            }
            if(_loc10_ == "true")
            {
               _loc10_ = true;
            }
            else if(_loc10_ == "false")
            {
               _loc10_ = false;
            }
            else
            {
               _loc14_ = int(_loc10_);
               if(_loc14_.toString() == _loc10_)
               {
                  _loc10_ = _loc14_;
               }
               else
               {
                  _loc14_ = Number(_loc10_);
                  if(_loc14_.toString() == _loc10_)
                  {
                     _loc10_ = _loc14_;
                  }
               }
            }
            _loc11_ = _loc4_;
            _loc8_ = _loc9_.split(".");
            _loc12_ = int(_loc8_.length);
            _loc13_ = 0;
            while(_loc13_ < _loc12_ - 1)
            {
               _loc15_ = _loc8_[_loc13_];
               if(_loc11_[_loc15_] == null && _loc13_ < _loc12_ - 1)
               {
                  _loc16_ = _loc8_[_loc13_ + 1];
                  _loc17_ = int(_loc16_);
                  if(_loc17_.toString() == _loc16_)
                  {
                     _loc11_[_loc15_] = [];
                  }
                  else
                  {
                     _loc11_[_loc15_] = {};
                  }
               }
               _loc11_ = _loc11_[_loc15_];
               _loc13_++;
            }
            _loc11_[_loc8_[_loc13_]] = _loc10_;
            _loc7_++;
         }
         return _loc4_;
      }
   }
}

