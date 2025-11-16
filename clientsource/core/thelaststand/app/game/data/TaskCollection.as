package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.task.JunkRemovalTask;
   import thelaststand.common.io.ISerializable;
   
   public class TaskCollection implements ISerializable
   {
      
      private var _compound:CompoundData;
      
      private var _tasks:Vector.<Task>;
      
      private var _tasksById:Dictionary;
      
      public var taskAdded:Signal;
      
      public var taskRemoved:Signal;
      
      public var taskCompleted:Signal;
      
      public function TaskCollection(param1:CompoundData)
      {
         super();
         this._compound = param1;
         this._tasks = new Vector.<Task>();
         this._tasksById = new Dictionary(true);
         this.taskAdded = new Signal(Task);
         this.taskRemoved = new Signal(Task);
         this.taskCompleted = new Signal(Task);
      }
      
      public function addTask(param1:Task) : Task
      {
         if(this._tasks.indexOf(param1) > -1)
         {
            return null;
         }
         if(this._tasksById[param1.id] != null)
         {
            return null;
         }
         this._tasks.push(param1);
         this._tasksById[param1.id] = param1;
         param1.completed.addOnce(this.onTaskCompleted);
         this.taskAdded.dispatch(param1);
         return param1;
      }
      
      public function containsTask(param1:Task) : Boolean
      {
         return this._tasks.indexOf(param1) > -1;
      }
      
      public function containsTaskId(param1:String) : Boolean
      {
         return this._tasks[param1] != null;
      }
      
      public function dispose() : void
      {
         this.taskAdded.removeAll();
         this.taskRemoved.removeAll();
         this.taskCompleted.removeAll();
         this._tasks = null;
         this._tasksById = null;
         this._compound = null;
      }
      
      public function getTask(param1:uint) : Task
      {
         if(param1 < 0 || param1 >= this._tasks.length)
         {
            return null;
         }
         return this._tasks[param1];
      }
      
      public function getTaskById(param1:String) : Task
      {
         return this._tasksById[param1];
      }
      
      public function getTasksOfType(param1:String) : Vector.<Task>
      {
         var _loc3_:Task = null;
         var _loc2_:Vector.<Task> = new Vector.<Task>();
         for each(_loc3_ in this._tasks)
         {
            if(_loc3_.type == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         var _loc2_:Task = null;
         if(!param1)
         {
            param1 = [];
         }
         for each(_loc2_ in this._tasks)
         {
            param1.push(_loc2_.writeObject());
         }
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc4_:Task = null;
         this._tasks.length = 0;
         if(!(param1 is Array))
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = int(param1.length);
         while(_loc2_ < _loc3_)
         {
            if(param1[_loc2_] != null)
            {
               switch(param1[_loc2_].type)
               {
                  case TaskType.JUNK_REMOVAL:
                     _loc4_ = new JunkRemovalTask(null);
               }
               if(_loc4_ != null && _loc4_.readObject(param1[_loc2_],this._compound))
               {
                  _loc4_.completed.addOnce(this.onTaskCompleted);
                  this._tasks.push(_loc4_);
               }
            }
            _loc2_++;
         }
         this.buildIdLookup();
      }
      
      public function removeTask(param1:Task) : Task
      {
         var _loc2_:int = int(this._tasks.indexOf(param1));
         if(_loc2_ == -1)
         {
            return null;
         }
         if(this._tasksById[param1.id] == null)
         {
            return null;
         }
         this._tasks.splice(_loc2_,1);
         this._tasksById[param1.id] = null;
         delete this._tasksById[param1.id];
         param1.completed.remove(this.onTaskCompleted);
         this.taskRemoved.dispatch(param1);
         return param1;
      }
      
      public function removeTaskById(param1:String) : Task
      {
         var _loc2_:Task = this._tasksById[param1];
         return this.removeTask(_loc2_);
      }
      
      public function removeAll() : void
      {
         var _loc1_:Task = null;
         for each(_loc1_ in this._tasks)
         {
            this._tasksById[_loc1_.id] = null;
            delete this._tasksById[_loc1_.id];
            _loc1_.completed.remove(this.onTaskCompleted);
         }
         this._tasks.length = 0;
      }
      
      private function buildIdLookup() : void
      {
         var _loc1_:Task = null;
         this._tasksById = new Dictionary(true);
         for each(_loc1_ in this._tasks)
         {
            this._tasksById[_loc1_.id] = _loc1_;
         }
      }
      
      private function onTaskCompleted(param1:Task) : void
      {
         this.removeTask(param1);
         this.taskCompleted.dispatch(param1);
      }
      
      public function get compound() : CompoundData
      {
         return this._compound;
      }
      
      public function get length() : int
      {
         return this._tasks.length;
      }
   }
}

