package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.ResourceManager;
   
   public class BuildingCollection
   {
      
      private var _compound:CompoundData;
      
      private var _buildings:Vector.<Building>;
      
      private var _buildingsById:Dictionary;
      
      public var buildingAdded:Signal;
      
      public var buildingRemoved:Signal;
      
      public function BuildingCollection(param1:CompoundData)
      {
         super();
         this._compound = param1;
         this._buildings = new Vector.<Building>();
         this._buildingsById = new Dictionary(true);
         this.buildingAdded = new Signal(Building);
         this.buildingRemoved = new Signal(Building);
      }
      
      public function addBuilding(param1:Building) : Building
      {
         if(this._buildings.indexOf(param1) > -1)
         {
            return null;
         }
         this._buildings.push(param1);
         this._buildingsById[param1.id.toUpperCase()] = param1;
         this.buildingAdded.dispatch(param1);
         return param1;
      }
      
      public function containsBuilding(param1:Building) : Boolean
      {
         return this._buildings.indexOf(param1) > -1;
      }
      
      public function dispose() : void
      {
         this.buildingAdded.removeAll();
         this.buildingRemoved.removeAll();
         this._buildings = null;
         this._buildingsById = null;
         this._compound = null;
      }
      
      public function getBuilding(param1:uint) : Building
      {
         if(param1 >= this._buildings.length)
         {
            return null;
         }
         return this._buildings[param1];
      }
      
      public function getBuildingById(param1:String) : Building
      {
         return this._buildingsById[param1.toUpperCase()];
      }
      
      public function getBuildingsOfType(param1:String, param2:Boolean = true) : Vector.<Building>
      {
         var _loc4_:Building = null;
         var _loc3_:Vector.<Building> = new Vector.<Building>();
         for each(_loc4_ in this._buildings)
         {
            if(_loc4_.type.toLowerCase() == param1.toLowerCase())
            {
               if(!(!param2 && _loc4_.isUnderConstruction()))
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         return _loc3_;
      }
      
      public function getFirstBuildingOfType(param1:String, param2:Boolean = true) : Building
      {
         var _loc3_:Vector.<Building> = this.getBuildingsOfType(param1,param2);
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return null;
         }
         return _loc3_[0];
      }
      
      public function getBuildingsBeingUpgraded() : Vector.<Building>
      {
         var _loc2_:Building = null;
         var _loc1_:Vector.<Building> = new Vector.<Building>();
         for each(_loc2_ in this._buildings)
         {
            if(_loc2_.upgradeTimer != null)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function getNumBuildingsOfType(param1:String, param2:Boolean = true) : int
      {
         var _loc4_:Building = null;
         var _loc3_:int = 0;
         for each(_loc4_ in this._buildings)
         {
            if(_loc4_.type.toLowerCase() == param1.toLowerCase())
            {
               if(!(!param2 && _loc4_.isUnderConstruction()))
               {
                  _loc3_++;
               }
            }
         }
         return _loc3_;
      }
      
      public function getNumTraps(param1:Boolean = true) : int
      {
         var _loc3_:Building = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this._buildings)
         {
            if(_loc3_.isTrap)
            {
               if(!(!param1 && _loc3_.isUnderConstruction()))
               {
                  _loc2_++;
               }
            }
         }
         return _loc2_;
      }
      
      public function getHighestLevelOfType(param1:String) : int
      {
         var _loc3_:Building = null;
         var _loc2_:int = -1;
         for each(_loc3_ in this._buildings)
         {
            if(_loc3_.type == param1 && _loc3_.level > _loc2_ && !_loc3_.isUnderConstruction())
            {
               _loc2_ = _loc3_.level;
            }
         }
         return _loc2_;
      }
      
      public function getHighestLevelBuilding(param1:String) : Building
      {
         var _loc3_:Building = null;
         var _loc4_:Building = null;
         var _loc2_:int = -1;
         for each(_loc4_ in this._buildings)
         {
            if(_loc4_.type == param1 && _loc4_.level > _loc2_ && !_loc4_.isUnderConstruction())
            {
               _loc2_ = _loc4_.level;
               _loc3_ = _loc4_;
            }
         }
         return _loc3_;
      }
      
      public function getNumCraftingBuildings(param1:String = null) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Building = null;
         for each(_loc3_ in this._buildings)
         {
            if(param1 == null || _loc3_.canCraft(param1))
            {
               if(_loc3_.craftingCategories.length > 0 && !_loc3_.isUnderConstruction())
               {
                  _loc2_++;
               }
            }
         }
         return _loc2_;
      }
      
      public function hasBuilding(param1:String, param2:int, param3:int = 1, param4:Boolean = true) : Boolean
      {
         var _loc6_:Building = null;
         var _loc5_:int = 0;
         for each(_loc6_ in this._buildings)
         {
            if(_loc6_.type == param1 && _loc6_.level >= param2)
            {
               if(!(param4 && _loc6_.upgradeTimer != null && _loc6_.upgradeTimer.data.level <= param2))
               {
                  if(_loc5_++ >= param3)
                  {
                     return true;
                  }
               }
            }
         }
         return _loc5_ >= param3;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         var _loc2_:Building = null;
         if(!param1)
         {
            param1 = [];
         }
         for each(_loc2_ in this._buildings)
         {
            param1.push(_loc2_.writeObject());
         }
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var xml:XML;
         var i:int = 0;
         var len:int = 0;
         var node:XML = null;
         var bld:Building = null;
         var input:Object = param1;
         this._buildings.length = 0;
         if(!(input is Array))
         {
            return;
         }
         xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content;
         if(xml != null)
         {
            i = 0;
            len = int(input.length);
            while(i < len)
            {
               if(input[i] != null)
               {
                  node = xml.item.(@id == input[i].type)[0];
                  if(node != null)
                  {
                     bld = node.@type == "junk" ? new JunkBuilding() : new Building();
                     bld.readObject(input[i]);
                     this._buildings.push(bld);
                  }
               }
               i++;
            }
         }
         this.buildIdLookup();
      }
      
      public function removeBuilding(param1:Building) : Building
      {
         var _loc2_:int = int(this._buildings.indexOf(param1));
         if(_loc2_ == -1)
         {
            return null;
         }
         this._buildings.splice(_loc2_,1);
         this._buildingsById[param1.id.toUpperCase()] = null;
         delete this._buildingsById[param1.id.toUpperCase()];
         this.buildingRemoved.dispatch(param1);
         return param1;
      }
      
      public function removeAt(param1:int) : Building
      {
         if(param1 < 0 || param1 >= this._buildings.length)
         {
            return null;
         }
         var _loc2_:Building = this._buildings[param1];
         this._buildings.splice(param1,1);
         delete this._buildingsById[_loc2_.id.toUpperCase()];
         this.buildingRemoved.dispatch(_loc2_);
         return _loc2_;
      }
      
      public function removeAll() : void
      {
         var _loc1_:Building = null;
         for each(_loc1_ in this._buildings)
         {
            this._buildingsById[_loc1_.id.toUpperCase()] = null;
            delete this._buildingsById[_loc1_.id.toUpperCase()];
         }
         this._buildings.length = 0;
      }
      
      private function buildIdLookup() : void
      {
         var _loc1_:Building = null;
         this._buildingsById = new Dictionary(true);
         for each(_loc1_ in this._buildings)
         {
            this._buildingsById[_loc1_.id.toUpperCase()] = _loc1_;
         }
      }
      
      public function get compound() : CompoundData
      {
         return this._compound;
      }
      
      public function get numBuildings() : int
      {
         return this._buildings != null ? int(this._buildings.length) : 0;
      }
   }
}

