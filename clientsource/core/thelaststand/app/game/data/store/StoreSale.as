package thelaststand.app.game.data.store
{
   import playerio.DatabaseObject;
   import thelaststand.app.network.Network;
   
   public class StoreSale
   {
      
      private var _id:String;
      
      private var _itemKeys:Vector.<String>;
      
      private var _adminOnly:Boolean;
      
      private var _dateStart:Date;
      
      private var _dateEnd:Date;
      
      private var _levelMin:int;
      
      private var _levelMax:int;
      
      private var _savingPerc:Number;
      
      public function StoreSale(param1:String, param2:DatabaseObject)
      {
         var _loc3_:int = 0;
         super();
         this._id = param1;
         this._adminOnly = param2.admin === true;
         this._savingPerc = Number(param2.savingPerc);
         this._levelMin = "levelMin" in param2 ? int(param2.levelMin) : 0;
         this._levelMax = "levelMax" in param2 ? int(param2.levelMax) : int.MAX_VALUE;
         this._dateStart = "start" in param2 ? new Date(param2.start) : null;
         this._dateEnd = "end" in param2 ? new Date(param2.end) : null;
         this._itemKeys = new Vector.<String>();
         if(param2.items is Array)
         {
            _loc3_ = 0;
            while(_loc3_ < param2.items.length)
            {
               this._itemKeys.push(param2.items[_loc3_].item);
               _loc3_++;
            }
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get savingPercentage() : Number
      {
         return this._savingPerc;
      }
      
      public function get itemKeys() : Vector.<String>
      {
         return this._itemKeys;
      }
      
      public function get adminOnly() : Boolean
      {
         return this._adminOnly;
      }
      
      public function get dateStart() : Date
      {
         return this._dateStart;
      }
      
      public function get dateEnd() : Date
      {
         return this._dateEnd;
      }
      
      public function get levelMin() : int
      {
         return this._levelMin;
      }
      
      public function get levelMax() : int
      {
         return this._levelMax;
      }
      
      public function isActive() : Boolean
      {
         if(this._adminOnly && Network.getInstance().playerData.isAdmin)
         {
            return true;
         }
         var _loc1_:Number = Network.getInstance().serverTime;
         if(this._dateStart != null && _loc1_ < this._dateStart.time || this._dateEnd != null && _loc1_ > this._dateEnd.time)
         {
            return false;
         }
         var _loc2_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         if(_loc2_ < this._levelMin || _loc2_ > this._levelMax)
         {
            return false;
         }
         return true;
      }
   }
}

