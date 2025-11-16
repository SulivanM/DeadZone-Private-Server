package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeSource extends DaeElement
   {
      
      private const FLOAT_ARRAY:String = "float_array";
      
      private const INT_ARRAY:String = "int_array";
      
      private const NAME_ARRAY:String = "Name_array";
      
      public var numbers:Vector.<Number>;
      
      public var ints:Vector.<int>;
      
      public var names:Vector.<String>;
      
      public var stride:int;
      
      public function DaeSource(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
         this.constructArrays();
      }
      
      private function constructArrays() : void
      {
         var _loc4_:XML = null;
         var _loc5_:DaeArray = null;
         var _loc1_:XMLList = data.children();
         var _loc2_:int = 0;
         var _loc3_:int = int(_loc1_.length());
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc1_[_loc2_];
            switch(_loc4_.localName())
            {
               case this.FLOAT_ARRAY:
               case this.INT_ARRAY:
               case this.NAME_ARRAY:
                  _loc5_ = new DaeArray(_loc4_,document);
                  if(_loc5_.id != null)
                  {
                     document.arrays[_loc5_.id] = _loc5_;
                  }
            }
            _loc2_++;
         }
      }
      
      private function get accessor() : XML
      {
         return data.technique_common.accessor[0];
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc2_:XML = null;
         var _loc3_:DaeArray = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc1_:XML = this.accessor;
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_.@source[0];
            _loc3_ = _loc2_ == null ? null : document.findArray(_loc2_);
            if(_loc3_ != null)
            {
               _loc4_ = _loc1_.@count[0];
               if(_loc4_ != null)
               {
                  _loc5_ = parseInt(_loc4_.toString(),10);
                  _loc6_ = _loc1_.@offset[0];
                  _loc7_ = _loc1_.@stride[0];
                  _loc8_ = _loc6_ == null ? 0 : int(parseInt(_loc6_.toString(),10));
                  _loc9_ = _loc7_ == null ? 1 : int(parseInt(_loc7_.toString(),10));
                  _loc3_.parse();
                  if(_loc3_.array.length < _loc8_ + _loc5_ * _loc9_)
                  {
                     document.logger.logNotEnoughDataError(_loc1_);
                     return false;
                  }
                  this.stride = this.parseArray(_loc8_,_loc5_,_loc9_,_loc3_.array,_loc3_.type);
                  return true;
               }
            }
            else
            {
               document.logger.logNotFoundError(_loc2_);
            }
         }
         return false;
      }
      
      private function numValidParams(param1:XMLList) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length());
         while(_loc3_ < _loc4_)
         {
            if(param1[_loc3_].@name[0] != null)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function parseArray(param1:int, param2:int, param3:int, param4:Array, param5:String) : int
      {
         var _loc10_:XML = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc6_:XMLList = this.accessor.param;
         var _loc7_:int = Math.max(this.numValidParams(_loc6_),param3);
         switch(param5)
         {
            case this.FLOAT_ARRAY:
               this.numbers = new Vector.<Number>(int(_loc7_ * param2));
               break;
            case this.INT_ARRAY:
               this.ints = new Vector.<int>(int(_loc7_ * param2));
               break;
            case this.NAME_ARRAY:
               this.names = new Vector.<String>(int(_loc7_ * param2));
         }
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         while(_loc9_ < _loc7_)
         {
            _loc10_ = _loc6_[_loc9_];
            if(_loc10_ == null || Boolean(_loc10_.hasOwnProperty("@name")))
            {
               switch(param5)
               {
                  case this.FLOAT_ARRAY:
                     _loc11_ = 0;
                     while(_loc11_ < param2)
                     {
                        _loc12_ = param4[int(param1 + param3 * _loc11_ + _loc9_)];
                        if(_loc12_.indexOf(",") != -1)
                        {
                           _loc12_ = _loc12_.replace(/,/,".");
                        }
                        this.numbers[int(_loc7_ * _loc11_ + _loc8_)] = parseFloat(_loc12_);
                        _loc11_++;
                     }
                     break;
                  case this.INT_ARRAY:
                     _loc11_ = 0;
                     while(_loc11_ < param2)
                     {
                        this.ints[int(_loc7_ * _loc11_ + _loc8_)] = parseInt(param4[int(param1 + param3 * _loc11_ + _loc9_)],10);
                        _loc11_++;
                     }
                     break;
                  case this.NAME_ARRAY:
                     _loc11_ = 0;
                     while(_loc11_ < param2)
                     {
                        this.names[int(_loc7_ * _loc11_ + _loc8_)] = param4[int(param1 + param3 * _loc11_ + _loc9_)];
                        _loc11_++;
                     }
               }
               _loc8_++;
            }
            _loc9_++;
         }
         return _loc7_;
      }
   }
}

