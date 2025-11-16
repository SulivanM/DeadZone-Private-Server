package thelaststand.app.game.data.bounty
{
   import org.osflash.signals.Signal;
   import playerio.Message;
   import thelaststand.app.game.data.Item;
   
   public class InfectedBounty
   {
      
      private var _id:String;
      
      private var _tasks:Vector.<InfectedBountyTask>;
      
      private var _issueTime:Date;
      
      private var _isCompleted:Boolean;
      
      private var _isAbandoned:Boolean;
      
      private var _isViewed:Boolean;
      
      private var _rewardItemId:String;
      
      public var completed:Signal = new Signal(InfectedBounty);
      
      public var abandoned:Signal = new Signal(InfectedBounty);
      
      public var taskCompleted:Signal = new Signal(InfectedBounty,InfectedBountyTask);
      
      public var taskConditionCompleted:Signal = new Signal(InfectedBounty,InfectedBountyTask,InfectedBountyTaskCondition);
      
      public var viewed:Signal = new Signal(InfectedBounty);
      
      public function InfectedBounty(param1:Object)
      {
         super();
         this.deserialize(param1);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get numTasks() : int
      {
         return this._tasks.length;
      }
      
      public function get issueTime() : Date
      {
         return this._issueTime;
      }
      
      public function get isCompleted() : Boolean
      {
         return this._isCompleted;
      }
      
      public function get isActive() : Boolean
      {
         return !this._isCompleted && !this._isAbandoned;
      }
      
      public function get isAbandoned() : Boolean
      {
         return this._isAbandoned;
      }
      
      public function get isViewed() : Boolean
      {
         return this._isViewed;
      }
      
      public function set isViewed(param1:Boolean) : void
      {
         if(param1 == this._isViewed)
         {
            return;
         }
         this._isViewed = param1;
         if(this._isViewed)
         {
            this.viewed.dispatch(this);
         }
      }
      
      public function get rewardItemId() : String
      {
         return this._rewardItemId;
      }
      
      public function abandon() : void
      {
         if(this._isCompleted || this._isAbandoned)
         {
            return;
         }
         this._isAbandoned = true;
         this.abandoned.dispatch(this);
      }
      
      public function complete(param1:Item) : void
      {
         this._rewardItemId = param1.id;
         if(this._isCompleted || this._isAbandoned)
         {
            return;
         }
         this._isCompleted = true;
         var _loc2_:int = 0;
         while(_loc2_ < this._tasks.length)
         {
            this._tasks[_loc2_].complete();
            _loc2_++;
         }
         this.completed.dispatch(this);
      }
      
      public function getTask(param1:int) : InfectedBountyTask
      {
         if(param1 < 0 || param1 >= this._tasks.length)
         {
            return null;
         }
         return this._tasks[param1];
      }
      
      public function getTaskForSuburb(param1:String) : InfectedBountyTask
      {
         var _loc3_:InfectedBountyTask = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._tasks.length)
         {
            _loc3_ = this._tasks[_loc2_];
            if(_loc3_.suburb == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function parseUpdateMessage(param1:Message) : void
      {
         var _loc4_:InfectedBountyTask = null;
         var _loc5_:int = 0;
         var _loc6_:InfectedBountyTaskCondition = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._tasks.length)
         {
            _loc4_ = this._tasks[_loc3_];
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numConditions)
            {
               _loc6_ = _loc4_.getCondition(_loc5_);
               _loc6_.kills = param1.getInt(_loc2_++);
               if(_loc2_ >= param1.length)
               {
                  return;
               }
               _loc5_++;
            }
            _loc3_++;
         }
      }
      
      private function deserialize(param1:Object) : void
      {
         var _loc5_:InfectedBountyTask = null;
         this._id = String(param1["id"]);
         this._isCompleted = Boolean(param1["completed"]);
         this._isAbandoned = Boolean(param1["abandoned"]);
         this._isViewed = Boolean(param1["viewed"]);
         this._rewardItemId = String(param1["rewardItemId"]);
         var _loc2_:Object = param1["issueTime"];
         if(_loc2_ is Date)
         {
            this._issueTime = _loc2_ as Date;
         }
         else
         {
            this._issueTime = new Date(_loc2_);
            this._issueTime.minutes -= this._issueTime.getTimezoneOffset();
         }
         var _loc3_:Array = param1["tasks"] as Array;
         this._tasks = new Vector.<InfectedBountyTask>(_loc3_.length,true);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = new InfectedBountyTask(_loc4_,_loc3_[_loc4_]);
            _loc5_.completed.add(this.onTaskCompleted);
            _loc5_.conditionCompleted.add(this.onTaskConditionCompleted);
            this._tasks[_loc4_] = _loc5_;
            _loc4_++;
         }
      }
      
      private function onTaskCompleted(param1:InfectedBountyTask) : void
      {
         this.taskCompleted.dispatch(this,param1);
      }
      
      private function onTaskConditionCompleted(param1:InfectedBountyTask, param2:InfectedBountyTaskCondition) : void
      {
         if(this._isCompleted || this._isAbandoned)
         {
            return;
         }
         this.taskConditionCompleted.dispatch(this,param1,param2);
      }
   }
}

