package thelaststand.app.game.scenes
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.primitives.Box;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.CoverData;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.entities.effects.BloodSplatDecal;
   import thelaststand.app.game.entities.light.SunLight;
   import thelaststand.app.game.logic.ai.NoiseSource;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.scenes.Scene;
   import thelaststand.engine.utils.BoundingBoxUtils;
   
   public class BaseScene extends Scene
   {
      
      private var _lightScene:SunLight;
      
      private var _itemsXMLBySearchableEntity:Dictionary;
      
      private var _noiseSources:Vector.<NoiseSource>;
      
      private var _noiseSourcesById:Dictionary;
      
      protected var _totalSearchableEntities:int;
      
      protected var _coverTable:Dictionary;
      
      protected var _noiseVolumeMultiplier:Number = 1;
      
      protected var _visibilityRating:Number = 1;
      
      public var spawnPointsPlayer:Vector.<Vector3D>;
      
      public var spawnPointsHuman:Vector.<HumanSpawnPoint>;
      
      public var spawnPointsStatic:Vector.<Vector3D>;
      
      public var spawnPointsPortals:Vector.<Vector3D>;
      
      public var searchableEntities:Vector.<GameEntity>;
      
      private var _buildings:Vector.<Building> = new Vector.<Building>();
      
      public function BaseScene()
      {
         super();
         this._itemsXMLBySearchableEntity = new Dictionary(true);
         this._noiseSources = new Vector.<NoiseSource>();
         this._noiseSourcesById = new Dictionary(true);
         this.spawnPointsPlayer = new Vector.<Vector3D>();
         this.spawnPointsHuman = new Vector.<HumanSpawnPoint>();
         this.spawnPointsStatic = new Vector.<Vector3D>();
         this.spawnPointsPortals = new Vector.<Vector3D>();
         this.searchableEntities = new Vector.<GameEntity>();
         Settings.getInstance().settingChanged.add(this.onSettingChanged);
      }
      
      override public function dispose() : void
      {
         var _loc1_:Object = null;
         var _loc2_:CoverData = null;
         Settings.getInstance().settingChanged.remove(this.onSettingChanged);
         BloodSplatDecal.disposeAll();
         if(this._lightScene != null)
         {
            this._lightScene.dispose();
            this._lightScene = null;
         }
         for(_loc1_ in this._itemsXMLBySearchableEntity)
         {
            this._itemsXMLBySearchableEntity[_loc1_] = null;
            delete this._itemsXMLBySearchableEntity[_loc1_];
         }
         this._noiseSources = null;
         this._noiseSourcesById = null;
         this._itemsXMLBySearchableEntity = null;
         this.searchableEntities = null;
         this.spawnPointsPlayer = null;
         this.spawnPointsHuman = null;
         this.spawnPointsStatic = null;
         this.spawnPointsPortals = null;
         super.dispose();
         for each(_loc2_ in this._coverTable)
         {
            _loc2_.dispose();
         }
         this._coverTable = null;
      }
      
      override public function populateFromDescriptor(param1:XML, param2:Number = NaN, param3:Boolean = true) : void
      {
         var searchEnts:XMLList;
         var n:XML = null;
         var bld:Building = null;
         var name:String = null;
         var ent:GameEntity = null;
         var bounds:BoundBox = null;
         var target:Object3D = null;
         var itemList:XMLList = null;
         var meshHitArea:Box = null;
         var sPt:HumanSpawnPoint = null;
         var bldId:String = null;
         var xml:XML = param1;
         var seed:Number = param2;
         var updateMap:Boolean = param3;
         super.populateFromDescriptor(xml,seed,updateMap);
         for each(n in _xmlDescriptor.player.spawn)
         {
            this.spawnPointsPlayer.push(new Vector3D(Number(n.@x.toString()),Number(n.@y.toString()),0,-Number(n.@r.toString()) * Math.PI / 180));
         }
         for each(n in _xmlDescriptor.zombies.spawn)
         {
            this.spawnPointsStatic.push(new Vector3D(Number(n.@x.toString()),Number(n.@y.toString()),0));
         }
         for each(n in _xmlDescriptor.zombie_portals.spawn)
         {
            this.spawnPointsPortals.push(new Vector3D(Number(n.@x.toString()),Number(n.@y.toString()),0,-Number(n.@r.toString()) * Math.PI / 180));
         }
         if(true)
         {
            for each(n in _xmlDescriptor.traps.spawn)
            {
               bld = this.createTrap(n);
               if(bld != null)
               {
                  bld.entity.transform.setPosition(Number(n.@x.toString()),Number(n.@y.toString()),Number(n.@z.toString()));
                  bld.entity.transform.setRotationEuler(0,-Number(n.@r.toString()),0,true);
                  this._buildings.push(bld);
               }
            }
         }
         if(true)
         {
            for each(n in _xmlDescriptor.ent.e.(hasOwnProperty("building")))
            {
               name = n.@name.toString();
               ent = getEntityByName(name);
               if(ent != null)
               {
                  removeEntity(ent);
                  ent.dispose();
               }
               bld = this.createBuilding(n);
               if(bld != null)
               {
                  bld.entity.name = name;
                  addEntity(bld.entity);
                  this._buildings.push(bld);
                  if(bld.forceScavengable)
                  {
                     this.searchableEntities.push(bld.entity);
                  }
               }
            }
         }
         searchEnts = _xmlDescriptor.ent.e.(hasOwnProperty("itms"));
         bounds = new BoundBox();
         for each(n in searchEnts)
         {
            name = n.@name.toString();
            ent = getEntityByName(name);
            if(ent != null)
            {
               target = ent.asset.getChildByName("meshEntity");
               if(target != null)
               {
                  itemList = n.itms.itm;
                  this.searchableEntities.push(ent);
                  this._itemsXMLBySearchableEntity[ent] = itemList;
                  BoundingBoxUtils.transformBounds(target,target.matrix,bounds);
                  meshHitArea = Primitives.BOX.clone() as Box;
                  meshHitArea.name = "meshHitArea";
                  meshHitArea.mouseEnabled = true;
                  meshHitArea.scaleX = bounds.maxX - bounds.minX;
                  meshHitArea.scaleY = bounds.maxY - bounds.minY;
                  meshHitArea.scaleZ = bounds.maxZ - bounds.minZ;
                  meshHitArea.x = bounds.minX + meshHitArea.scaleX * 0.5;
                  meshHitArea.y = bounds.minY + meshHitArea.scaleY * 0.5;
                  meshHitArea.z = bounds.minZ + meshHitArea.scaleZ * 0.5;
                  ent.asset.addChild(meshHitArea);
                  if(itemList.length() <= 0)
                  {
                     ent.flags |= EntityFlags.EMPTY_CONTAINER;
                  }
               }
            }
         }
         for each(n in _xmlDescriptor.human.spawn)
         {
            sPt = new HumanSpawnPoint();
            sPt.position = new Vector3D(Number(n.@x.toString()),Number(n.@y.toString()),Number(n.@z.toString()),-Number(n.@r.toString()) * Math.PI / 180);
            sPt.xml = n;
            bldId = String(n.building);
            if(bldId != null)
            {
               sPt.building = getEntityByName(bldId) as BuildingEntity;
            }
            this.spawnPointsHuman.push(sPt);
         }
         if(this._lightScene != null)
         {
            this._lightScene.timeChanged.add(this.onTimeChanged);
            this.onTimeChanged(this._lightScene.time);
         }
         this._totalSearchableEntities = this.searchableEntities.length;
      }
      
      public function getCoverCellsInList(param1:Vector.<Cell>) : Vector.<Cell>
      {
         var _loc3_:Cell = null;
         var _loc2_:Vector.<Cell> = new Vector.<Cell>();
         for each(_loc3_ in param1)
         {
            if(this._coverTable[_loc3_] != null)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getClosestCoverFromList(param1:Cell, param2:Vector.<Cell>) : Cell
      {
         var _loc5_:Cell = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc3_:Cell = null;
         var _loc4_:Number = Number.MAX_VALUE;
         for each(_loc5_ in param2)
         {
            _loc6_ = _loc5_.x - param1.x;
            _loc7_ = _loc5_.y - param1.y;
            _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
            if(_loc8_ <= _loc4_)
            {
               _loc4_ = _loc8_;
               _loc3_ = _loc5_;
            }
         }
         return _loc3_;
      }
      
      public function getCover(param1:Cell) : CoverData
      {
         return this._coverTable[param1];
      }
      
      public function getClosestCover(param1:Cell) : CoverData
      {
         var _loc4_:GameEntity = null;
         var _loc5_:Cell = null;
         var _loc2_:CoverData = this._coverTable[param1];
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         var _loc3_:BuildingEntity = null;
         for each(_loc4_ in _map.getEntitiesOccupyingCell(param1))
         {
            if(_loc4_ is CoverEntity)
            {
               _loc5_ = _map.getClosestCellFromListToPoint(CoverEntity(_loc4_).getCoverTiles(),_map.getCellCoords(param1.x,param1.y));
               if(!(_loc5_ != null && !_map.isPassableCell(_loc5_)))
               {
                  _loc2_ = this.getCoverData(_loc5_);
                  if(_loc2_ != null)
                  {
                     return _loc2_;
                  }
               }
            }
         }
         return null;
      }
      
      public function getItemXMLListInSearchableEntity(param1:GameEntity) : XMLList
      {
         return this._itemsXMLBySearchableEntity[param1];
      }
      
      public function emptySearchableEntity(param1:GameEntity) : void
      {
         var _loc2_:int = int(this.searchableEntities.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this.searchableEntities.splice(_loc2_,1);
         this._itemsXMLBySearchableEntity[param1] = null;
         delete this._itemsXMLBySearchableEntity[param1];
      }
      
      override public function update(param1:Number) : void
      {
         var _loc3_:NoiseSource = null;
         super.update(param1);
         var _loc2_:int = int(this._noiseSources.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._noiseSources[_loc2_];
            _loc3_.update(param1);
            if(_loc3_.volume <= 0)
            {
               this._noiseSources.splice(_loc2_,1);
               delete this._noiseSourcesById[_loc3_.id];
            }
            _loc2_--;
         }
      }
      
      public function addNoiseSource(param1:NoiseSource) : void
      {
         var _loc3_:int = 0;
         var _loc2_:NoiseSource = this._noiseSourcesById[param1.id];
         if(_loc2_ == param1)
         {
            return;
         }
         if(_loc2_ != null)
         {
            _loc3_ = int(this._noiseSources.indexOf(_loc2_));
            if(_loc3_ > -1)
            {
               this._noiseSources.splice(_loc3_,1);
            }
            delete this._noiseSourcesById[_loc2_.id];
         }
         this._noiseSourcesById[param1.id] = param1;
         this._noiseSources.push(param1);
      }
      
      public function removeNoiseSource(param1:NoiseSource) : void
      {
         var _loc2_:int = int(this._noiseSources.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._noiseSources.splice(_loc2_,1);
         }
         if(this._noiseSourcesById[param1.id] == param1)
         {
            delete this._noiseSourcesById[param1.id];
         }
      }
      
      public function getCoverData(param1:Cell) : CoverData
      {
         return this._coverTable != null ? this._coverTable[param1] : null;
      }
      
      public function buildCoverTable() : void
      {
         var _loc2_:CoverEntity = null;
         var _loc3_:int = 0;
         var _loc4_:Cell = null;
         var _loc5_:CoverData = null;
         this._coverTable = new Dictionary(true);
         var _loc1_:GameEntity = entityListHead;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_ as CoverEntity;
            if(_loc2_ != null)
            {
               _loc3_ = _loc2_.coverRating;
               if(_loc3_ > 0)
               {
                  for each(_loc4_ in _loc2_.getCoverTiles())
                  {
                     _loc5_ = this._coverTable[_loc4_];
                     if(_loc5_ == null)
                     {
                        _loc5_ = this._coverTable[_loc4_] = new CoverData(_loc4_);
                     }
                     _loc5_.entities.push(_loc2_);
                  }
               }
            }
            _loc1_ = _loc1_.next;
         }
         for each(_loc5_ in this._coverTable)
         {
            _loc5_.calculateRating();
         }
      }
      
      protected function addSceneLight(param1:Class = null) : SunLight
      {
         if(this._lightScene != null)
         {
            return this._lightScene;
         }
         if(param1 == null)
         {
            param1 = SunLight;
         }
         this._lightScene = new param1();
         SunLight(this._lightScene).shadow = shadow;
         addEntity(this._lightScene);
         return this._lightScene;
      }
      
      protected function createTrap(param1:XML) : Building
      {
         var _loc2_:String = String(param1.type);
         var _loc3_:XML = Building.getBuildingXML(_loc2_);
         if(_loc3_ == null)
         {
            return null;
         }
         var _loc4_:Building = new Building(_loc3_,0);
         addTriggers(param1,_loc4_.entity);
         return _loc4_;
      }
      
      protected function createBuilding(param1:XML) : Building
      {
         var _loc2_:String = String(param1.building);
         var _loc3_:int = int(param1.building.@level);
         var _loc4_:XML = Building.getBuildingXML(_loc2_);
         if(_loc4_ == null)
         {
            return null;
         }
         var _loc5_:Vector3D = new Vector3D(Number(param1.@x.toString()),Number(param1.@y.toString()),Number(param1.@z.toString()));
         var _loc6_:Number = param1.hasOwnProperty("rx") ? Number(param1.rx.split(" ")[0]) : 0;
         var _loc7_:Number = param1.hasOwnProperty("ry") ? Number(param1.ry.split(" ")[0]) : 0;
         var _loc8_:Number = param1.hasOwnProperty("rz") ? Number(param1.rz.split(" ")[0]) : 0;
         var _loc9_:int = Math.abs(int(_loc8_ / 360 * 4));
         var _loc10_:Building = new Building(_loc4_,_loc3_,true);
         var _loc11_:Cell = map.getCellAtCoords(_loc5_.x,_loc5_.y);
         _loc10_.tileX = _loc11_.x;
         _loc10_.tileY = _loc11_.y;
         map.getCellCoords(_loc10_.tileX,_loc10_.tileY,_loc5_);
         _loc10_.entity.transform.setPosition(_loc5_.x,_loc5_.y,_loc5_.z);
         _loc10_.entity.transform.setRotationEuler(_loc6_,_loc7_,_loc8_,true);
         _loc10_.rotation = _loc9_;
         _loc10_.buildingEntity.updateTransform();
         _loc10_.buildingEntity.updateCenterPoint();
         addProperties(param1,_loc10_.entity);
         addTriggers(param1,_loc10_.entity);
         return _loc10_;
      }
      
      override protected function createEntity(param1:XML) : GameEntity
      {
         var _loc2_:Building = null;
         var _loc3_:BuildingEntity = null;
         var _loc4_:CoverEntity = null;
         if(Boolean(param1.hasOwnProperty("health")) && !param1.hasOwnProperty("building"))
         {
            _loc2_ = new Building(null,0,true);
            _loc2_.setLevel(1);
            _loc2_.maxLevel = 1;
            _loc2_.maxHealth = Number(param1.health);
            _loc2_.destroyable = true;
            _loc3_ = new BuildingEntity();
            _loc3_.coverRating = int(param1.cover);
            _loc3_.flags &= ~GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP;
            _loc3_.buildingData = _loc2_;
            _loc2_.buildingEntity = _loc3_;
            _loc2_.entity = _loc3_;
            this._buildings.push(_loc2_);
            addProperties(param1,_loc3_);
            addTriggers(param1,_loc3_);
            return _loc3_;
         }
         if(param1.hasOwnProperty("cover"))
         {
            _loc4_ = new CoverEntity();
            _loc4_.coverRating = int(param1.cover);
            addProperties(param1,_loc4_);
            addTriggers(param1,_loc4_);
            return _loc4_;
         }
         return super.createEntity(param1);
      }
      
      private function onTimeChanged(param1:int) : void
      {
         var _loc4_:Light3D = null;
         if(_sceneModel == null)
         {
            return;
         }
         var _loc2_:Boolean = this._lightScene.time > 1780 || this._lightScene.time < 600;
         var _loc3_:Boolean = Settings.getInstance().dynamicLights;
         for each(_loc4_ in _sceneModel.nightLights)
         {
            _loc4_.visible = _loc3_ && _loc2_;
         }
         this._visibilityRating = Math.max(0.2,this._lightScene.intensity);
      }
      
      private function onSettingChanged(param1:String, param2:Object) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Light3D = null;
         if(param1 == "dynamicLights")
         {
            _loc3_ = Settings.getInstance().dynamicLights;
            for each(_loc4_ in _sceneModel.lights)
            {
               _loc4_.visible = _loc3_;
            }
            if(this._lightScene != null)
            {
               this.onTimeChanged(this._lightScene.time);
            }
         }
      }
      
      public function get noiseSources() : Vector.<NoiseSource>
      {
         return this._noiseSources;
      }
      
      public function get noiseVolumeMultiplier() : Number
      {
         return this._noiseVolumeMultiplier;
      }
      
      public function set noiseVolumeMultiplier(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._noiseVolumeMultiplier = param1;
      }
      
      public function get visibilityRating() : Number
      {
         return this._visibilityRating;
      }
      
      public function get totalSearchableEntities() : int
      {
         return this._totalSearchableEntities;
      }
      
      public function get buildings() : Vector.<Building>
      {
         return this._buildings;
      }
   }
}

