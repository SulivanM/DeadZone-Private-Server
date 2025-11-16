package thelaststand.app.game.data.bounty
{
   import org.osflash.signals.Signal;
   
   public class InfectedBountyTask
   {
      
      private var _index:int;
      
      private var _suburb:String;
      
      private var _isCompleted:Boolean;
      
      private var _conditions:Vector.<InfectedBountyTaskCondition>;
      
      private var _completedConditions:int;
      
      public var completed:Signal = new Signal(InfectedBountyTask);
      
      public var conditionCompleted:Signal = new Signal(InfectedBountyTask,InfectedBountyTaskCondition);
      
      public function InfectedBountyTask(param1:int, param2:Object)
      {
         super();
         this._index = param1;
         this.deserialize(param2);
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get suburb() : String
      {
         return this._suburb;
      }
      
      public function get isCompleted() : Boolean
      {
         return this._isCompleted;
      }
      
      public function get numConditions() : int
      {
         return this._conditions.length;
      }
      
      public function get numCompletedConditions() : int
      {
         return this._completedConditions;
      }
      
      public function complete() : void
      {
         if(this._isCompleted)
         {
            return;
         }
         this._isCompleted = true;
         var _loc1_:int = 0;
         while(_loc1_ < this._conditions.length)
         {
            this._conditions[_loc1_].complete();
            _loc1_++;
         }
         this._completedConditions = this._conditions.length;
         this.completed.dispatch(this);
      }
      
      public function getCondition(param1:int) : InfectedBountyTaskCondition
      {
         if(param1 < 0 || param1 >= this._conditions.length)
         {
            return null;
         }
         return this._conditions[param1];
      }
      
      private function deserialize(param1:Object) : void
      {
         var _loc5_:InfectedBountyTaskCondition = null;
         this._suburb = String(param1["suburb"]);
         var _loc2_:Array = param1["conditions"] as Array;
         this._conditions = new Vector.<InfectedBountyTaskCondition>(_loc2_.length,true);
         this._completedConditions = 0;
         var _loc3_:Boolean = true;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc5_ = new InfectedBountyTaskCondition(_loc4_,this._suburb,_loc2_[_loc4_]);
            this._conditions[_loc4_] = _loc5_;
            if(!_loc5_.isComplete)
            {
               _loc3_ = false;
               _loc5_.completed.addOnce(this.onConditionCompleted);
            }
            else
            {
               ++this._completedConditions;
            }
            _loc4_++;
         }
         this._isCompleted = _loc3_;
      }
      
      private function onConditionCompleted(param1:InfectedBountyTaskCondition) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         if(!this._isCompleted)
         {
            ++this._completedConditions;
            this.conditionCompleted.dispatch(this,param1);
            _loc2_ = true;
            _loc3_ = 0;
            while(_loc3_ < this._conditions.length)
            {
               if(!this._conditions[_loc3_].isComplete)
               {
                  _loc2_ = false;
                  break;
               }
               _loc3_++;
            }
            if(_loc2_)
            {
               this._isCompleted = true;
               this.completed.dispatch(this);
            }
         }
      }
   }
}

