package thelaststand.app.network
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.DatabaseObject;
   import playerio.PlayerIOError;
   import thelaststand.app.game.data.store.StoreCollection;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.data.store.StoreSale;
   import thelaststand.app.utils.DictionaryUtils;
   
   public class StoreManager
   {
      
      private static var _instance:StoreManager;
      
      private var _items:Vector.<StoreItem>;
      
      private var _itemsByKey:Dictionary;
      
      private var _itemsByCategory:Dictionary;
      
      private var _promotedItemKeys:Vector.<String>;
      
      private var _saleItemsByKey:Dictionary;
      
      private var _salesById:Dictionary;
      
      private var _saleIds:Vector.<String>;
      
      private var _collectionsById:Dictionary;
      
      private var _collectionIds:Vector.<String>;
      
      private var _itemsLoaded:Boolean = false;
      
      private var _itemsLoading:Boolean = false;
      
      private var _salesLoaded:Boolean = false;
      
      private var _salesLoading:Boolean = false;
      
      private var _salesCollectionedLoaded:Signal = new Signal();
      
      private var _promoSaleId:String;
      
      public var loadCompleted:Signal = new Signal();
      
      public var loadFailed:Signal = new Signal();
      
      public function StoreManager(param1:StoreManagerSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("StoreManager is a Singleton and cannot be directly instantiated. Use StoreManager.getInstance().");
         }
         this._items = new Vector.<StoreItem>();
         this._itemsByKey = new Dictionary(true);
         this._itemsByCategory = new Dictionary(true);
         this._promotedItemKeys = new Vector.<String>();
         this._saleItemsByKey = new Dictionary(true);
         this._salesById = new Dictionary(true);
         this._saleIds = new Vector.<String>();
         this._collectionsById = new Dictionary(true);
         this._collectionIds = new Vector.<String>();
      }
      
      public static function getInstance() : StoreManager
      {
         if(!_instance)
         {
            _instance = new StoreManager(new StoreManagerSingletonEnforcer());
         }
         return _instance;
      }
      
      public function get loaded() : Boolean
      {
         return this._itemsLoaded;
      }
      
      public function clear() : void
      {
         if(this._itemsLoading)
         {
            return;
         }
         this._itemsLoaded = false;
      }
      
      public function getItem(param1:String, param2:Boolean = false) : StoreItem
      {
         var _loc3_:StoreItem = this._saleItemsByKey[param1];
         var _loc4_:StoreSale = _loc3_ != null ? this.getSale(_loc3_.saleId) : null;
         if(_loc4_ == null || !_loc4_.isActive())
         {
            _loc3_ = null;
         }
         var _loc5_:StoreItem = _loc3_ || StoreItem(this._itemsByKey[param1]);
         if(_loc5_ == null || _loc5_.isCollectionOnly && param2)
         {
            return null;
         }
         return _loc5_;
      }
      
      public function getNumNewItems() : int
      {
         var _loc3_:StoreItem = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._items.length)
         {
            _loc3_ = this._items[_loc2_];
            if(_loc3_ != null)
            {
               if(_loc3_.isNew)
               {
                  _loc1_++;
               }
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getNewItems() : Vector.<StoreItem>
      {
         var _loc3_:StoreItem = null;
         var _loc4_:StoreItem = null;
         var _loc5_:StoreSale = null;
         var _loc1_:Vector.<StoreItem> = new Vector.<StoreItem>();
         var _loc2_:int = 0;
         while(_loc2_ < this._items.length)
         {
            _loc3_ = this._items[_loc2_];
            if(_loc3_ != null)
            {
               if(_loc3_.isNew)
               {
                  _loc4_ = this._saleItemsByKey[_loc3_.key];
                  if(_loc4_ != null)
                  {
                     _loc5_ = this.getSale(_loc4_.saleId);
                     if(_loc5_ != null && _loc5_.isActive())
                     {
                        _loc3_ = _loc4_;
                     }
                  }
                  _loc1_.push(_loc3_);
               }
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getItemsByCategory(param1:String, param2:Boolean = false) : Vector.<StoreItem>
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:StoreItem = null;
         var _loc3_:Vector.<StoreItem> = this._itemsByCategory[param1];
         var _loc4_:Vector.<StoreItem> = new Vector.<StoreItem>();
         if(_loc3_ != null)
         {
            _loc5_ = 0;
            _loc6_ = int(_loc3_.length);
            while(_loc5_ < _loc6_)
            {
               _loc7_ = this.getItem(_loc3_[_loc5_].key,param2);
               if(_loc7_ != null)
               {
                  _loc4_.push(_loc7_);
               }
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      public function getItems(param1:Vector.<String>, param2:Boolean = false) : Vector.<StoreItem>
      {
         var _loc5_:String = null;
         var _loc6_:StoreItem = null;
         var _loc3_:Vector.<StoreItem> = new Vector.<StoreItem>();
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_];
            _loc6_ = this.getItem(_loc5_,param2);
            if(_loc6_ != null)
            {
               _loc3_.push(_loc6_);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function getCollection(param1:String) : StoreCollection
      {
         return this._collectionsById[param1];
      }
      
      public function getCollectionByKey(param1:String) : StoreCollection
      {
         var _loc2_:StoreCollection = null;
         for each(_loc2_ in this._collectionsById)
         {
            if(_loc2_.key == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getCollectionIds() : Vector.<String>
      {
         return this._collectionIds;
      }
      
      public function getSale(param1:String) : StoreSale
      {
         return this._salesById[param1];
      }
      
      public function getSaleIds() : Vector.<String>
      {
         return this._saleIds;
      }
      
      public function getPromoSale() : StoreSale
      {
         return this._salesById[this._promoSaleId];
      }
      
      public function getPromotedItemKeys() : Vector.<String>
      {
         return this._promotedItemKeys.concat();
      }
      
      public function getPromotedItems() : Vector.<StoreItem>
      {
         var _loc3_:StoreItem = null;
         var _loc1_:Vector.<StoreItem> = new Vector.<StoreItem>();
         var _loc2_:int = 0;
         while(_loc2_ < this._promotedItemKeys.length)
         {
            _loc3_ = this.getItem(this._promotedItemKeys[_loc2_]);
            if(_loc3_ != null)
            {
               _loc1_.push(_loc3_);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function getItemsByItemType(param1:String) : Vector.<StoreItem>
      {
         var _loc4_:StoreItem = null;
         var _loc2_:Vector.<StoreItem> = new Vector.<StoreItem>();
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(_loc4_ != null)
            {
               if(_loc4_.item.type == param1)
               {
                  _loc4_ = this.getItem(_loc4_.key);
                  if(_loc4_ != null)
                  {
                     _loc2_.push(_loc4_);
                  }
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getItemsWhere(param1:Function) : Vector.<StoreItem>
      {
         var _loc4_:StoreItem = null;
         var _loc2_:Vector.<StoreItem> = new Vector.<StoreItem>();
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(_loc4_ != null)
            {
               if(param1(_loc4_))
               {
                  _loc4_ = this.getItem(_loc4_.key);
                  _loc2_.push(_loc4_);
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function loadItem(param1:String, param2:Function) : void
      {
         var numCompleted:int;
         var processComplete:Function;
         var numProcesses:int = 0;
         var key:String = param1;
         var completeCallback:Function = param2;
         var item:StoreItem = this.getItem(key);
         if(item != null)
         {
            completeCallback(item);
            return;
         }
         numProcesses = 2;
         numCompleted = 0;
         processComplete = function():void
         {
            if(++numCompleted < numProcesses)
            {
               return;
            }
            completeCallback(getItem(key));
         };
         this._salesCollectionedLoaded.addOnce(processComplete);
         this.loadSalesAndCollections();
         Network.getInstance().client.bigDB.load("PayVaultItems",key,function(param1:DatabaseObject):void
         {
            processItemList([param1]);
            processComplete();
         },function(param1:PlayerIOError):void
         {
            completeCallback(null);
         });
      }
      
      private function loadSalesAndCollections() : void
      {
         var network:Network;
         var numCompleted:int;
         var processComplete:Function;
         var dbSales:Array = null;
         var dbCollections:Array = null;
         var numProcesses:int = 0;
         if(this._salesLoading)
         {
            return;
         }
         if(this._salesLoaded)
         {
            this._salesCollectionedLoaded.dispatch();
            return;
         }
         DictionaryUtils.clear(this._saleItemsByKey);
         this._salesLoading = true;
         network = Network.getInstance();
         this._promoSaleId = network.loginFlags.promoSale;
         numProcesses = 2;
         numCompleted = 0;
         processComplete = function():void
         {
            if(++numCompleted < numProcesses)
            {
               return;
            }
            processSalesList(dbSales);
            processCollectionList(dbCollections);
            _salesLoaded = true;
            _salesLoading = false;
            _salesCollectionedLoaded.dispatch();
         };
         network.client.bigDB.loadRange("PayVaultItems","ByTypeEnabled",["itemcollection",true],null,null,1000,function(param1:Array):void
         {
            dbCollections = param1;
            processComplete();
         },function(param1:PlayerIOError):void
         {
            processComplete();
         });
         network.client.bigDB.loadRange("Store","ByTypeEnabled",["sale",true],null,null,1000,function(param1:Array):void
         {
            dbSales = param1;
            processComplete();
         },function(param1:PlayerIOError):void
         {
            processComplete();
         });
      }
      
      public function loadItemsByType(param1:String, param2:Function) : void
      {
         var network:Network;
         var numCompleted:int;
         var processComplete:Function;
         var dbItems:Array = null;
         var numProcesses:int = 0;
         var itemType:String = param1;
         var completeCallback:Function = param2;
         var list:Vector.<StoreItem> = this.getItemsByItemType(itemType);
         if(this._itemsLoaded || list.length > 0)
         {
            completeCallback(list);
            return;
         }
         network = Network.getInstance();
         numProcesses = 2;
         numCompleted = 0;
         processComplete = function():void
         {
            if(++numCompleted < numProcesses)
            {
               return;
            }
            processItemList(dbItems);
            completeCallback(getItemsByItemType(itemType));
         };
         this._salesCollectionedLoaded.addOnce(processComplete);
         this.loadSalesAndCollections();
         network.client.bigDB.loadRange("PayVaultItems","ByItemKeyEnabled",[itemType,true],null,null,1000,function(param1:Array):void
         {
            dbItems = param1;
            processComplete();
         },function(param1:PlayerIOError):void
         {
            completeCallback(getItemsByItemType(itemType));
         });
      }
      
      public function loadStoreItems() : void
      {
         var network:Network;
         var numCompleted:int;
         var processComplete:Function;
         var dbItems:Array = null;
         var numProcesses:int = 0;
         if(this._itemsLoading)
         {
            return;
         }
         if(this._itemsLoaded)
         {
            this.loadCompleted.dispatch();
            return;
         }
         DictionaryUtils.clear(this._itemsByKey);
         DictionaryUtils.clear(this._itemsByCategory);
         this._items.length = 0;
         this._promotedItemKeys.length = 0;
         this._itemsLoading = true;
         network = Network.getInstance();
         numProcesses = 2;
         numCompleted = 0;
         processComplete = function():void
         {
            if(++numCompleted < numProcesses)
            {
               return;
            }
            processItemList(dbItems);
            _itemsLoaded = true;
            _itemsLoading = false;
            loadCompleted.dispatch();
         };
         this._salesCollectionedLoaded.addOnce(processComplete);
         this.loadSalesAndCollections();
         network.client.bigDB.loadRange("PayVaultItems","ByTypeEnabled",["item",true],null,null,1000,function(param1:Array):void
         {
            dbItems = param1;
            processComplete();
         },this.onItemsLoadFailed);
      }
      
      private function processSalesList(param1:Array) : void
      {
         var _loc4_:DatabaseObject = null;
         var _loc5_:String = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Boolean = Network.getInstance().playerData.isAdmin;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_ != null)
            {
               if(_loc4_.enabled !== false)
               {
                  if(!(_loc4_.admin === true && !_loc2_))
                  {
                     _loc5_ = _loc4_.key.substr(_loc4_.key.indexOf("_") + 1);
                     this._salesById[_loc5_] = new StoreSale(_loc5_,_loc4_);
                     this._saleIds.push(_loc5_);
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function processCollectionList(param1:Array) : void
      {
         var _loc4_:DatabaseObject = null;
         var _loc5_:String = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Boolean = Network.getInstance().playerData.isAdmin;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_ != null)
            {
               if(_loc4_.enabled !== false)
               {
                  if(!(_loc4_.admin === true && !_loc2_))
                  {
                     _loc5_ = _loc4_.key.substr(_loc4_.key.indexOf("_") + 1);
                     this._collectionsById[_loc5_] = new StoreCollection(_loc5_,_loc4_);
                     this._collectionIds.push(_loc5_);
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function processItemList(param1:Array) : void
      {
         var _loc4_:DatabaseObject = null;
         var _loc5_:StoreItem = null;
         var _loc6_:String = null;
         var _loc7_:StoreItem = null;
         var _loc8_:Vector.<StoreItem> = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Boolean = Network.getInstance().playerData.isAdmin;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_ != null)
            {
               if(_loc4_.enabled !== false)
               {
                  if(!(_loc4_.admin === true && !_loc2_))
                  {
                     _loc5_ = new StoreItem(_loc4_);
                     if(_loc5_.item != null)
                     {
                        if(_loc5_.isOnSale)
                        {
                           _loc6_ = _loc5_.key.substr(0,_loc5_.key.lastIndexOf("_"));
                           _loc7_ = this._saleItemsByKey[_loc6_];
                           if(_loc7_ == null || _loc7_.cost >= _loc5_.cost)
                           {
                              this._saleItemsByKey[_loc6_] = _loc5_;
                           }
                        }
                        else
                        {
                           this._itemsByKey[_loc5_.key] = _loc5_;
                           this._items.push(_loc5_);
                           _loc8_ = this._itemsByCategory[_loc5_.item.category];
                           if(_loc8_ == null)
                           {
                              _loc8_ = new Vector.<StoreItem>();
                              this._itemsByCategory[_loc5_.item.category] = _loc8_;
                           }
                           _loc8_.push(_loc5_);
                           if(_loc5_.isPromoted)
                           {
                              this._promotedItemKeys.push(_loc5_.key);
                           }
                        }
                     }
                  }
               }
            }
            _loc3_++;
         }
      }
      
      private function onItemsLoadFailed(param1:PlayerIOError) : void
      {
         this._itemsLoading = false;
         this._itemsLoaded = false;
         this.loadFailed.dispatch();
      }
   }
}

class StoreManagerSingletonEnforcer
{
   
   public function StoreManagerSingletonEnforcer()
   {
      super();
   }
}
