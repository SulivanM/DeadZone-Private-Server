package thelaststand.app.game.data.alliance
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   
   public class AllianceList
   {
      
      private var _alliances:Vector.<AllianceDataSummary>;
      
      private var _allianceById:Dictionary;
      
      private var _numAlliances:int;
      
      public var allianceAdded:Signal = new Signal(AllianceDataSummary);
      
      public var allianceRemoved:Signal = new Signal(AllianceDataSummary);
      
      public var changed:Signal = new Signal();
      
      public function AllianceList()
      {
         super();
         this._alliances = new Vector.<AllianceDataSummary>();
         this._allianceById = new Dictionary(true);
      }
      
      public function get numAlliances() : int
      {
         return this._numAlliances;
      }
      
      public function dispose() : void
      {
         this._numAlliances = 0;
         this._alliances = null;
         this._allianceById = null;
         this.allianceAdded.removeAll();
         this.allianceRemoved.removeAll();
         this.changed.removeAll();
      }
      
      public function clear() : void
      {
         this._numAlliances = 0;
         this._alliances.length = 0;
         this._allianceById = new Dictionary(true);
         this.changed.dispatch();
      }
      
      public function contains(param1:AllianceDataSummary) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return this._allianceById[param1.id] == param1;
      }
      
      public function containsId(param1:String) : Boolean
      {
         return this._allianceById[param1] != null;
      }
      
      public function addMember(param1:AllianceDataSummary) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._alliances.indexOf(param1));
         if(_loc2_ > -1)
         {
            return;
         }
         this._alliances.push(param1);
         this._allianceById[param1.id] = param1;
         ++this._numAlliances;
         this.allianceAdded.dispatch(param1);
         this.changed.dispatch();
      }
      
      public function removeAlliance(param1:AllianceDataSummary) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._alliances.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._alliances.splice(_loc2_,1);
         }
         delete this._allianceById[param1.id];
         --this._numAlliances;
         this.allianceRemoved.dispatch(param1);
         this.changed.dispatch();
      }
      
      public function removeAllianceById(param1:String) : void
      {
         this.removeAlliance(this.getAllianceById(param1));
      }
      
      public function getAlliance(param1:int) : AllianceDataSummary
      {
         if(param1 < 0 || param1 >= this._numAlliances)
         {
            return null;
         }
         return this._alliances[param1];
      }
      
      public function getAllianceById(param1:String) : AllianceDataSummary
      {
         return this._allianceById[param1];
      }
      
      public function deserialize(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:AllianceDataSummary = null;
         this.clear();
         var _loc2_:Array = param1 as Array;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            if(param1 != null)
            {
               _loc5_ = new AllianceDataSummary(param1[_loc3_].allianceId || param1[_loc3_].id);
               _loc5_.deserialize(param1[_loc3_]);
               this._alliances.push(_loc5_);
               this._allianceById[_loc5_.id] = _loc5_;
               ++this._numAlliances;
            }
            _loc3_++;
         }
         this.changed.dispatch();
      }
   }
}

