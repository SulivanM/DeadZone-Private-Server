package thelaststand.app.game.data.research
{
   import com.exileetiquette.math.MathUtils;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.utils.DictionaryUtils;
   
   public class ResearchState
   {
      
      private var _effects:Dictionary = new Dictionary(true);
      
      private var _levels:Dictionary = new Dictionary(true);
      
      private var _tasks:Vector.<ResearchTask> = new Vector.<ResearchTask>();
      
      public var researchStarted:Signal = new Signal(ResearchTask);
      
      public var researchCompleted:Signal = new Signal(ResearchTask);
      
      public var effectsChanged:Signal = new Signal();
      
      public function ResearchState()
      {
         super();
      }
      
      public function get currentTask() : ResearchTask
      {
         return this._tasks.length > 0 ? this._tasks[0] : null;
      }
      
      public function get tasks() : Vector.<ResearchTask>
      {
         return this._tasks;
      }
      
      public function get effects() : Dictionary
      {
         return this._effects;
      }
      
      public function getEffectValue(param1:String) : Number
      {
         var _loc2_:Number = Number(this._effects[param1]);
         return isNaN(_loc2_) ? 0 : _loc2_;
      }
      
      public function getCompletedTaskCount() : int
      {
         var _loc2_:String = null;
         var _loc1_:int = 0;
         for(_loc2_ in this._levels)
         {
            _loc1_ += int(this._levels[_loc2_] + 1);
         }
         return _loc1_;
      }
      
      public function getLevel(param1:String, param2:String) : int
      {
         var _loc3_:String = param1 + ":" + param2;
         var _loc4_:int = this._levels[_loc3_] == undefined ? -1 : int(this._levels[_loc3_]);
         return isNaN(_loc4_) ? -1 : _loc4_;
      }
      
      public function getCategoryPrecentage(param1:String) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc2_:XML = ResearchSystem.getCategoryXML(param1);
         if(_loc2_ == null)
         {
            return 0;
         }
         for each(_loc5_ in _loc2_.group)
         {
            _loc3_ += _loc5_.level.length();
            _loc6_ = this.getLevel(param1,_loc5_.@id.toString());
            if(_loc6_ > -1)
            {
               _loc4_ += _loc6_ + 1;
            }
         }
         return MathUtils.clamp(_loc4_ / _loc3_,0,1);
      }
      
      public function getGroupPrecentage(param1:String, param2:String) : Number
      {
         var _loc3_:XML = ResearchSystem.getCategoryGroupXML(param1,param1);
         if(_loc3_ == null)
         {
            return 0;
         }
         var _loc4_:int = int(_loc3_.level.length());
         var _loc5_:int = int(this._levels[param1 + ":" + param2]);
         return MathUtils.clamp(_loc5_ / _loc4_,0,1);
      }
      
      public function setLevel(param1:String, param2:String, param3:int) : void
      {
         var _loc4_:String = param1 + ":" + param2;
         if(param3 < 0)
         {
            delete this._levels[_loc4_];
            return;
         }
         this._levels[_loc4_] = param3;
      }
      
      public function addTask(param1:ResearchTask) : void
      {
         this._tasks.push(param1);
      }
      
      public function removeTask(param1:ResearchTask) : void
      {
         var _loc2_:int = int(this._tasks.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._tasks.splice(_loc2_,1);
         }
      }
      
      public function removeTaskById(param1:String) : ResearchTask
      {
         var _loc3_:ResearchTask = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._tasks.length)
         {
            _loc3_ = this._tasks[_loc2_];
            if(_loc3_.id == param1)
            {
               this._tasks.splice(_loc2_,1);
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function removeTaskByType(param1:String, param2:String, param3:int) : ResearchTask
      {
         var _loc5_:ResearchTask = null;
         var _loc4_:int = 0;
         while(_loc4_ < this._tasks.length)
         {
            _loc5_ = this._tasks[_loc4_];
            if(_loc5_.category == param1 && _loc5_.group == param2 && _loc5_.level == param3)
            {
               this._tasks.splice(_loc4_,1);
               return _loc5_;
            }
            _loc4_++;
         }
         return null;
      }
      
      public function getTaskById(param1:String) : ResearchTask
      {
         var _loc3_:ResearchTask = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._tasks.length)
         {
            _loc3_ = this._tasks[_loc2_];
            if(_loc3_.id == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function parse(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:ResearchTask = null;
         var _loc6_:String = null;
         this._levels = new Dictionary(true);
         this._tasks.length = 0;
         var _loc2_:Array = param1.active as Array;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = _loc2_[_loc3_];
               _loc5_ = new ResearchTask();
               _loc5_.parse(_loc4_);
               this._tasks.push(_loc5_);
               _loc3_++;
            }
         }
         if(param1.levels != null)
         {
            for(_loc6_ in param1.levels)
            {
               this._levels[_loc6_] = int(param1.levels[_loc6_]);
            }
         }
      }
      
      public function parseEffects(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Number = NaN;
         DictionaryUtils.clear(this._effects);
         for(_loc2_ in param1)
         {
            _loc3_ = Number(param1[_loc2_]);
            if(!isNaN(_loc3_))
            {
               this._effects[_loc2_] = _loc3_;
            }
         }
         this.effectsChanged.dispatch();
      }
   }
}

