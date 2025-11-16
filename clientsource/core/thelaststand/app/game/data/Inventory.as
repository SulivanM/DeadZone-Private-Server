package thelaststand.app.game.data
{
   import flash.external.ExternalInterface;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.utils.BinaryUtils;
   import thelaststand.common.resources.ResourceManager;
   
   public class Inventory
   {
      
      private var _items:Vector.<Item>;
      
      private var _itemsById:Dictionary;
      
      private var _itemsByType:Dictionary;
      
      private var _itemsByCategory:Dictionary;
      
      private var _schematics:Vector.<Schematic>;
      
      private var _schematicsById:Dictionary;
      
      private var _schematicsByItemType:Dictionary;
      
      private var _schematicsByCategory:Dictionary;
      
      private var _numItemsWarningThreshold:int;
      
      private var _numLimitedSchematics:int;
      
      private var _numUnlockedSchematics:int;
      
      private var _maxItems:int = 500;
      
      public var itemAdded:Signal;
      
      public var itemRemoved:Signal;
      
      public var schematicAdded:Signal;
      
      public var schematicNewFlagsCleared:Signal;
      
      public var limitedSchematicsChanged:Signal;
      
      public function Inventory()
      {
         super();
         this._items = new Vector.<Item>();
         this._itemsById = new Dictionary(true);
         this._itemsByType = new Dictionary(true);
         this._itemsByCategory = new Dictionary(true);
         this._schematics = new Vector.<Schematic>();
         this._schematicsById = new Dictionary(true);
         this._schematicsByItemType = new Dictionary(true);
         this._schematicsByCategory = new Dictionary(true);
         this.maxItems = int(Config.constant.INVENTORY_SIZE_MAX);
         this.itemAdded = new Signal(Item);
         this.itemRemoved = new Signal(Item);
         this.schematicAdded = new Signal(Schematic);
         this.schematicNewFlagsCleared = new Signal();
         this.limitedSchematicsChanged = new Signal();
      }
      
      public function get numItems() : int
      {
         return this._items.length;
      }
      
      public function get maxItems() : int
      {
         return this._maxItems;
      }
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
      }
      
      public function set maxItems(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._maxItems = param1;
         var _loc2_:int = this._maxItems * Number(Config.constant.INVENTORY_SIZE_WARNING_PERC);
         this._numItemsWarningThreshold = Math.round(_loc2_ / 10) * 10;
      }
      
      public function get isFull() : Boolean
      {
         return this._items.length >= this._maxItems;
      }
      
      public function get isNearlyFull() : Boolean
      {
         return this._items.length >= this._numItemsWarningThreshold;
      }
      
      public function get numItemsWarningThreshold() : int
      {
         return this._numItemsWarningThreshold;
      }
      
      public function get numSchematics() : int
      {
         return this._schematics.length;
      }
      
      public function get numUnlockedSchematics() : int
      {
         return this._numUnlockedSchematics;
      }
      
      public function get numLimitedSchematics() : int
      {
         return this._numLimitedSchematics;
      }
      
      public function addItem(param1:Item) : void
      {
         var _loc2_:Vector.<Item> = null;
         var _loc3_:Item = null;
         if(param1 == null)
         {
            return;
         }
         if(this._itemsById[param1.id] != null)
         {
            return;
         }
         if(param1.quantifiable)
         {
            _loc2_ = this._itemsByType[param1.type];
            if(_loc2_ != null && _loc2_.length > 0)
            {
               _loc3_ = _loc2_[0];
               _loc3_.quantity += param1.quantity;
               _loc3_.isNew = _loc3_.isNew || param1.isNew;
               this.itemAdded.dispatch(_loc3_);
               return;
            }
         }
         this.addItemToLookups(param1);
         this.itemAdded.dispatch(param1);
      }
      
      public function addItems(param1:Vector.<Item>) : void
      {
         var _loc2_:Item = null;
         for each(_loc2_ in param1)
         {
            this.addItem(_loc2_);
         }
      }
      
      public function addSchematic(param1:Schematic) : Schematic
      {
         if(Boolean(param1.xml.hasOwnProperty("@visible")) && param1.xml.@visible == "0")
         {
            return null;
         }
         param1 = this.addSchematicToLookups(param1);
         if(param1 == null)
         {
            return null;
         }
         param1.isNew = true;
         this.schematicAdded.dispatch(param1);
         ++this._numUnlockedSchematics;
         return param1;
      }
      
      public function contains(param1:Item) : Boolean
      {
         return this._itemsById[param1.id] == param1;
      }
      
      public function containsType(param1:String) : Boolean
      {
         var _loc2_:Vector.<Item> = this._itemsByType[param1];
         return _loc2_ != null && _loc2_.length > 0;
      }
      
      public function containsTypeQuantity(param1:String, param2:uint) : Boolean
      {
         var _loc7_:Item = null;
         var _loc3_:Vector.<Item> = this._itemsByType[param1];
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return param2 == 0;
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc3_[_loc5_];
            if(_loc7_.quantifiable)
            {
               _loc4_ += _loc3_[_loc5_].quantity;
            }
            else
            {
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc4_ >= param2;
      }
      
      public function containsQuantitiesOfTypes(param1:Dictionary) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:uint = 0;
         for(_loc2_ in param1)
         {
            _loc3_ = uint(param1[_loc2_]);
            if(!this.containsTypeQuantity(_loc2_,_loc3_))
            {
               return false;
            }
         }
         return true;
      }
      
      public function clearSchematicNewFlags() : void
      {
         var _loc1_:Schematic = null;
         for each(_loc1_ in this._schematics)
         {
            _loc1_.isNew = false;
         }
         this.schematicNewFlagsCleared.dispatch();
      }
      
      public function dispose() : void
      {
         var _loc1_:Item = null;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         this._itemsById = null;
         this._itemsByType = null;
         this._itemsByCategory = null;
         this._schematics = null;
         this._schematicsById = null;
         this._schematicsByCategory = null;
         this._schematicsByItemType = null;
      }
      
      public function getAllItems() : Vector.<Item>
      {
         return this._items.concat();
      }
      
      public function getNewItems() : Vector.<Item>
      {
         var _loc4_:Item = null;
         var _loc1_:Vector.<Item> = new Vector.<Item>();
         var _loc2_:int = 0;
         var _loc3_:int = int(this._items.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this._items[_loc2_];
            if(_loc4_.isNew)
            {
               _loc1_.push(_loc4_);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getItem(param1:int) : Item
      {
         return this._items[param1];
      }
      
      public function getItemById(param1:String) : Item
      {
         return this._itemsById[param1.toUpperCase()];
      }
      
      public function getFirstItemOfType(param1:String) : Item
      {
         var _loc2_:Vector.<Item> = this._itemsByType[param1];
         if(_loc2_ == null || _loc2_.length == 0)
         {
            return null;
         }
         return _loc2_[0];
      }
      
      public function getItemsWhere(param1:Function) : Vector.<Item>
      {
         var _loc4_:Item = null;
         var _loc2_:Vector.<Item> = new Vector.<Item>();
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(param1(_loc4_))
            {
               _loc2_.push(_loc4_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getItemsOfCategory(param1:String) : Vector.<Item>
      {
         var _loc2_:Vector.<Item> = this._itemsByCategory[param1];
         return _loc2_ == null ? new Vector.<Item>() : _loc2_.concat();
      }
      
      public function getItemsOfCategoryWhere(param1:String, param2:Function) : Vector.<Item>
      {
         var _loc6_:Item = null;
         var _loc3_:Vector.<Item> = new Vector.<Item>();
         var _loc4_:Vector.<Item> = this._itemsByCategory[param1];
         if(_loc4_ == null)
         {
            return _loc3_;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc6_ = _loc4_[_loc5_];
            if(param2(_loc6_))
            {
               _loc3_.push(_loc6_);
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getItemsOfType(param1:String) : Vector.<Item>
      {
         var _loc2_:Vector.<Item> = this._itemsByType[param1];
         return _loc2_ == null ? new Vector.<Item>() : _loc2_.concat();
      }
      
      public function getItemsOfTypeWhere(param1:String, param2:Function) : Vector.<Item>
      {
         var _loc5_:int = 0;
         var _loc6_:Item = null;
         var _loc3_:Vector.<Item> = new Vector.<Item>();
         var _loc4_:Vector.<Item> = this._itemsByType[param1];
         if(_loc4_ != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               _loc6_ = _loc4_[_loc5_];
               if(param2(_loc6_))
               {
                  _loc3_.push(_loc6_);
               }
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      public function getNumItemsOfCategory(param1:String, param2:Boolean = true) : uint
      {
         var _loc7_:Item = null;
         var _loc3_:Vector.<Item> = this._itemsByCategory[param1];
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return 0;
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc3_[_loc5_];
            if(_loc7_.quantifiable && param2)
            {
               _loc4_ += _loc7_.quantity;
            }
            else
            {
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function getNumItemsOfType(param1:String, param2:Boolean = true) : uint
      {
         var _loc7_:Item = null;
         var _loc3_:Vector.<Item> = this._itemsByType[param1];
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return 0;
         }
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc3_[_loc5_];
            if(_loc7_.quantifiable && param2)
            {
               _loc4_ += _loc7_.quantity;
            }
            else
            {
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      public function getGear(param1:uint = 0) : Vector.<Item>
      {
         var _loc3_:int = 0;
         var _loc4_:Gear = null;
         var _loc2_:Vector.<Item> = this.getItemsOfCategory("gear");
         if(param1 > -1)
         {
            _loc3_ = int(_loc2_.length - 1);
            while(_loc3_ >= 0)
            {
               _loc4_ = Gear(_loc2_[_loc3_]);
               if(!(_loc4_.gearType & param1))
               {
                  _loc2_.splice(_loc3_,1);
               }
               _loc3_--;
            }
         }
         return _loc2_;
      }
      
      public function getSchematicsOfCategory(param1:String = null) : Vector.<Schematic>
      {
         if(param1 == null || param1.toLowerCase() == "all")
         {
            return this._schematics.concat();
         }
         var _loc2_:Vector.<Schematic> = this._schematicsByCategory[param1];
         return _loc2_ == null ? new Vector.<Schematic>() : _loc2_.concat();
      }
      
      public function hasSchematicForItem(param1:String) : Boolean
      {
         var _loc2_:Vector.<Schematic> = this._schematicsByItemType[param1];
         return _loc2_ != null && _loc2_.length > 0;
      }
      
      public function hasOtherSchematicForItem(param1:String, param2:Schematic) : Boolean
      {
         var _loc3_:Vector.<Schematic> = this._schematicsByItemType[param1];
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return false;
         }
         if(_loc3_.length == 1 && _loc3_[0] == param2)
         {
            return false;
         }
         return true;
      }
      
      public function getSchematic(param1:String) : Schematic
      {
         return this._schematicsById[param1];
      }
      
      public function getNumNewSchematics() : int
      {
         var _loc2_:Schematic = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._schematics)
         {
            if(_loc2_.isNew)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function removeItem(param1:Item) : Item
      {
         if(this.removeItemFromLookups(param1))
         {
            this.itemRemoved.dispatch(param1);
         }
         return param1;
      }
      
      public function removeItemById(param1:String) : Item
      {
         var _loc2_:Item = this.getItemById(param1);
         if(_loc2_ != null)
         {
            return this.removeItem(_loc2_);
         }
         return null;
      }
      
      public function removeQuantity(param1:Item, param2:uint) : Item
      {
         param2 = Math.min(param2,param1.quantity);
         param1.quantity -= param2;
         if(param1.quantity <= 0)
         {
            if(this.removeItemFromLookups(param1))
            {
               this.itemRemoved.dispatch(param1);
               param1.dispose();
            }
         }
         return param1;
      }
      
      public function removeQuantityOfType(param1:String, param2:uint) : void
      {
         var _loc4_:int = 0;
         var _loc7_:Item = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:Vector.<Item> = this._itemsByType[param1];
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return;
         }
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc3_.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc3_[_loc5_];
            _loc8_ = int(_loc7_.quantity);
            _loc9_ = _loc8_ - param2;
            if(_loc9_ <= 0)
            {
               if(this.removeItemFromLookups(_loc7_))
               {
                  this.itemRemoved.dispatch(_loc7_);
                  _loc7_.dispose();
               }
            }
            else
            {
               _loc7_.quantity = _loc9_;
            }
            _loc4_ += _loc9_ < 0 ? _loc8_ : param2;
            if(_loc4_ >= param2)
            {
               return;
            }
            _loc5_++;
         }
      }
      
      public function removeQuantityOfTypes(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:uint = 0;
         for(_loc2_ in param1)
         {
            _loc3_ = uint(param1[_loc2_]);
            if(_loc3_ > 0)
            {
               this.removeQuantityOfType(_loc2_,_loc3_);
            }
         }
      }
      
      public function updateQuantities(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Item = null;
         var _loc4_:int = 0;
         if(param1 == null)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = this._itemsById[_loc2_.toUpperCase()];
            if(_loc3_ != null)
            {
               _loc4_ = int(param1[_loc2_]);
               if(_loc4_ <= 0)
               {
                  this.removeItem(_loc3_);
               }
               else
               {
                  _loc3_.quantity = _loc4_;
               }
            }
         }
      }
      
      public function deserialize(param1:Object) : void
      {
         var i:int = 0;
         var len:int = 0;
         var itemData:Object = null;
         var item:Item = null;
         var schemStatus:Vector.<Boolean> = null;
         var schemList:XMLList = null;
         var schemXML:XML = null;
         var schemId:String = null;
         var schem:Schematic = null;
         var input:Object = param1;
         if(input == null)
         {
            return;
         }
         if(input.inventory is Array)
         {
            i = 0;
            len = int(input.inventory.length);
            while(i < len)
            {
               itemData = input.inventory[i];
               if(itemData != null)
               {
                  log("[inventory raw] id=" + itemData.id + ", type=" + itemData.type + ", name=" + itemData.name + ", qty=" + itemData.qty + ", duplicate=" + itemData.duplicate);
                  if(itemData.duplicate !== true)
                  {
                     item = ItemFactory.createItemFromObject(itemData);
                     if(item != null)
                     {
                        log("[inventory created] " + item.toString());
                        this.addItemToLookups(item);
                     }
                     else
                     {
                        log("[inventory] Failed to create item from data: id=" + itemData.id);
                     }
                  }
                  else
                  {
                     log("[inventory] Skipping duplicate item: id=" + itemData.id);
                  }
               }
               i++;
            }
         }
         log("[inventory] Final inventory array length = " + input.inventory.length);
         this._numUnlockedSchematics = 0;
         if(input.schematics is ByteArray)
         {
            schemStatus = BinaryUtils.booleanArrayFromByteArray(input.schematics);
            schemList = ResourceManager.getInstance().getResource("xml/crafting.xml").content.schem;
            i = 0;
            len = Math.min(schemStatus.length,schemList.length());
            for(; i < len; i++)
            {
               if(schemStatus[i] != false)
               {
                  schemXML = schemList[i];
                  if(!(Boolean(schemXML.hasOwnProperty("@levelup")) && schemXML.@levelup == "1"))
                  {
                     if(!(Boolean(schemXML.hasOwnProperty("@visible")) && schemXML.@visible == "0"))
                     {
                        try
                        {
                           schemId = schemList[i].@id.toString();
                           schem = new Schematic(schemId);
                           schem = this.addSchematicToLookups(schem);
                           if(schem != null)
                           {
                              ++this._numUnlockedSchematics;
                           }
                        }
                        catch(e:Error)
                        {
                        }
                        continue;
                     }
                  }
               }
            }
         }
         this.updateLimitedSchematics();
      }
      
      public function updateLimitedSchematics() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:Schematic = null;
         var _loc1_:int = 0;
         var _loc2_:XMLList = ResourceManager.getInstance().getResource("xml/crafting.xml").content.limited.schem;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.@id.toString();
            if(_loc3_.limit != null)
            {
               if(!(Boolean(_loc3_.hasOwnProperty("@visible")) && _loc3_.@visible == "0"))
               {
                  _loc5_ = Schematic.meetsLimitConstraints(_loc4_);
                  _loc6_ = this.getSchematic(_loc4_);
                  if(_loc5_)
                  {
                     if(_loc6_ == null)
                     {
                        _loc6_ = new Schematic(_loc4_);
                        this.addSchematicToLookups(_loc6_);
                        _loc1_++;
                     }
                  }
                  else if(_loc6_ != null)
                  {
                     this.removeSchematicFromLookups(_loc6_);
                  }
               }
            }
         }
         if(_loc1_ != this._numLimitedSchematics)
         {
            this._numLimitedSchematics = _loc1_;
            this.limitedSchematicsChanged.dispatch();
         }
      }
      
      private function addItemToLookups(param1:Item) : void
      {
         this._items.push(param1);
         this._itemsById[param1.id.toUpperCase()] = param1;
         var _loc2_:Vector.<Item> = this._itemsByCategory[param1.category];
         if(_loc2_ == null)
         {
            this._itemsByCategory[param1.category] = new <Item>[param1];
         }
         else
         {
            _loc2_.push(param1);
         }
         var _loc3_:Vector.<Item> = this._itemsByType[param1.type];
         if(_loc3_ == null)
         {
            this._itemsByType[param1.type] = new <Item>[param1];
         }
         else
         {
            _loc3_.push(param1);
         }
      }
      
      private function removeItemFromLookups(param1:Item) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = int(this._items.indexOf(param1));
         if(_loc2_ == -1)
         {
            return false;
         }
         this._items.splice(_loc2_,1);
         delete this._itemsById[param1.id.toUpperCase()];
         var _loc3_:Vector.<Item> = this._itemsByCategory[param1.category];
         if(_loc3_ != null)
         {
            _loc2_ = int(_loc3_.indexOf(param1));
            if(_loc2_ > -1)
            {
               _loc3_.splice(_loc2_,1);
            }
         }
         var _loc4_:Vector.<Item> = this._itemsByType[param1.type];
         if(_loc4_ != null)
         {
            _loc2_ = int(_loc4_.indexOf(param1));
            if(_loc2_ > -1)
            {
               _loc4_.splice(_loc2_,1);
            }
         }
         return true;
      }
      
      private function addSchematicToLookups(param1:Schematic) : Schematic
      {
         var _loc2_:Schematic = this._schematicsById[param1];
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         if(param1.outputItem == null)
         {
            return null;
         }
         this._schematics.push(param1);
         this._schematicsById[param1.id] = param1;
         var _loc3_:Vector.<Schematic> = this._schematicsByCategory[param1.category];
         if(_loc3_ == null)
         {
            this._schematicsByCategory[param1.category] = new <Schematic>[param1];
         }
         else
         {
            _loc3_.push(param1);
         }
         var _loc4_:Vector.<Schematic> = this._schematicsByItemType[param1.outputItem.type];
         if(_loc4_ == null)
         {
            this._schematicsByItemType[param1.outputItem.type] = new <Schematic>[param1];
         }
         else
         {
            _loc4_.push(param1);
         }
         return param1;
      }
      
      private function removeSchematicFromLookups(param1:Schematic) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = int(this._schematics.indexOf(param1));
         if(_loc2_ == -1)
         {
            return false;
         }
         this._schematics.splice(_loc2_,1);
         delete this._schematicsById[param1.id];
         var _loc3_:Vector.<Schematic> = this._schematicsByCategory[param1.outputItem.category];
         if(_loc3_ != null)
         {
            _loc2_ = int(_loc3_.indexOf(param1));
            if(_loc2_ > -1)
            {
               _loc3_.splice(_loc2_,1);
            }
         }
         var _loc4_:Vector.<Schematic> = this._schematicsByItemType[param1.outputItem.type];
         if(_loc4_ != null)
         {
            _loc2_ = int(_loc4_.indexOf(param1));
            if(_loc2_ > -1)
            {
               _loc4_.splice(_loc2_,1);
            }
         }
         return true;
      }
   }
}

