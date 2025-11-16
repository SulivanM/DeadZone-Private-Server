package thelaststand.app.game.data
{
   import flash.utils.ByteArray;
   
   public class CraftingInfo extends ItemBonusStats
   {
      
      protected var _userName:String;
      
      protected var _userId:String;
      
      protected var _date:Date;
      
      public function CraftingInfo()
      {
         super();
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function get date() : Date
      {
         return this._date;
      }
      
      override public function clone() : ItemBonusStats
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeObject(_rawData);
         _loc1_.position = 0;
         var _loc2_:CraftingInfo = new CraftingInfo();
         _loc2_._rawData = _loc1_.readObject();
         _loc2_._survivorModTable = cloneModTable(_survivorModTable);
         _loc2_._weaponModTable = cloneModTable(_weaponModTable);
         _loc2_._userName = this._userName;
         _loc2_._userId = this._userId;
         _loc2_._date = new Date(this._date.time);
         return _loc2_;
      }
      
      override internal function read(param1:Object) : void
      {
         super.read(param1);
         this._userId = param1.user_id;
         this._userName = param1.user_name;
         this._date = param1.date is Date ? param1.date as Date : new Date(param1.date);
      }
   }
}

