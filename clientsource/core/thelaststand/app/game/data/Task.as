package thelaststand.app.game.data
{
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   
   public class Task
   {
      
      protected var _type:String;
      
      protected var _time:Number = 0;
      
      protected var _length:int;
      
      protected var _items:Vector.<Item>;
      
      private var _complete:Boolean;
      
      private var _id:String;
      
      private var _survivors:Vector.<Survivor>;
      
      private var _status:String;
      
      private var _lastUpdate:Number = -1;
      
      public var completed:Signal;
      
      public var statusChanged:Signal;
      
      public function Task()
      {
         super();
         this._id = GUID.create();
         this._survivors = new Vector.<Survivor>();
         this._items = new Vector.<Item>();
         this._status = TaskStatus.INACTIVE;
         this.completed = new Signal(Task);
         this.statusChanged = new Signal(Task);
      }
      
      public function assignSurvivor(param1:Survivor) : void
      {
         if(param1.task == this || param1.state & SurvivorState.ON_MISSION || Boolean(param1.state & SurvivorState.ON_ASSIGNMENT))
         {
            return;
         }
         if(param1.task != null)
         {
            param1.task.removeSurvivor(param1);
         }
         param1.task = this;
         if(this._survivors.indexOf(param1) == -1)
         {
            this._survivors.push(param1);
         }
         if(!this._complete)
         {
            this.setStatus(TaskStatus.ACTIVE);
         }
      }
      
      public function dispose() : void
      {
         this._id = null;
         this._type = null;
         this._survivors = null;
         this.completed.removeAll();
         this.completed = null;
      }
      
      public function getSecondsRemaining() : int
      {
         return int((this._length - this._time) / Math.max(1,this._survivors.length));
      }
      
      public function getXP() : int
      {
         return 0;
      }
      
      public function removeSurvivor(param1:Survivor) : void
      {
         if(param1.task == this)
         {
            param1.task = null;
         }
         var _loc2_:int = int(this._survivors.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._survivors.splice(_loc2_,1);
         }
         if(this._survivors.length == 0)
         {
            this.setStatus(this._complete ? TaskStatus.COMPLETE : TaskStatus.INACTIVE);
         }
      }
      
      public function removeAllSurvivors() : Array
      {
         var _loc2_:Survivor = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this._survivors)
         {
            if(_loc2_.task == this)
            {
               _loc1_.push(_loc2_.id.toUpperCase());
               _loc2_.task = null;
            }
         }
         this._survivors.length = 0;
         this.setStatus(this._complete ? TaskStatus.COMPLETE : TaskStatus.INACTIVE);
         return _loc1_;
      }
      
      public function setItems(param1:Array) : void
      {
         var _loc3_:Item = null;
         this._items.length = 0;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = ItemFactory.createItemFromObject(param1[_loc2_]);
            if(_loc3_ != null)
            {
               this._items.push(_loc3_);
            }
            _loc2_++;
         }
      }
      
      public function speedUp(param1:Object, param2:Function = null) : void
      {
         var network:Network = null;
         var option:Object = param1;
         var onComplete:Function = param2;
         network = Network.getInstance();
         var timeRemaining:int = this._length - this._time;
         var speedUpCost:int = network.data.costTable.getCostForTime(option,timeRemaining);
         var cash:int = network.playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
         }
         else
         {
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "option":option.key
            },SaveDataMethod.TASK_SPEED_UP,function(param1:Object):void
            {
               network.completeAsyncOp();
               if(param1 == null)
               {
                  return;
               }
               if(param1.error == PlayerIOError.NotEnoughCoins.errorID)
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen();
               }
               if(param1.success === false)
               {
                  return;
               }
               if(param1.complete === true)
               {
                  completeTask();
               }
               else
               {
                  _time += int(param1.time);
               }
               Tracking.trackEvent("SpeedUp",option.key,_type,int(param1.cost));
               if(onComplete != null)
               {
                  onComplete();
               }
            });
         }
      }
      
      public function completeTask() : void
      {
         var _loc1_:Item = null;
         var _loc2_:Survivor = null;
         if(this._complete)
         {
            return;
         }
         this._complete = true;
         this._time = this._length;
         NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.TASK_COMPLETE,this._id));
         for each(_loc1_ in this._items)
         {
            Network.getInstance().playerData.giveItem(_loc1_);
         }
         this.setStatus(TaskStatus.COMPLETE);
         this.completed.dispatch(this);
         for each(_loc2_ in this._survivors)
         {
            _loc2_.task = null;
         }
         this._survivors.length = 0;
      }
      
      public function updateTimer() : void
      {
         var _loc2_:Number = NaN;
         var _loc1_:Number = Network.getInstance().serverTime;
         if(this._lastUpdate == -1)
         {
            this._lastUpdate = _loc1_;
         }
         if(this._survivors.length > 0)
         {
            _loc2_ = _loc1_ - this._lastUpdate;
            this._time += _loc2_ / 1000 * this._survivors.length;
         }
         if(this._time >= this._length)
         {
            this._time = this._length;
         }
         this._lastUpdate = _loc1_;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         var _loc2_:Survivor = null;
         param1 ||= {};
         param1.id = this._id;
         param1.type = this._type;
         param1.length = this._length;
         param1.time = this._time;
         param1.survivors = [];
         for each(_loc2_ in this._survivors)
         {
            param1.survivors.push(_loc2_.id.toUpperCase());
         }
         return param1;
      }
      
      public function readObject(param1:Object, param2:CompoundData) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:Item = null;
         var _loc5_:String = null;
         var _loc6_:Survivor = null;
         this._id = String(param1.id).toUpperCase();
         this._type = String(param1.type);
         this._length = int(param1.length);
         this._time = Number(param1.time);
         if(param1.items != null)
         {
            this._items.length = 0;
            _loc3_ = 0;
            while(_loc3_ < param1.items.length)
            {
               if(param1.items[_loc3_] != null)
               {
                  _loc4_ = ItemFactory.createItemFromObject(param1.items[_loc3_]);
                  if(_loc4_ != null)
                  {
                     this._items.push(_loc4_);
                  }
               }
               _loc3_++;
            }
         }
         this._lastUpdate = -1;
         this._complete = Boolean(param1.completed);
         if(this._complete)
         {
            this._status = TaskStatus.COMPLETE;
         }
         else
         {
            this._survivors.length = 0;
            if(param1.survivors is Array && param2 != null && param2.survivors != null)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.survivors.length)
               {
                  _loc5_ = param1.survivors[_loc3_];
                  if(_loc5_ != null)
                  {
                     _loc6_ = param2.survivors.getSurvivorById(_loc5_);
                     if(_loc6_ != null)
                     {
                        _loc6_.task = this;
                        this._survivors.push(_loc6_);
                     }
                  }
                  _loc3_++;
               }
            }
            this._status = this._survivors.length > 0 ? TaskStatus.ACTIVE : TaskStatus.INACTIVE;
            this.updateTimer();
         }
         return true;
      }
      
      private function setStatus(param1:String) : void
      {
         if(param1 == this._status)
         {
            return;
         }
         this._status = param1;
         this.statusChanged.dispatch(this);
      }
      
      public function get id() : String
      {
         return this._id.toUpperCase();
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function get items() : Vector.<Item>
      {
         return this._items;
      }
      
      public function get status() : String
      {
         return this._status;
      }
      
      public function get survivors() : Vector.<Survivor>
      {
         return this._survivors;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function set time(param1:Number) : void
      {
         this._time = param1;
      }
      
      public function get length() : int
      {
         return this._length;
      }
      
      public function set length(param1:int) : void
      {
         this._length = param1;
      }
      
      public function get type() : String
      {
         return this._type;
      }
   }
}

