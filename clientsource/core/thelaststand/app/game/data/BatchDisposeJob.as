package thelaststand.app.game.data
{
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   
   public class BatchDisposeJob
   {
      
      private var _maxItems:int = -1;
      
      private var _itemsToDispose:Vector.<Item>;
      
      public function BatchDisposeJob(param1:int = -1)
      {
         super();
         this._maxItems = param1;
         this._itemsToDispose = new Vector.<Item>();
      }
      
      public function dispose() : void
      {
         var _loc1_:Item = null;
         for each(_loc1_ in this._itemsToDispose)
         {
            _loc1_.dispose();
         }
         this._itemsToDispose = null;
      }
      
      public function clearItems() : void
      {
         this._itemsToDispose.length = 0;
      }
      
      public function contains(param1:Item) : Boolean
      {
         var _loc2_:Item = null;
         for each(_loc2_ in this._itemsToDispose)
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
         if(this.numItemsToDispose >= this._maxItems || this.contains(param1))
         {
            return;
         }
         param1 = param1.clone();
         param1.quantity = Math.max(1,Math.min(param2,param1.quantity));
         this._itemsToDispose.push(param1);
      }
      
      public function removeItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Item = null;
         var _loc3_:int = -1;
         _loc2_ = 0;
         while(_loc2_ < this._itemsToDispose.length)
         {
            if(this._itemsToDispose[_loc2_].id.toUpperCase() == param1.id.toUpperCase())
            {
               _loc3_ = _loc2_;
               _loc4_ = this._itemsToDispose[_loc2_];
               break;
            }
            _loc2_++;
         }
         if(_loc3_ == -1)
         {
            return;
         }
         this._itemsToDispose.splice(_loc3_,1);
         _loc4_.dispose();
      }
      
      public function getCost() : int
      {
         if(this.numItemsToDispose == 0)
         {
            return 0;
         }
         var _loc1_:int = this.getTotalItemQuantity();
         var _loc2_:Object = Network.getInstance().data.costTable.getItemByKey("BatchDisposal");
         var _loc3_:int = int(_loc2_.minCost);
         var _loc4_:int = Math.floor(Number(_loc2_.costPerQty * _loc1_));
         return Math.max(_loc3_,_loc4_);
      }
      
      public function start(param1:Function = null) : void
      {
         var itemList:Object;
         var i:int;
         var network:Network = null;
         var onComplete:Function = param1;
         var self:BatchDisposeJob = this;
         network = Network.getInstance();
         if(network.playerData.compound.resources.getAmount(GameResources.CASH) < this.getCost())
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
            return;
         }
         itemList = {};
         i = 0;
         while(i < this._itemsToDispose.length)
         {
            itemList[this._itemsToDispose[i].id.toUpperCase()] = this._itemsToDispose[i].quantity;
            i++;
         }
         this._itemsToDispose.length = 0;
         network.startAsyncOp();
         network.save({"items":itemList},SaveDataMethod.ITEM_BATCH_DISPOSE,function(param1:Object):void
         {
            var _loc2_:int = 0;
            var _loc3_:Item = null;
            var _loc4_:Object = null;
            network.completeAsyncOp();
            if(param1 == null || param1.success !== true)
            {
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            if(param1.change != null)
            {
               network.playerData.inventory.updateQuantities(param1.change);
            }
            if(onComplete != null)
            {
               onComplete(true);
            }
         });
      }
      
      private function getTotalItemQuantity() : int
      {
         var _loc3_:Item = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._itemsToDispose.length)
         {
            _loc3_ = this._itemsToDispose[_loc2_];
            _loc1_ += _loc3_.quantity;
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get numItemsToDispose() : int
      {
         var _loc2_:Item = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._itemsToDispose)
         {
            _loc1_ += _loc2_.quantity < 1 ? 1 : _loc2_.quantity;
         }
         return _loc1_;
      }
      
      public function get maxItems() : int
      {
         return this._maxItems;
      }
      
      public function get items() : Vector.<Item>
      {
         return this._itemsToDispose;
      }
   }
}

