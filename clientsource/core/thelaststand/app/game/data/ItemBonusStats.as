package thelaststand.app.game.data
{
   import com.dynamicflash.util.Base64;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   
   public class ItemBonusStats
   {
      
      internal var _rawData:Object;
      
      protected var _survivorModTable:Dictionary;
      
      protected var _weaponModTable:Dictionary;
      
      protected var _gearModTable:Dictionary;
      
      public function ItemBonusStats()
      {
         super();
      }
      
      public function get survivorModTable() : Dictionary
      {
         return this._survivorModTable;
      }
      
      public function get weaponModTable() : Dictionary
      {
         return this._weaponModTable;
      }
      
      public function get gearModTable() : Dictionary
      {
         return this._gearModTable;
      }
      
      public function clone() : ItemBonusStats
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeObject(this._rawData);
         _loc1_.position = 0;
         var _loc2_:ItemBonusStats = new ItemBonusStats();
         _loc2_._rawData = _loc1_.readObject();
         _loc2_._survivorModTable = this.cloneModTable(this._survivorModTable);
         _loc2_._weaponModTable = this.cloneModTable(this._weaponModTable);
         _loc2_._gearModTable = this.cloneModTable(this._gearModTable);
         return _loc2_;
      }
      
      public function getModTable(param1:String) : Dictionary
      {
         switch(param1)
         {
            case ItemAttributes.GROUP_SURVIVOR:
               return this._survivorModTable;
            case ItemAttributes.GROUP_WEAPON:
               return this._weaponModTable;
            case ItemAttributes.GROUP_GEAR:
               return this._gearModTable;
            default:
               return null;
         }
      }
      
      internal function read(param1:Object) : void
      {
         this._rawData = param1;
         this._survivorModTable = new Dictionary();
         if(param1.stat_srv != null)
         {
            this.readModTable(param1.stat_srv,this._survivorModTable);
            if(this._rawData.stat_srv is ByteArray)
            {
               this._rawData.stat_srv = Base64.encodeByteArray(this._rawData.stat_srv);
            }
         }
         this._weaponModTable = new Dictionary();
         if(param1.stat_weap != null)
         {
            this.readModTable(param1.stat_weap,this._weaponModTable);
            if(this._rawData.stat_weap is ByteArray)
            {
               this._rawData.stat_weap = Base64.encodeByteArray(this._rawData.stat_weap);
            }
         }
         this._gearModTable = new Dictionary();
         if(param1.stat_gear != null)
         {
            this.readModTable(param1.stat_gear,this._gearModTable);
            if(this._rawData.stat_gear is ByteArray)
            {
               this._rawData.stat_gear = Base64.encodeByteArray(this._rawData.stat_gear);
            }
         }
      }
      
      internal function cloneModTable(param1:Dictionary) : Dictionary
      {
         var _loc3_:* = undefined;
         var _loc2_:Dictionary = new Dictionary();
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      private function readModTable(param1:Object, param2:Dictionary) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:ByteArray = null;
         var _loc6_:ByteArray = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1 is String)
         {
            _loc5_ = Base64.decodeToByteArray(String(param1));
            this.readModTable(_loc5_,param2);
            return;
         }
         if(param1 is ByteArray)
         {
            _loc6_ = ByteArray(param1);
            _loc6_.endian = Endian.LITTLE_ENDIAN;
            _loc6_.position = 0;
            _loc7_ = _loc6_.readShort();
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               _loc3_ = _loc6_.readUTF();
               _loc4_ = _loc6_.readFloat();
               if(!(_loc3_ == "att" || _loc3_ == "key"))
               {
                  param2[_loc3_] = _loc4_;
               }
               _loc8_++;
            }
            return;
         }
         for(_loc3_ in param1)
         {
            if(!(_loc3_ == "att" || _loc3_ == "key"))
            {
               _loc4_ = Number(param1[_loc3_]);
               param2[_loc3_] = _loc4_;
            }
         }
      }
   }
}

