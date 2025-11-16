package alternativa.engine3d.materials.compiler
{
   import flash.utils.ByteArray;
   
   public class SamplerVariable extends Variable
   {
      
      public function SamplerVariable(param1:String)
      {
         var _loc4_:Array = null;
         var _loc7_:String = null;
         super();
         var _loc2_:String = String(param1.match(/[si]/g)[0]);
         switch(_loc2_)
         {
            case "s":
               upperCode = VariableType.SAMPLER;
               break;
            case "i":
               upperCode = VariableType.INPUT;
         }
         index = parseInt(param1.match(/\d+/g)[0],10);
         lowerCode = index;
         var _loc3_:int = int(param1.search(/<.*>/g));
         if(_loc3_ != -1)
         {
            _loc4_ = param1.substring(_loc3_).match(/(\w+)/g);
         }
         type = upperCode;
         var _loc5_:uint = _loc4_.length;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            switch(_loc7_)
            {
               case "2d":
                  upperCode &= ~0xF000;
                  break;
               case "3d":
                  upperCode &= ~0xF000;
                  upperCode |= 8192;
                  break;
               case "cube":
                  upperCode &= ~0xF000;
                  upperCode |= 4096;
                  break;
               case "mipnearest":
                  upperCode &= ~0x0F000000;
                  upperCode |= 16777216;
                  break;
               case "miplinear":
                  upperCode &= ~0x0F000000;
                  upperCode |= 33554432;
                  break;
               case "mipnone":
               case "nomip":
                  upperCode &= ~0x0F000000;
                  break;
               case "nearest":
                  upperCode &= ~4026531840;
                  break;
               case "linear":
                  upperCode &= ~4026531840;
                  upperCode |= 268435456;
                  break;
               case "centroid":
                  upperCode |= 4294967296;
                  break;
               case "single":
                  upperCode |= 8589934592;
                  break;
               case "depth":
                  upperCode |= 17179869184;
                  break;
               case "repeat":
               case "wrap":
                  upperCode &= ~0xF00000;
                  upperCode |= 1048576;
                  break;
               case "clamp":
                  upperCode &= ~0xF00000;
            }
            _loc6_++;
         }
      }
      
      override public function writeToByteArray(param1:ByteArray, param2:int, param3:int, param4:int = 0) : void
      {
         super.writeToByteArray(param1,param2,param3,param4);
      }
   }
}

