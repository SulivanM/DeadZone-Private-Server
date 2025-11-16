package thelaststand.app.game.data.quests
{
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   
   public class GlobalQuestData
   {
      
      private var _dict:Dictionary = new Dictionary();
      
      public function GlobalQuestData()
      {
         super();
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc3_:GQDataObj = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(!(param1 is ByteArray))
         {
            return;
         }
         var _loc2_:ByteArray = ByteArray(param1);
         _loc2_.endian = Endian.LITTLE_ENDIAN;
         _loc2_.position = 0;
         while(_loc2_.position < _loc2_.length)
         {
            _loc3_ = new GQDataObj();
            _loc3_.id = String(_loc2_.readUnsignedShort());
            _loc4_ = _loc2_.readByte();
            _loc3_.contributed = (_loc4_ >> 1 & 1) == 1;
            _loc3_.collected = (_loc4_ & 1) == 1;
            _loc3_.contributedLevel = _loc2_.readByte();
            _loc5_ = _loc2_.readByte();
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc3_.statValues[_loc6_] = _loc2_.readUnsignedInt();
               _loc6_++;
            }
            this._dict[_loc3_.id] = _loc3_;
         }
      }
      
      public function getContributed(param1:String) : Boolean
      {
         this.createObjectIfRequired(param1);
         return Boolean(this._dict[param1].contributed);
      }
      
      public function setContributed(param1:String, param2:int) : void
      {
         this.createObjectIfRequired(param1);
         this._dict[param1].contributed = true;
         this._dict[param1].contributedLevel = param2;
      }
      
      public function getTotal(param1:String, param2:int) : int
      {
         this.createObjectIfRequired(param1);
         if(param2 >= this._dict[param1].statValues.length)
         {
            return 0;
         }
         return this._dict[param1].statValues[param2];
      }
      
      public function getContributedLevel(param1:String) : int
      {
         this.createObjectIfRequired(param1);
         return this._dict[param1].contributedLevel;
      }
      
      public function getCollected(param1:String) : Boolean
      {
         this.createObjectIfRequired(param1);
         return Boolean(this._dict[param1].collected);
      }
      
      public function setCollected(param1:String) : void
      {
         this.createObjectIfRequired(param1);
         this._dict[param1].collected = true;
      }
      
      private function createObjectIfRequired(param1:String) : void
      {
         if(this._dict[param1] != null)
         {
            return;
         }
         this._dict[param1] = new GQDataObj();
         this._dict[param1].id = param1;
      }
   }
}

class GQDataObj
{
   
   public var id:String;
   
   public var collected:Boolean;
   
   public var contributed:Boolean;
   
   public var contributedLevel:int = -1;
   
   public var statValues:Array = [];
   
   public function GQDataObj()
   {
      super();
   }
}
