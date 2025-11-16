package alternativa.engine3d.materials.compiler
{
   import flash.utils.ByteArray;
   
   public class DestinationVariable extends Variable
   {
      
      public function DestinationVariable(param1:String)
      {
         var _loc4_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         super();
         var _loc2_:String = param1.match(/[tovid]/)[0];
         index = parseInt(param1.match(/\d+/)[0],10);
         var _loc3_:Array = param1.match(/\.[xyzw]{1,4}/);
         var _loc5_:String = _loc3_ ? _loc3_[0] : null;
         if(_loc5_ != null)
         {
            _loc4_ = 0;
            _loc7_ = uint(_loc5_.length);
            _loc8_ = 1;
            while(_loc8_ < _loc7_)
            {
               _loc6_ = _loc5_.charCodeAt(_loc8_) - X_CHAR_CODE;
               if(_loc6_ == -1)
               {
                  _loc6_ = 3;
               }
               _loc4_ |= 1 << _loc6_;
               _loc8_++;
            }
         }
         else
         {
            _loc4_ = 15;
         }
         lowerCode = _loc4_ << 16 | index;
         switch(_loc2_)
         {
            case "t":
               lowerCode |= 33554432;
               type = VariableType.TEMPORARY;
               break;
            case "o":
               lowerCode |= 50331648;
               type = VariableType.OUTPUT;
               break;
            case "v":
               lowerCode |= 67108864;
               type = VariableType.VARYING;
               break;
            case "d":
               lowerCode |= 100663296;
               type = VariableType.DEPTH;
               break;
            case "i":
               lowerCode |= 117440512;
               type = VariableType.INPUT;
               break;
            default:
               throw new ArgumentError("Wrong destination register type, must be \"t\" or \"o\" or \"v\" or \"d\", var = " + param1);
         }
      }
      
      override public function writeToByteArray(param1:ByteArray, param2:int, param3:int, param4:int = 0) : void
      {
         param1.position = position + param4;
         param1.writeUnsignedInt(lowerCode & ~0x0F00FFFF | param2 | param3 << 24);
      }
   }
}

