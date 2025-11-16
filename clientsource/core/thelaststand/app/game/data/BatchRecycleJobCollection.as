package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import thelaststand.common.io.ISerializable;
   
   public class BatchRecycleJobCollection implements ISerializable
   {
      
      private var _jobs:Vector.<BatchRecycleJob>;
      
      private var _jobsById:Dictionary;
      
      public function BatchRecycleJobCollection()
      {
         super();
         this._jobs = new Vector.<BatchRecycleJob>();
         this._jobsById = new Dictionary(true);
      }
      
      public function dispose() : void
      {
         var _loc1_:BatchRecycleJob = null;
         for each(_loc1_ in this._jobs)
         {
            _loc1_.completed.remove(this.onJobCompleted);
         }
         this._jobs = null;
         this._jobsById = null;
      }
      
      public function add(param1:BatchRecycleJob) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(this._jobs.indexOf(param1) > -1)
         {
            return;
         }
         this._jobs.unshift(param1);
         this._jobsById[param1.id.toUpperCase()] = param1;
         param1.completed.addOnce(this.onJobCompleted);
      }
      
      public function clear() : void
      {
         var _loc1_:BatchRecycleJob = null;
         for each(_loc1_ in this._jobs)
         {
            _loc1_.completed.remove(this.onJobCompleted);
            delete this._jobsById[_loc1_.id.toUpperCase()];
         }
         this._jobs.length = 0;
      }
      
      public function getJob(param1:int) : BatchRecycleJob
      {
         if(param1 < 0 || param1 >= this._jobs.length)
         {
            return null;
         }
         return this._jobs[param1];
      }
      
      public function getJobById(param1:String) : BatchRecycleJob
      {
         param1 = param1.toUpperCase();
         return this._jobsById[param1];
      }
      
      public function remove(param1:BatchRecycleJob) : void
      {
         if(param1 == null)
         {
            return;
         }
         param1.completed.remove(this.onJobCompleted);
         var _loc2_:int = int(this._jobs.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._jobs.splice(_loc2_,1);
         }
         var _loc3_:String = param1.id.toUpperCase();
         this._jobsById[_loc3_] = null;
         delete this._jobsById[_loc3_];
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return null;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc3_:BatchRecycleJob = null;
         if(!(param1 is Array))
         {
            return;
         }
         this._jobs.length = 0;
         this._jobsById = new Dictionary(true);
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            if(param1[_loc2_] == null)
            {
               return;
            }
            _loc3_ = new BatchRecycleJob();
            _loc3_.readObject(param1[_loc2_]);
            this._jobs.push(_loc3_);
            this._jobsById[_loc3_.id.toUpperCase()] = _loc3_;
            if(!_loc3_.isComplete)
            {
               _loc3_.completed.addOnce(this.onJobCompleted);
            }
            _loc2_++;
         }
      }
      
      private function onJobCompleted(param1:BatchRecycleJob) : void
      {
         this.remove(param1);
      }
      
      public function get numActiveJobs() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._jobs.length)
         {
            if(!this._jobs[_loc2_].isComplete)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
   }
}

