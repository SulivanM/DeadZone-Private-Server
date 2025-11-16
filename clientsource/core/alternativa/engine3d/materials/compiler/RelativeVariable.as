package alternativa.engine3d.materials.compiler
{
   import flash.utils.ByteArray;
   
   public class RelativeVariable extends Variable
   {
      
      public function RelativeVariable(param1:String)
      {
         super();
         var _loc2_:Array = param1.match(/[A-Za-z]/g);
         index = parseInt(param1.match(/\d+/g)[0],10);
         switch(_loc2_[0])
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
            case "i":
               type = VariableType.INPUT;
         }
         var _loc3_:Array = param1.match(/(\.[xyzw]{1,1})/);
         if(_loc3_.length == 0)
         {
            throw new Error("error: bad index register select");
         }
         var _loc4_:int = _loc3_[0].charCodeAt(1) - X_CHAR_CODE;
         if(_loc4_ == -1)
         {
            _loc4_ = 3;
         }
         var _loc5_:Array = param1.match(/\+\d{1,3}/g);
         var _loc6_:int = 0;
         if(_loc5_.length > 0)
         {
            _loc6_ = parseInt(_loc5_[0],10);
         }
         if(_loc6_ < 0 || _loc6_ > 255)
         {
            throw new Error("Error: index offset " + _loc6_ + " out of bounds. [0..255]");
         }
         lowerCode = _loc6_ << 16 | index;
         upperCode |= type << 8;
         upperCode |= _loc4_ << 16;
         upperCode |= 1 << 31;
      }
      
      override public function writeToByteArray(param1:ByteArray, param2:int, param3:int, param4:int = 0) : void
      {
         param1.position = position + param4;
         param1.writeShort(param2);
         param1.position = position + param4 + 5;
         param1.writeByte(param3);
      }
   }
}

