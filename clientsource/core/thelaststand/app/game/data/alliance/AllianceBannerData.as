package thelaststand.app.game.data.alliance
{
   import flash.utils.ByteArray;
   import org.osflash.signals.Signal;
   
   public class AllianceBannerData
   {
      
      public static const BASE_COLOR:int = 0;
      
      public static const DECAL_1:int = 1;
      
      public static const DECAL_1_COLOR:int = 2;
      
      public static const DECAL_2:int = 3;
      
      public static const DECAL_2_COLOR:int = 4;
      
      public static const DECAL_3:int = 5;
      
      public static const DECAL_3_COLOR:int = 6;
      
      private var _data:Vector.<int> = Vector.<int>([1,1,1,1,1,1,1]);
      
      public var onChange:Signal;
      
      public function AllianceBannerData()
      {
         super();
         this.onChange = new Signal();
      }
      
      public function dump() : void
      {
      }
      
      public function dispose() : void
      {
         this.onChange.removeAll();
         this.onChange = null;
         this._data = null;
      }
      
      public function setProp(param1:int, param2:uint, param3:Boolean = true) : void
      {
         if(param1 < 0 || param1 >= this._data.length)
         {
            return;
         }
         if(this._data[param1] != param2)
         {
            this._data[param1] = param2;
            if(param3)
            {
               this.onChange.dispatch();
            }
         }
      }
      
      public function getProp(param1:int) : uint
      {
         if(param1 < 0 || param1 >= this._data.length)
         {
            return 0;
         }
         return this._data[param1];
      }
      
      public function get byteArray() : ByteArray
      {
         var _loc2_:int = 0;
         var _loc1_:ByteArray = new ByteArray();
         for each(_loc2_ in this._data)
         {
            _loc1_.writeByte(_loc2_);
         }
         return _loc1_;
      }
      
      public function set byteArray(param1:ByteArray) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = 0;
         param1.position = 0;
         while(_loc2_ < param1.length)
         {
            this._data[_loc2_] = param1.readByte();
            _loc2_++;
         }
         while(_loc2_ < this._data.length)
         {
            this._data[_loc2_++] = 0;
         }
         this.onChange.dispatch();
      }
      
      public function get hexString() : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc1_:String = "";
         for each(_loc2_ in this._data)
         {
            _loc3_ = _loc2_.toString(16);
            if(_loc3_.length < 2)
            {
               _loc3_ = "0" + _loc3_;
            }
            _loc1_ = _loc3_ + _loc1_;
         }
         return "0x" + _loc1_;
      }
      
      public function set hexString(param1:String) : void
      {
         param1 = param1.replace("0x","");
         var _loc2_:int = 0;
         var _loc3_:int = param1.length - 2;
         while(_loc3_ >= 0)
         {
            var _loc4_:*;
            this._data[_loc4_ = _loc2_++] = parseInt(param1.substr(_loc3_,2),16);
            _loc3_ -= 2;
         }
         while(_loc2_ < this._data.length)
         {
            this._data[_loc4_ = _loc2_++] = 0;
         }
         this.onChange.dispatch();
      }
   }
}

