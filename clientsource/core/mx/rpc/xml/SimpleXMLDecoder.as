package mx.rpc.xml
{
   import flash.xml.XMLNode;
   import flash.xml.XMLNodeType;
   import mx.collections.ArrayCollection;
   import mx.utils.ObjectProxy;
   
   public class SimpleXMLDecoder
   {
      
      private var makeObjectsBindable:Boolean;
      
      public function SimpleXMLDecoder(param1:Boolean = false)
      {
         super();
         this.makeObjectsBindable = param1;
      }
      
      public static function simpleType(param1:Object) : Object
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:Object = param1;
         if(param1 != null)
         {
            if(param1 is String && String(param1) == "")
            {
               _loc2_ = param1.toString();
            }
            else if(isNaN(Number(param1)) || param1.charAt(0) == "0" || param1.charAt(0) == "-" && param1.charAt(1) == "0" || param1.charAt(param1.length - 1) == "E")
            {
               _loc3_ = param1.toString();
               _loc4_ = _loc3_.toLowerCase();
               if(_loc4_ == "true")
               {
                  _loc2_ = true;
               }
               else if(_loc4_ == "false")
               {
                  _loc2_ = false;
               }
               else
               {
                  _loc2_ = _loc3_;
               }
            }
            else
            {
               _loc2_ = Number(param1);
            }
         }
         return _loc2_;
      }
      
      public static function getLocalName(param1:XMLNode) : String
      {
         var _loc2_:String = param1.nodeName;
         var _loc3_:int = int(_loc2_.indexOf(":"));
         if(_loc3_ != -1)
         {
            _loc2_ = _loc2_.substring(_loc3_ + 1);
         }
         return _loc2_;
      }
      
      public function decodeXML(param1:XMLNode) : Object
      {
         var _loc2_:Object = null;
         var _loc6_:String = null;
         var _loc7_:uint = 0;
         var _loc8_:XMLNode = null;
         var _loc9_:String = null;
         var _loc10_:Object = null;
         var _loc11_:Object = null;
         var _loc3_:Boolean = false;
         if(param1 == null)
         {
            return null;
         }
         var _loc4_:Array = param1.childNodes;
         if(_loc4_.length == 1 && _loc4_[0].nodeType == XMLNodeType.TEXT_NODE)
         {
            _loc3_ = true;
            _loc2_ = SimpleXMLDecoder.simpleType(_loc4_[0].nodeValue);
         }
         else if(_loc4_.length > 0)
         {
            _loc2_ = {};
            if(this.makeObjectsBindable)
            {
               _loc2_ = new ObjectProxy(_loc2_);
            }
            _loc7_ = 0;
            while(_loc7_ < _loc4_.length)
            {
               _loc8_ = _loc4_[_loc7_];
               if(_loc8_.nodeType == XMLNodeType.ELEMENT_NODE)
               {
                  _loc9_ = getLocalName(_loc8_);
                  _loc10_ = this.decodeXML(_loc8_);
                  _loc11_ = _loc2_[_loc9_];
                  if(_loc11_ != null)
                  {
                     if(_loc11_ is Array)
                     {
                        _loc11_.push(_loc10_);
                     }
                     else if(_loc11_ is ArrayCollection)
                     {
                        _loc11_.source.push(_loc10_);
                     }
                     else
                     {
                        _loc11_ = [_loc11_];
                        _loc11_.push(_loc10_);
                        if(this.makeObjectsBindable)
                        {
                           _loc11_ = new ArrayCollection(_loc11_ as Array);
                        }
                        _loc2_[_loc9_] = _loc11_;
                     }
                  }
                  else
                  {
                     _loc2_[_loc9_] = _loc10_;
                  }
               }
               _loc7_++;
            }
         }
         var _loc5_:Object = param1.attributes;
         for(_loc6_ in _loc5_)
         {
            if(!(_loc6_ == "xmlns" || _loc6_.indexOf("xmlns:") != -1))
            {
               if(_loc2_ == null)
               {
                  _loc2_ = {};
                  if(this.makeObjectsBindable)
                  {
                     _loc2_ = new ObjectProxy(_loc2_);
                  }
               }
               if(_loc3_ && !(_loc2_ is ComplexString))
               {
                  _loc2_ = new ComplexString(_loc2_.toString());
                  _loc3_ = false;
               }
               _loc2_[_loc6_] = SimpleXMLDecoder.simpleType(_loc5_[_loc6_]);
            }
         }
         return _loc2_;
      }
   }
}

