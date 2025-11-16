package alternativa.engine3d.materials.compiler
{
   import flash.utils.ByteArray;
   
   public class SourceVariable extends Variable
   {
      
      public var relative:RelativeVariable;
      
      public function SourceVariable(param1:String)
      {
         var _loc3_:uint = 0;
         var _loc5_:* = false;
         var _loc8_:int = 0;
         var _loc9_:uint = 0;
         var _loc10_:int = 0;
         super();
         var _loc2_:String = String(param1.match(/[catsoiv]/g)[0]);
         var _loc4_:Array = param1.match(/\[.*\]/g);
         _loc5_ = _loc4_.length > 0;
         if(_loc5_)
         {
            param1 = param1.replace(_loc4_[0],"0");
         }
         else
         {
            index = parseInt(param1.match(/\d+/g)[0],10);
         }
         var _loc6_:Array = param1.match(/\.[xyzw]{1,4}/);
         var _loc7_:String = _loc6_ ? _loc6_[0] : null;
         if(_loc7_)
         {
            _loc3_ = 0;
            _loc9_ = uint(_loc7_.length);
            _loc10_ = 1;
            while(_loc10_ < _loc9_)
            {
               _loc8_ = _loc7_.charCodeAt(_loc10_) - X_CHAR_CODE;
               if(_loc8_ == -1)
               {
                  _loc8_ = 3;
               }
               _loc3_ |= _loc8_ << (_loc10_ - 1 << 1);
               _loc10_++;
            }
            while(_loc10_ <= 4)
            {
               _loc3_ |= _loc8_ << (_loc10_ - 1 << 1);
               _loc10_++;
            }
         }
         else
         {
            _loc3_ = 228;
         }
         lowerCode = _loc3_ << 24 | index;
         switch(_loc2_)
         {
            case "a":
               type = VariableType.ATTRIBUTE;
               break;
            case "c":
               type = VariableType.CONSTANT;
               break;
            case "t":
               type = VariableType.TEMPORARY;
               break;
            case "o":
               type = VariableType.OUTPUT;
               break;
            case "v":
               type = VariableType.VARYING;
               break;
            case "i":
               type = VariableType.INPUT;
               break;
            default:
               throw new ArgumentError("Wrong source register type, must be \"a\" or \"c\" or \"t\" or \"o\" or \"v\" or \"i\", var = " + param1);
         }
         upperCode = type;
         if(_loc5_)
         {
            this.relative = new RelativeVariable(_loc4_[0]);
            lowerCode |= this.relative.lowerCode;
            upperCode |= this.relative.upperCode;
            isRelative = true;
         }
      }
      
      override public function get size() : uint
      {
         if(this.relative)
         {
            return 0;
         }
         return super.size;
      }
      
      override public function writeToByteArray(param1:ByteArray, param2:int, param3:int, param4:int = 0) : void
      {
         if(this.relative == null)
         {
            super.writeToByteArray(param1,param2,param3,param4);
         }
         else
         {
            param1.position = position + 2;
         }
         param1.position = position + param4 + 4;
         param1.writeByte(param3);
      }
   }
}

