package mx.rpc.xml
{
   import flash.xml.XMLDocument;
   import flash.xml.XMLNode;
   import mx.utils.ObjectUtil;
   
   public class SimpleXMLEncoder
   {
      
      private static const NUMBER_TYPE:uint = 0;
      
      private static const STRING_TYPE:uint = 1;
      
      private static const OBJECT_TYPE:uint = 2;
      
      private static const DATE_TYPE:uint = 3;
      
      private static const BOOLEAN_TYPE:uint = 4;
      
      private static const XML_TYPE:uint = 5;
      
      private static const ARRAY_TYPE:uint = 6;
      
      private static const MAP_TYPE:uint = 7;
      
      private static const ANY_TYPE:uint = 8;
      
      private static const ROWSET_TYPE:uint = 11;
      
      private static const QBEAN_TYPE:uint = 12;
      
      private static const DOC_TYPE:uint = 13;
      
      private static const SCHEMA_TYPE:uint = 14;
      
      private static const FUNCTION_TYPE:uint = 15;
      
      private static const ELEMENT_TYPE:uint = 16;
      
      private static const BASE64_BINARY_TYPE:uint = 17;
      
      private static const HEX_BINARY_TYPE:uint = 18;
      
      private static const CLASS_INFO_OPTIONS:Object = {
         "includeReadOnly":false,
         "includeTransient":false
      };
      
      private var myXMLDoc:XMLDocument;
      
      public function SimpleXMLEncoder(param1:XMLDocument)
      {
         super();
         this.myXMLDoc = param1 ? param1 : new XMLDocument();
      }
      
      internal static function encodeDate(param1:Date, param2:String) : String
      {
         var _loc4_:Number = NaN;
         var _loc3_:String = new String();
         if(param2 == "dateTime" || param2 == "date")
         {
            _loc3_ = _loc3_.concat(param1.getUTCFullYear(),"-");
            _loc4_ = param1.getUTCMonth() + 1;
            if(_loc4_ < 10)
            {
               _loc3_ = _loc3_.concat("0");
            }
            _loc3_ = _loc3_.concat(_loc4_,"-");
            _loc4_ = Number(param1.getUTCDate());
            if(_loc4_ < 10)
            {
               _loc3_ = _loc3_.concat("0");
            }
            _loc3_ = _loc3_.concat(_loc4_);
         }
         if(param2 == "dateTime")
         {
            _loc3_ = _loc3_.concat("T");
         }
         if(param2 == "dateTime" || param2 == "time")
         {
            _loc4_ = Number(param1.getUTCHours());
            if(_loc4_ < 10)
            {
               _loc3_ = _loc3_.concat("0");
            }
            _loc3_ = _loc3_.concat(_loc4_,":");
            _loc4_ = Number(param1.getUTCMinutes());
            if(_loc4_ < 10)
            {
               _loc3_ = _loc3_.concat("0");
            }
            _loc3_ = _loc3_.concat(_loc4_,":");
            _loc4_ = Number(param1.getUTCSeconds());
            if(_loc4_ < 10)
            {
               _loc3_ = _loc3_.concat("0");
            }
            _loc3_ = _loc3_.concat(_loc4_,".");
            _loc4_ = Number(param1.getUTCMilliseconds());
            if(_loc4_ < 10)
            {
               _loc3_ = _loc3_.concat("00");
            }
            else if(_loc4_ < 100)
            {
               _loc3_ = _loc3_.concat("0");
            }
            _loc3_ = _loc3_.concat(_loc4_);
         }
         return _loc3_.concat("Z");
      }
      
      public function encodeValue(param1:Object, param2:QName, param3:XMLNode) : XMLNode
      {
         var _loc4_:XMLNode = null;
         var _loc6_:Object = null;
         var _loc7_:Array = null;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:String = null;
         var _loc11_:QName = null;
         var _loc12_:uint = 0;
         var _loc13_:QName = null;
         var _loc14_:uint = 0;
         var _loc15_:String = null;
         var _loc16_:XMLNode = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         if(param1 == null)
         {
            return null;
         }
         var _loc5_:uint = this.getDataTypeFromObject(param1);
         if(_loc5_ == SimpleXMLEncoder.FUNCTION_TYPE)
         {
            return null;
         }
         if(_loc5_ == SimpleXMLEncoder.XML_TYPE)
         {
            _loc4_ = param1.cloneNode(true);
            param3.appendChild(_loc4_);
            return _loc4_;
         }
         _loc4_ = this.myXMLDoc.createElement("foo");
         _loc4_.nodeName = param2.localName;
         param3.appendChild(_loc4_);
         if(_loc5_ == SimpleXMLEncoder.OBJECT_TYPE)
         {
            _loc6_ = ObjectUtil.getClassInfo(param1,null,CLASS_INFO_OPTIONS);
            _loc7_ = _loc6_.properties;
            _loc8_ = _loc7_.length;
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc10_ = _loc7_[_loc9_];
               _loc11_ = new QName("",_loc10_);
               this.encodeValue(param1[_loc10_],_loc11_,_loc4_);
               _loc9_++;
            }
         }
         else if(_loc5_ == SimpleXMLEncoder.ARRAY_TYPE)
         {
            _loc12_ = uint(param1.length);
            _loc13_ = new QName("","item");
            _loc14_ = 0;
            while(_loc14_ < _loc12_)
            {
               this.encodeValue(param1[_loc14_],_loc13_,_loc4_);
               _loc14_++;
            }
         }
         else
         {
            if(_loc5_ == SimpleXMLEncoder.DATE_TYPE)
            {
               _loc15_ = encodeDate(param1 as Date,"dateTime");
            }
            else if(_loc5_ == SimpleXMLEncoder.NUMBER_TYPE)
            {
               if(param1 == Number.POSITIVE_INFINITY)
               {
                  _loc15_ = "INF";
               }
               else if(param1 == Number.NEGATIVE_INFINITY)
               {
                  _loc15_ = "-INF";
               }
               else
               {
                  _loc17_ = param1.toString();
                  _loc18_ = _loc17_.substr(0,2);
                  if(_loc18_ == "0X" || _loc18_ == "0x")
                  {
                     _loc15_ = parseInt(_loc17_).toString();
                  }
                  else
                  {
                     _loc15_ = _loc17_;
                  }
               }
            }
            else
            {
               _loc15_ = param1.toString();
            }
            _loc16_ = this.myXMLDoc.createTextNode(_loc15_);
            _loc4_.appendChild(_loc16_);
         }
         return _loc4_;
      }
      
      private function getDataTypeFromObject(param1:Object) : uint
      {
         if(param1 is Number)
         {
            return SimpleXMLEncoder.NUMBER_TYPE;
         }
         if(param1 is Boolean)
         {
            return SimpleXMLEncoder.BOOLEAN_TYPE;
         }
         if(param1 is String)
         {
            return SimpleXMLEncoder.STRING_TYPE;
         }
         if(param1 is XMLDocument)
         {
            return SimpleXMLEncoder.XML_TYPE;
         }
         if(param1 is Date)
         {
            return SimpleXMLEncoder.DATE_TYPE;
         }
         if(param1 is Array)
         {
            return SimpleXMLEncoder.ARRAY_TYPE;
         }
         if(param1 is Function)
         {
            return SimpleXMLEncoder.FUNCTION_TYPE;
         }
         if(param1 is Object)
         {
            return SimpleXMLEncoder.OBJECT_TYPE;
         }
         return SimpleXMLEncoder.STRING_TYPE;
      }
   }
}

