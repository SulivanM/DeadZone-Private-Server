package thelaststand.app.game.data.assignment
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.network.Network;
   
   public class AssignmentData
   {
      
      protected var _xml:XML;
      
      protected var _id:String;
      
      protected var _name:String;
      
      protected var _type:String;
      
      protected var _survivorIds:Vector.<String> = new Vector.<String>();
      
      protected var _started:Boolean;
      
      protected var _completed:Boolean;
      
      protected var _bailOut:Boolean;
      
      protected var _successful:Boolean;
      
      protected var _minLevel:int;
      
      protected var _minSurvivorCount:int;
      
      protected var _maxSurvivorCount:int;
      
      protected var _currentStageIndex:int;
      
      protected var _completedStageIndex:int;
      
      protected var _stages:Vector.<AssignmentStageData>;
      
      protected var _stageCount:int;
      
      protected var _rewardItems:Vector.<Item>;
      
      protected var _rewardTierCount:int;
      
      protected var _rewardTierPoints:Vector.<int>;
      
      public var survivorsChanged:Signal = new Signal();
      
      public var survivorLoadoutChanged:Signal = new Signal();
      
      public function AssignmentData()
      {
         super();
         this._id = GUID.create();
      }
      
      public static function create(param1:Object) : AssignmentData
      {
         var _loc2_:AssignmentData = null;
         if(!param1 || !param1.type)
         {
            return null;
         }
         switch(param1.type)
         {
            case AssignmentType.Raid:
               _loc2_ = new RaidData();
               break;
            case AssignmentType.Arena:
               _loc2_ = new ArenaSession();
               break;
            default:
               return null;
         }
         if(!_loc2_.parse(param1))
         {
            return null;
         }
         return _loc2_;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get hasStarted() : Boolean
      {
         return this._started;
      }
      
      public function set hasStarted(param1:Boolean) : void
      {
         this._started = param1;
      }
      
      public function get isCompleted() : Boolean
      {
         return this._completed;
      }
      
      public function set isCompleted(param1:Boolean) : void
      {
         this._completed = param1;
      }
      
      public function get successful() : Boolean
      {
         return this._successful;
      }
      
      public function set successful(param1:Boolean) : void
      {
         this._successful = param1;
      }
      
      public function get bailOut() : Boolean
      {
         return this._bailOut;
      }
      
      public function set bailOut(param1:Boolean) : void
      {
         this._bailOut = param1;
      }
      
      public function get survivorIds() : Vector.<String>
      {
         return this._survivorIds;
      }
      
      public function get minLevel() : int
      {
         return this._minLevel;
      }
      
      public function get minSurvivorCount() : int
      {
         return this._minSurvivorCount;
      }
      
      public function get maxSurvivorCount() : int
      {
         return this._maxSurvivorCount;
      }
      
      public function get stageCount() : int
      {
         return this._stageCount;
      }
      
      public function get currentStageIndex() : int
      {
         return this._currentStageIndex;
      }
      
      public function set currentStageIndex(param1:int) : void
      {
         this._currentStageIndex = param1;
      }
      
      public function get completedStageIndex() : int
      {
         return this._completedStageIndex;
      }
      
      public function set completedStageIndex(param1:int) : void
      {
         this._completedStageIndex = param1;
      }
      
      public function get rewardTierCount() : int
      {
         return this._rewardTierCount;
      }
      
      public function get currentRewardTier() : int
      {
         return this.getCurrentRewardTier();
      }
      
      public function get rewardItems() : Vector.<Item>
      {
         return this._rewardItems;
      }
      
      public function set rewardItems(param1:Vector.<Item>) : void
      {
         this._rewardItems = param1;
      }
      
      public function get xml() : XML
      {
         return this._xml;
      }
      
      public function getSurvivorList() : Vector.<Survivor>
      {
         var _loc3_:String = null;
         var _loc4_:Survivor = null;
         var _loc1_:Vector.<Survivor> = new Vector.<Survivor>();
         var _loc2_:int = 0;
         while(_loc2_ < this._survivorIds.length)
         {
            _loc3_ = this._survivorIds[_loc2_];
            _loc4_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc3_);
            _loc1_.push(_loc4_);
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function addSurvivor(param1:Survivor) : void
      {
         if(this._survivorIds.indexOf(param1.id) > -1)
         {
            return;
         }
         this._survivorIds.push(param1.id);
         this.survivorsChanged.dispatch();
         param1.loadoutOffence.changed.add(this.onSurvivorLoadoutChanged);
      }
      
      public function removeSurvivor(param1:Survivor) : void
      {
         var _loc2_:int = int(this._survivorIds.indexOf(param1.id));
         if(_loc2_ == -1)
         {
            return;
         }
         this._survivorIds.splice(_loc2_,1);
         this.survivorsChanged.dispatch();
         param1.loadoutOffence.changed.remove(this.onSurvivorLoadoutChanged);
      }
      
      public function getStage(param1:int) : AssignmentStageData
      {
         return this._stages[param1];
      }
      
      public function getRewardTierXML(param1:int) : XML
      {
         if(param1 < 0 || param1 >= this._rewardTierCount)
         {
            return null;
         }
         return this._xml.rewards.tier[param1];
      }
      
      public function setXML(param1:XML) : Boolean
      {
         var _loc3_:AssignmentStageData = null;
         if(param1 == null)
         {
            return false;
         }
         this._xml = param1;
         this._name = this._xml.@id.toString();
         this._minLevel = Math.max(int(this._xml.level_min),0);
         this._minSurvivorCount = Math.max(int(this._xml.survivor_min),1);
         this._maxSurvivorCount = Math.min(int(this._xml.survivor_max),5);
         this._stageCount = this._xml.stage.length();
         this._currentStageIndex = 0;
         this._stages = new Vector.<AssignmentStageData>(this._stageCount);
         var _loc2_:int = 0;
         while(_loc2_ < this._stageCount)
         {
            _loc3_ = this.createStageData(_loc2_);
            _loc3_.state = _loc2_ == 0 ? AssignmentStageState.ACTIVE : AssignmentStageState.LOCKED;
            this._stages[_loc2_] = _loc3_;
            _loc2_++;
         }
         return this.onSetXML(param1);
      }
      
      public function parse(param1:Object) : Boolean
      {
         var _loc2_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Survivor = null;
         var _loc7_:Object = null;
         var _loc8_:AssignmentStageData = null;
         var _loc9_:AssignmentStageData = null;
         if(!this.setXML(this.getXmlNode(param1.name)))
         {
            return false;
         }
         this._id = String(param1.id);
         this._started = Boolean(param1.started);
         this._completed = Boolean(param1.competed);
         this._currentStageIndex = int(param1.stageindex);
         this._survivorIds.length = 0;
         var _loc3_:Array = param1.survivors as Array;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            _loc5_ = String(_loc3_[_loc2_]);
            this._survivorIds.push(_loc5_);
            _loc6_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc5_);
            _loc6_.loadoutOffence.changed.add(this.onSurvivorLoadoutChanged);
            _loc2_++;
         }
         var _loc4_:Array = param1.stagelist as Array;
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            _loc7_ = _loc4_[_loc2_];
            _loc8_ = this._stages[int(_loc7_.stage)];
            _loc8_.parse(_loc7_);
            _loc2_++;
         }
         if(!this._completed)
         {
            _loc9_ = this._stages[this._currentStageIndex];
            _loc9_.state = AssignmentStageState.ACTIVE;
         }
         return this.onParse(param1);
      }
      
      protected function onParse(param1:Object) : Boolean
      {
         return true;
      }
      
      protected function onSetXML(param1:XML) : Boolean
      {
         return true;
      }
      
      protected function getXmlNode(param1:String) : XML
      {
         throw new Error("This method must be implemented by subclasses");
      }
      
      protected function getCurrentRewardTier() : int
      {
         throw new Error("This method must be implemented by subclasses");
      }
      
      protected function createStageData(param1:int) : AssignmentStageData
      {
         throw new Error("This method must be implemented by subclasses");
      }
      
      private function onSurvivorLoadoutChanged() : void
      {
         this.survivorLoadoutChanged.dispatch();
      }
   }
}

