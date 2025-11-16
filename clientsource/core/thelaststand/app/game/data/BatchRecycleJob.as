package thelaststand.app.game.data
{
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.notification.NotificationFactory;
   import thelaststand.app.game.data.notification.NotificationType;
   import thelaststand.app.game.logic.NotificationSystem;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.io.ISerializable;
   
   public class BatchRecycleJob implements ISerializable
   {
      
      private static var _constantsSet:Boolean = false;
      
      public static var TIME_PER_ITEM:int = 0;
      
      public static var TIME_PER_QTY:int = 0;
      
      private var _complete:Boolean = false;
      
      private var _maxItems:int = -1;
      
      private var _id:String;
      
      private var _timer:TimerData;
      
      private var _outputItems:Vector.<Item>;
      
      private var _itemsToRecycle:Vector.<Item>;
      
      public var completed:Signal;
      
      public function BatchRecycleJob(param1:int = -1)
      {
         super();
         if(!_constantsSet)
         {
            TIME_PER_ITEM = int(Config.constant.BATCH_RECYCLE_TIME_PER_ITEM);
            TIME_PER_QTY = int(Config.constant.BATCH_RECYCLE_TIME_PER_QTY);
            _constantsSet = true;
         }
         this._maxItems = param1;
         this._outputItems = new Vector.<Item>();
         this._itemsToRecycle = new Vector.<Item>();
         this.completed = new Signal(BatchRecycleJob);
      }
      
      public function dispose() : void
      {
         var _loc1_:Item = null;
         if(this._timer != null)
         {
            this._timer.dispose();
            this._timer = null;
         }
         for each(_loc1_ in this._itemsToRecycle)
         {
            _loc1_.dispose();
         }
         for each(_loc1_ in this._outputItems)
         {
            _loc1_.dispose();
         }
         this._outputItems = null;
         this._itemsToRecycle = null;
         this.completed.removeAll();
      }
      
      public function clearItems() : void
      {
         this._itemsToRecycle.length = 0;
         this._outputItems.length = 0;
      }
      
      public function contains(param1:Item) : Boolean
      {
         var _loc2_:Item = null;
         for each(_loc2_ in this._itemsToRecycle)
         {
            if(_loc2_.id.toUpperCase() == param1.id.toUpperCase())
            {
               return true;
            }
         }
         return false;
      }
      
      public function addItem(param1:Item, param2:int = 1) : void
      {
         var _loc5_:Item = null;
         var _loc6_:Item = null;
         if(this.numItemsToRecycle >= this._maxItems || this.contains(param1))
         {
            return;
         }
         param1 = param1.clone();
         param1.quantity = Math.max(1,Math.min(param2,param1.quantity));
         this._itemsToRecycle.push(param1);
         var _loc3_:Vector.<Item> = param1.getRecycleItems();
         var _loc4_:int = 0;
         for(; _loc4_ < _loc3_.length; _loc4_++)
         {
            _loc5_ = _loc3_[_loc4_];
            if(_loc5_ != null)
            {
               if(_loc5_.quantifiable)
               {
                  _loc5_.quantity *= param1.quantity;
                  _loc6_ = this.getRecycleItemByType(_loc5_.type);
                  if(_loc6_ != null && _loc6_ != _loc5_)
                  {
                     _loc6_.quantity += _loc5_.quantity;
                     continue;
                  }
               }
               this._outputItems.push(_loc5_);
            }
         }
      }
      
      public function removeItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Item = null;
         var _loc6_:Item = null;
         var _loc7_:Item = null;
         var _loc8_:int = 0;
         var _loc3_:int = -1;
         _loc2_ = 0;
         while(_loc2_ < this._itemsToRecycle.length)
         {
            if(this._itemsToRecycle[_loc2_].id.toUpperCase() == param1.id.toUpperCase())
            {
               _loc3_ = _loc2_;
               _loc4_ = this._itemsToRecycle[_loc2_];
               break;
            }
            _loc2_++;
         }
         if(_loc3_ == -1)
         {
            return;
         }
         var _loc5_:Vector.<Item> = param1.getRecycleItems();
         _loc2_ = 0;
         while(_loc2_ < _loc5_.length)
         {
            _loc6_ = _loc5_[_loc2_];
            if(_loc6_ != null)
            {
               _loc7_ = this.getRecycleItemByType(_loc6_.type);
               if(_loc7_ != null)
               {
                  if(_loc7_.quantifiable)
                  {
                     _loc7_.quantity -= _loc6_.quantity * _loc4_.quantity;
                  }
                  if(_loc7_.quantity <= 0 || !_loc7_.quantifiable)
                  {
                     _loc8_ = int(this._outputItems.indexOf(_loc7_));
                     if(_loc8_ > -1)
                     {
                        this._outputItems.splice(_loc8_,1);
                     }
                  }
               }
            }
            _loc2_++;
         }
         this._itemsToRecycle.splice(_loc3_,1);
         _loc4_.dispose();
      }
      
      public function getTotalTime() : int
      {
         var _loc2_:Item = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._outputItems)
         {
            _loc1_ += _loc2_.quantity;
         }
         return int(this.numItemsToRecycle * TIME_PER_ITEM + _loc1_ * TIME_PER_QTY);
      }
      
      public function getCost() : int
      {
         if(this.numItemsToRecycle == 0)
         {
            return 0;
         }
         var _loc1_:Object = Network.getInstance().data.costTable.getItemByKey("BatchRecycle");
         var _loc2_:int = int(_loc1_.minCost);
         var _loc3_:int = Math.floor(Number(_loc1_.costPerMin) * (this.getTotalTime() / 60));
         return Math.max(_loc2_,_loc3_);
      }
      
      public function start(param1:Boolean = false, param2:Function = null) : void
      {
         var itemList:Object;
         var i:int;
         var self:BatchRecycleJob = null;
         var network:Network = null;
         var buy:Boolean = param1;
         var onStarted:Function = param2;
         self = this;
         network = Network.getInstance();
         if(buy && network.playerData.compound.resources.getAmount(GameResources.CASH) < this.getCost())
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
            return;
         }
         itemList = {};
         i = 0;
         while(i < this._itemsToRecycle.length)
         {
            itemList[this._itemsToRecycle[i].id.toUpperCase()] = this._itemsToRecycle[i].quantity;
            i++;
         }
         this._outputItems.length = 0;
         this._itemsToRecycle.length = 0;
         network.startAsyncOp();
         network.save({
            "items":itemList,
            "buy":buy
         },SaveDataMethod.ITEM_BATCH_RECYCLE,function(param1:Object):void
         {
            var _loc2_:int = 0;
            var _loc3_:Item = null;
            var _loc4_:Object = null;
            var _loc5_:Object = null;
            network.completeAsyncOp();
            if(param1 == null || param1.success !== true)
            {
               if(onStarted != null)
               {
                  onStarted(false);
               }
               return;
            }
            if(_outputItems == null)
            {
               return;
            }
            if(param1.change != null)
            {
               network.playerData.inventory.updateQuantities(param1.change);
            }
            if(param1.items is Array)
            {
               _loc2_ = 0;
               while(_loc2_ < param1.items.length)
               {
                  _loc4_ = param1.items[_loc2_];
                  if(_loc4_ != null)
                  {
                     _loc3_ = ItemFactory.createItemFromObject(_loc4_);
                     if(_loc3_ != null)
                     {
                        if(param1.buy === true)
                        {
                           network.playerData.giveItem(_loc3_,true);
                        }
                        else
                        {
                           _outputItems.push(_loc3_);
                        }
                     }
                  }
                  _loc2_++;
               }
            }
            if(param1.buy !== true)
            {
               _id = String(param1.id);
               Network.getInstance().playerData.batchRecycleJobs.add(self);
               _loc5_ = param1.timer;
               if(_loc5_ != null)
               {
                  _timer = new TimerData(null,0,self);
                  _timer.completed.addOnce(onCompleted);
                  _timer.readObject(_loc5_);
                  TimerManager.getInstance().addTimer(_timer);
               }
            }
            if(onStarted != null)
            {
               onStarted(true);
            }
         });
      }
      
      public function speedUp(param1:Object, param2:Function = null) : void
      {
         var speedUpCost:int;
         var cash:int;
         var network:Network = null;
         var option:Object = param1;
         var onComplete:Function = param2;
         if(this._timer == null)
         {
            return;
         }
         network = Network.getInstance();
         speedUpCost = network.data.costTable.getCostForTime(option,this._timer.getSecondsRemaining());
         cash = network.playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
            return;
         }
         if(!this._timer.hasEnded() && this._timer.getSecondsRemaining() > 3)
         {
            network.startAsyncOp();
            network.save({
               "id":this._id,
               "option":option.key
            },SaveDataMethod.ITEM_BATCH_RECYCLE_SPEED_UP,function(param1:Object):void
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
               if(_timer != null)
               {
                  _timer.speedUpByPurchaseOption(option);
               }
               Tracking.trackEvent("SpeedUp",option.key,"batchRecycle",int(param1.cost));
               if(onComplete != null)
               {
                  onComplete();
               }
            });
         }
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Item = null;
         var _loc5_:TimerData = null;
         if(param1 == null)
         {
            return;
         }
         this._id = param1.id.toUpperCase();
         this._outputItems.length = 0;
         if(param1.items is Array)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.items.length)
            {
               _loc3_ = param1.items[_loc2_];
               if(_loc3_ != null)
               {
                  _loc4_ = ItemFactory.createItemFromObject(_loc3_);
                  if(_loc4_ != null)
                  {
                     this._outputItems.push(_loc4_);
                  }
               }
               _loc2_++;
            }
         }
         if(param1.start != null)
         {
            _loc5_ = new TimerData(new Date(param1.start),int(param1.length),this);
            if(_loc5_.hasEnded())
            {
               this._complete = true;
               _loc5_.dispose();
               _loc5_ = null;
            }
            else
            {
               this._timer = _loc5_;
               this._timer.completed.addOnce(this.onCompleted);
               TimerManager.getInstance().addTimer(this._timer);
            }
         }
      }
      
      private function getRecycleItemByType(param1:String) : Item
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._outputItems.length)
         {
            if(this._outputItems[_loc2_].type == param1)
            {
               return this._outputItems[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function onCompleted(param1:TimerData) : void
      {
         var _loc3_:Item = null;
         if(this._complete)
         {
            return;
         }
         this._complete = true;
         var _loc2_:int = 0;
         while(_loc2_ < this._outputItems.length)
         {
            _loc3_ = this._outputItems[_loc2_];
            if(_loc3_ != null)
            {
               Network.getInstance().playerData.giveItem(_loc3_);
            }
            _loc2_++;
         }
         NotificationSystem.getInstance().addNotification(NotificationFactory.createNotification(NotificationType.BATCH_RECYCLE_COMPLETE,this._id));
         this.completed.dispatch(this);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get numItemsToRecycle() : int
      {
         var _loc2_:Item = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._itemsToRecycle)
         {
            _loc1_ += _loc2_.quantity < 1 ? 1 : _loc2_.quantity;
         }
         return _loc1_;
      }
      
      public function get maxItems() : int
      {
         return this._maxItems;
      }
      
      public function get isComplete() : Boolean
      {
         return this._complete;
      }
      
      public function get timer() : TimerData
      {
         return this._timer;
      }
      
      public function get items() : Vector.<Item>
      {
         return this._outputItems;
      }
   }
}

