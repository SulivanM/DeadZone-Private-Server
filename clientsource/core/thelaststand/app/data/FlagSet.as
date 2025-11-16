package thelaststand.app.data
{
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import org.osflash.signals.Signal;
   import thelaststand.app.utils.BinaryUtils;
   
   public class FlagSet
   {
      
      private var _flags:Vector.<Boolean>;
      
      private var _length:int = 0;
      
      public var changed:Signal = new Signal(uint,Boolean);
      
      public function FlagSet(param1:Class)
      {
         this._flags = new Vector.<Boolean>(this._length);
         super();
         this._length = describeType(param1).constant.length();
      }
      
      public function get(param1:uint) : Boolean
      {
         return this._flags[param1];
      }
      
      public function set(param1:uint, param2:Boolean, param3:Boolean = false) : void
      {
         var _loc4_:Boolean = this._flags[param1];
         if(param2 == _loc4_)
         {
            return;
         }
         this._flags[param1] = param2;
         if(!param3)
         {
            this.changed.dispatch(param1,param2);
         }
      }
      
      public function deserialize(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         if(param1 != null)
         {
            this._flags = BinaryUtils.booleanArrayFromByteArray(param1);
         }
         else
         {
            this._flags = new Vector.<Boolean>(this._length);
         }
         if(this._flags.length < this._length)
         {
            this._flags.length = this._length;
            _loc2_ = int(this._flags.length);
            while(_loc2_ < this._length)
            {
               this._flags[_loc2_] = false;
               _loc2_++;
            }
         }
      }
   }
}

