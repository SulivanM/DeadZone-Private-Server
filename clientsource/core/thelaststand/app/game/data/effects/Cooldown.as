package thelaststand.app.game.data.effects
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.common.io.ISerializable;
   
   public class Cooldown implements ISerializable
   {
      
      private var _id:String;
      
      private var _type:uint;
      
      private var _subType:String;
      
      private var _timer:TimerData;
      
      public var completed:Signal;
      
      public function Cooldown()
      {
         super();
         this.completed = new Signal(Cooldown);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get type() : uint
      {
         return this._type;
      }
      
      public function get subType() : String
      {
         return this._subType;
      }
      
      public function get timer() : TimerData
      {
         return this._timer;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         if(this._timer != null)
         {
            this._timer.dispose();
         }
         var _loc2_:ByteArray = ByteArray(param1);
         _loc2_.endian = Endian.LITTLE_ENDIAN;
         _loc2_.position = 0;
         this._type = _loc2_.readUnsignedShort();
         this._id = _loc2_.readUTF();
         var _loc3_:Date = new Date(_loc2_.readDouble());
         this._timer = new TimerData(_loc3_,_loc2_.readUnsignedInt(),this);
         if(!this._timer.hasEnded())
         {
            this._timer.data.type = "cooldown";
            this._timer.completed.addOnce(this.onCompleted);
            TimerManager.getInstance().addTimer(this._timer);
         }
         else
         {
            this._timer.dispose();
         }
         if(_loc2_.bytesAvailable == 0)
         {
            return;
         }
         this._subType = _loc2_.readUnsignedByte() != 0 ? _loc2_.readUTF() : null;
      }
      
      private function onCompleted(param1:TimerData) : void
      {
         this.completed.dispatch(this);
      }
   }
}

