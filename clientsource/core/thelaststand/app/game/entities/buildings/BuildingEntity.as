package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.primitives.Box;
   import alternativa.engine3d.utils.Object3DUtils;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.AssignmentPosition;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.CoverEntity;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.gui.UIAssignmentPosition;
   import thelaststand.app.game.entities.gui.UIRangeIndicator;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.map.CellMap;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.objects.ICellFootprint;
   import thelaststand.engine.utils.BoundingBoxUtils;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class BuildingEntity extends CoverEntity implements ICellFootprint
   {
      
      private static var _materialsSet:Boolean;
      
      private static var _tmpRect1:Rectangle = new Rectangle();
      
      private static var _tmpRect2:Rectangle = new Rectangle();
      
      public static const MAT_FOOTPRINT_BUFFER:TextureMaterial = new TextureMaterial();
      
      public static const MAT_FOOTPRINT_LEGAL:TextureMaterial = new TextureMaterial();
      
      public static const MAT_FOOTPRINT_ILLEGAL:TextureMaterial = new TextureMaterial();
      
      public static const MAX_BOUND_HEIGHT:int = 250;
      
      private var _assetMatrix:Matrix3D;
      
      private var _assetURI:String;
      
      private var _assetDamagedURI:String;
      
      private var _alpha:Number = 1;
      
      private var _bufferMin:Point;
      
      private var _bufferMax:Point;
      
      private var _size:Rectangle;
      
      private var _footprintValid:Boolean = true;
      
      private var _footprintVisible:Boolean;
      
      private var _rotation:int;
      
      private var _meshLoaded:Boolean;
      
      private var _tweenDummy:Object;
      
      private var _loader:AssetLoader;
      
      private var _assignPositionMarkers:Vector.<UIAssignmentPosition>;
      
      private var _centerPoint:Vector3D;
      
      private var _showAssignFlags:Boolean = true;
      
      private var _showingAssignPositions:Boolean = false;
      
      private var _showDecoyMarker:Boolean = false;
      
      public var mesh_hitArea:Box;
      
      protected var mesh_building:MeshGroup;
      
      protected var mesh_damaged:MeshGroup;
      
      protected var mesh_footprint:BuildingFootprint;
      
      protected var ui_range:UIRangeIndicator;
      
      public var buildingData:Building;
      
      public var onScavengedCooldownReset:Signal;
      
      public var onScavenged:Signal;
      
      public function BuildingEntity()
      {
         var _loc1_:ResourceManager = null;
         this._size = new Rectangle();
         this._tweenDummy = {"rotationZ":0};
         this._centerPoint = new Vector3D();
         super();
         this.onScavengedCooldownReset = new Signal();
         this.onScavenged = new Signal();
         passable = false;
         losVisible = false;
         flags |= GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP | GameEntityFlags.FORCE_UNPASSABLE;
         this.asset = new Object3D();
         asset.mouseEnabled = false;
         asset.boundBox = new BoundBox();
         this.mesh_hitArea = Primitives.BOX.clone() as Box;
         this.mesh_hitArea.name = "meshHitArea";
         this.mesh_hitArea.mouseEnabled = true;
         this.mesh_hitArea.mouseChildren = false;
         addedToScene.add(this.onAddedToScene);
         removedFromScene.add(this.onRemovedFromScene);
         if(!_materialsSet)
         {
            _materialsSet = false;
            _loc1_ = ResourceManager.getInstance();
            MAT_FOOTPRINT_BUFFER.diffuseMap = _loc1_.materials.getBitmapTextureResource("images/ui/tile-blueprint-blue-feet.jpg");
            MAT_FOOTPRINT_LEGAL.diffuseMap = _loc1_.materials.getBitmapTextureResource("images/ui/tile-blueprint-blue.jpg");
            MAT_FOOTPRINT_ILLEGAL.diffuseMap = _loc1_.materials.getBitmapTextureResource("images/ui/tile-blueprint-red.jpg");
         }
         Settings.getInstance().settingChanged.add(this.onSettingChanged);
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIAssignmentPosition = null;
         Settings.getInstance().settingChanged.remove(this.onSettingChanged);
         this.onScavenged.removeAll();
         this.onScavengedCooldownReset.removeAll();
         if(scene != null)
         {
            if(this.mesh_building != null)
            {
               scene.removeShadowCaster(this.mesh_building);
            }
            if(this.mesh_damaged != null)
            {
               scene.removeShadowCaster(this.mesh_damaged);
            }
         }
         super.dispose();
         addedToScene.remove(this.onAddedToScene);
         removedFromScene.remove(this.onRemovedFromScene);
         this.buildingData = null;
         if(this.mesh_hitArea.parent != null)
         {
            this.mesh_hitArea.parent.removeChild(this.mesh_hitArea);
         }
         this.mesh_hitArea = null;
         TweenMaxDelta.killTweensOf(this._tweenDummy);
         this._assetMatrix = null;
         this._bufferMax = this._bufferMax = null;
         this._size = null;
         if(this._assignPositionMarkers != null)
         {
            for each(_loc1_ in this._assignPositionMarkers)
            {
               _loc1_.dispose();
            }
            this._assignPositionMarkers = null;
         }
         if(this.mesh_footprint != null)
         {
            this.mesh_footprint.dispose();
            this.mesh_footprint = null;
         }
         if(this._loader != null)
         {
            this._loader.dispose();
         }
      }
      
      public function getFootprintRect(param1:int, param2:int, param3:Rectangle = null) : Rectangle
      {
         param3 ||= new Rectangle();
         switch(this._rotation)
         {
            case 0:
               param3.left = param1 - (this._size.width - 1);
               param3.right = param1;
               param3.top = param2 - (this._size.height - 1);
               param3.bottom = param2;
               break;
            case 1:
               param3.left = param1 - (this._size.height - 1);
               param3.right = param1;
               param3.top = param2;
               param3.bottom = param2 + (this._size.width - 1);
               break;
            case 2:
               param3.left = param1;
               param3.right = param1 + (this._size.width - 1);
               param3.top = param2;
               param3.bottom = param2 + (this._size.height - 1);
               break;
            case 3:
               param3.left = param1;
               param3.right = param1 + (this._size.height - 1);
               param3.top = param2 - (this._size.width - 1);
               param3.bottom = param2;
         }
         return param3;
      }
      
      public function getFootprintBufferRect(param1:int, param2:int, param3:Rectangle = null) : Rectangle
      {
         param3 = this.getFootprintRect(param1,param2,param3);
         if(this._bufferMin == null || this._bufferMax == null)
         {
            return param3;
         }
         var _loc4_:int = Math.min(this._bufferMin.x,0);
         var _loc5_:int = Math.min(this._bufferMin.y,0);
         var _loc6_:int = Math.max(this._bufferMax.x,0);
         var _loc7_:int = Math.max(this._bufferMax.y,0);
         switch(this._rotation)
         {
            case 0:
            case 2:
               param3.left += _loc4_;
               param3.right += _loc6_;
               param3.top += _loc5_;
               param3.bottom += _loc7_;
               break;
            case 1:
            case 3:
               param3.left += _loc5_;
               param3.right += _loc7_;
               param3.top += _loc4_;
               param3.bottom += _loc6_;
         }
         return param3;
      }
      
      public function getBufferCells(param1:Vector.<Cell> = null) : Vector.<Cell>
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Cell = null;
         var _loc5_:Rectangle = null;
         var _loc6_:Rectangle = null;
         var _loc7_:Cell = null;
         param1 ||= new Vector.<Cell>();
         param1.length = 0;
         if(scene != null)
         {
            _loc4_ = scene.map.getCellAtCoords(transform.position.x,transform.position.y);
            _loc5_ = this.getFootprintRect(_loc4_.x,_loc4_.y,_tmpRect1);
            _loc6_ = this.getFootprintBufferRect(_loc4_.x,_loc4_.y,_tmpRect2);
            _loc2_ = _loc6_.left;
            while(_loc2_ <= _loc6_.right)
            {
               _loc3_ = _loc6_.top;
               while(_loc3_ <= _loc6_.bottom)
               {
                  if(!((_loc2_ <= _loc6_.left || _loc2_ >= _loc6_.right) && (_loc3_ <= _loc6_.top || _loc3_ >= _loc6_.bottom)))
                  {
                     if(!(_loc2_ >= _loc5_.left && _loc2_ <= _loc5_.right && _loc3_ >= _loc5_.top && _loc3_ <= _loc5_.bottom))
                     {
                        _loc7_ = scene.map.cellMap.getCell(_loc2_,_loc3_);
                        if(_loc7_ != null)
                        {
                           param1.push(_loc7_);
                        }
                     }
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
         }
         return param1;
      }
      
      override public function getCoverTiles() : Vector.<Cell>
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Cell = null;
         if(!(flags & GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP))
         {
            return super.getCoverTiles();
         }
         if(scene == null || this.buildingData.coverRating == 0)
         {
            return new Vector.<Cell>();
         }
         var _loc1_:Vector.<Cell> = new Vector.<Cell>();
         var _loc2_:CellMap = scene.map.cellMap;
         var _loc3_:Rectangle = this.getFootprintRect(this.buildingData.tileX,this.buildingData.tileY,_tmpRect1);
         var _loc4_:int = _loc3_.left - 1;
         var _loc5_:int = _loc3_.right + 1;
         var _loc6_:int = _loc3_.top - 1;
         var _loc7_:int = _loc3_.bottom + 1;
         if(Boolean(this.buildingData.doorPosition) && this.buildingData.assignable)
         {
            _loc8_ = _loc4_;
            while(_loc8_ <= _loc5_)
            {
               _loc9_ = _loc6_;
               while(_loc9_ <= _loc7_)
               {
                  _loc10_ = _loc2_.getCell(_loc8_,_loc9_);
                  if(_loc10_ != null)
                  {
                     _loc1_.push(_loc10_);
                  }
                  _loc9_++;
               }
               _loc8_++;
            }
         }
         else
         {
            _loc8_ = _loc4_;
            while(_loc8_ <= _loc5_)
            {
               _loc10_ = _loc2_.getCell(_loc8_,_loc6_);
               if(_loc10_ != null)
               {
                  _loc1_.push(_loc10_);
               }
               _loc10_ = _loc2_.getCell(_loc8_,_loc7_);
               if(_loc10_ != null)
               {
                  _loc1_.push(_loc10_);
               }
               _loc8_++;
            }
            _loc8_ = _loc6_ + 1;
            while(_loc8_ <= _loc7_ - 1)
            {
               _loc10_ = _loc2_.getCell(_loc4_,_loc8_);
               if(_loc10_ != null)
               {
                  _loc1_.push(_loc10_);
               }
               _loc10_ = _loc2_.getCell(_loc5_,_loc8_);
               if(_loc10_ != null)
               {
                  _loc1_.push(_loc10_);
               }
               _loc8_++;
            }
         }
         return _loc1_;
      }
      
      public function getDoorTile() : Cell
      {
         var _loc1_:Point = this.buildingData.doorPosition;
         if(scene == null || _loc1_ == null)
         {
            return null;
         }
         return this.getRelativeTile(_loc1_.x,_loc1_.y);
      }
      
      public function getAssignPositions() : Vector.<AssignmentPosition>
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Cell = null;
         var _loc6_:Number = NaN;
         var _loc7_:Boolean = false;
         var _loc8_:AssignmentPosition = null;
         var _loc1_:Vector.<AssignmentPosition> = new Vector.<AssignmentPosition>();
         if(scene != null && this.buildingData.assignable)
         {
            for each(_loc2_ in this.buildingData.xml.assign)
            {
               _loc3_ = int(_loc2_.@x.toString());
               _loc4_ = int(_loc2_.@y.toString());
               _loc5_ = this.getRelativeTile(_loc3_,_loc4_);
               _loc6_ = _loc2_.hasOwnProperty("@height") ? Number(_loc2_.@height.toString()) : 0;
               _loc7_ = _loc2_.hasOwnProperty("@lock") ? Boolean(_loc2_.@lock == "1") : false;
               _loc8_ = new AssignmentPosition(_loc5_,_loc6_,_loc7_);
               _loc1_.push(_loc8_);
            }
         }
         return _loc1_;
      }
      
      private function getRelativeTile(param1:int, param2:int) : Cell
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(scene == null)
         {
            return null;
         }
         switch(this._rotation)
         {
            case 0:
               _loc3_ = this.buildingData.tileX + param1;
               _loc4_ = this.buildingData.tileY - param2;
               break;
            case 1:
               _loc3_ = this.buildingData.tileX - param2;
               _loc4_ = this.buildingData.tileY - param1;
               break;
            case 2:
               _loc3_ = this.buildingData.tileX - param1;
               _loc4_ = this.buildingData.tileY + param2;
               break;
            case 3:
               _loc3_ = this.buildingData.tileX + param2;
               _loc4_ = this.buildingData.tileY + param1;
         }
         return scene.map.cellMap.getCell(_loc3_,_loc4_);
      }
      
      public function getRandomBufferTile() : Cell
      {
         var _loc7_:int = 0;
         if(scene == null)
         {
            return null;
         }
         var _loc1_:CellMap = scene.map.cellMap;
         var _loc2_:Cell = scene.map.getCellAtCoords(transform.position.x,transform.position.y);
         var _loc3_:Rectangle = this.getFootprintRect(_loc2_.x,_loc2_.y,_tmpRect1);
         var _loc4_:Rectangle = this.getFootprintBufferRect(_loc2_.x,_loc2_.y,_tmpRect2);
         var _loc5_:Vector.<Cell> = new Vector.<Cell>();
         var _loc6_:int = _loc4_.left;
         while(_loc6_ <= _loc4_.right)
         {
            _loc7_ = _loc4_.top;
            while(_loc7_ <= _loc4_.bottom)
            {
               if(!_loc3_.contains(_loc6_,_loc7_))
               {
                  _loc2_ = _loc1_.getCell(_loc6_,_loc7_);
                  if(_loc2_ != null)
                  {
                     _loc5_.push(_loc2_);
                  }
               }
               _loc7_++;
            }
            _loc6_++;
         }
         return _loc5_.length > 0 ? _loc5_[int(Math.random() * _loc5_.length)] : null;
      }
      
      public function getTileCoords() : Vector.<Point>
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:Vector.<Point> = new Vector.<Point>();
         var _loc2_:Cell = scene.map.getCellAtCoords(transform.position.x,transform.position.y);
         var _loc3_:Rectangle = this.getFootprintRect(_loc2_.x,_loc2_.y,_tmpRect1);
         var _loc4_:Rectangle = this.getFootprintBufferRect(_loc2_.x,_loc2_.y,_tmpRect2);
         _loc5_ = _loc4_.left;
         while(_loc5_ <= _loc4_.right)
         {
            _loc6_ = _loc4_.top;
            while(_loc6_ <= _loc4_.bottom)
            {
               if(!((_loc5_ <= _loc4_.left || _loc5_ >= _loc4_.right) && (_loc6_ <= _loc4_.top || _loc6_ >= _loc4_.bottom)))
               {
                  _loc1_.push(new Point(_loc5_,_loc6_));
               }
               _loc6_++;
            }
            _loc5_++;
         }
         return _loc1_;
      }
      
      public function isCurrentPositionValid() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:* = false;
         var _loc3_:Cell = scene.map.getCellAtCoords(transform.position.x,transform.position.y);
         if(!this.isCellPlaceable(_loc3_,false))
         {
            return false;
         }
         var _loc4_:Rectangle = this.getFootprintRect(_loc3_.x,_loc3_.y,_tmpRect1);
         var _loc5_:Rectangle = this.getFootprintBufferRect(_loc3_.x,_loc3_.y,_tmpRect2);
         var _loc6_:int = _loc5_.width - _loc4_.width;
         var _loc7_:int = _loc5_.height - _loc4_.height;
         _loc1_ = _loc5_.left;
         while(_loc1_ <= _loc5_.right)
         {
            _loc2_ = _loc5_.top;
            while(_loc2_ <= _loc5_.bottom)
            {
               if(!((_loc1_ <= _loc5_.left || _loc1_ >= _loc5_.right) && (_loc2_ <= _loc5_.top || _loc2_ >= _loc5_.bottom)))
               {
                  _loc8_ = !(_loc1_ >= _loc4_.left && _loc1_ <= _loc4_.right && _loc2_ >= _loc4_.top && _loc2_ <= _loc4_.bottom);
                  if(!this.isCellPlaceable(scene.map.cellMap.getCell(_loc1_,_loc2_),_loc8_))
                  {
                     return false;
                  }
               }
               _loc2_++;
            }
            _loc1_++;
         }
         return true;
      }
      
      public function setMesh(param1:String, param2:String = null) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this._assetURI = param1;
         this._assetDamagedURI = param2;
         this._meshLoaded = false;
         if(this.mesh_building != null)
         {
            if(scene != null)
            {
               scene.removeShadowCaster(this.mesh_building);
            }
            if(this.mesh_building.parent != null)
            {
               this.mesh_building.parent.removeChild(this.mesh_building);
            }
         }
         if(this.mesh_damaged != null)
         {
            if(scene != null)
            {
               scene.removeShadowCaster(this.mesh_damaged);
            }
            if(this.mesh_damaged.parent != null)
            {
               this.mesh_damaged.parent.removeChild(this.mesh_damaged);
            }
         }
         var _loc3_:int = 100;
         if(flags & GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP)
         {
            _loc4_ = this._size.width * _loc3_;
            _loc5_ = this._size.height * _loc3_;
            if(this.mesh_footprint != null)
            {
               asset.addChild(this.mesh_footprint);
            }
         }
         else
         {
            _loc4_ = _loc3_;
            _loc5_ = _loc3_;
         }
         this.mesh_hitArea.scaleX = _loc4_ * 0.75;
         this.mesh_hitArea.scaleY = _loc5_ * 0.75;
         this.mesh_hitArea.scaleZ = MAX_BOUND_HEIGHT;
         this.mesh_hitArea.x = -_loc4_ * 0.5 + _loc3_ * 0.5;
         this.mesh_hitArea.y = _loc5_ * 0.5 - _loc3_ * 0.5;
         this.mesh_hitArea.z = this.mesh_hitArea.scaleZ * 0.5;
         this.mesh_hitArea.calculateBoundBox();
         this.mesh_hitArea.visible = true;
         asset.addChild(this.mesh_hitArea);
         _coverArea = this.mesh_hitArea;
         asset.boundBox = this.mesh_hitArea.boundBox;
         assetInvalidated.dispatch(this);
         if(this._loader == null)
         {
            this._loader = new AssetLoader();
         }
         else
         {
            this._loader.clear();
         }
         this.updateCenterPoint();
         this._loader.loadingCompleted.addOnce(this.onMeshReady);
         this._loader.loadAsset(this._assetURI);
         if(this._assetDamagedURI != null)
         {
            this._loader.loadAsset(this._assetDamagedURI);
         }
      }
      
      public function setFootprint(param1:int, param2:int, param3:Boolean = true) : void
      {
         this._size.x = this._size.y = 0;
         this._size.width = param1;
         this._size.height = param2;
         var _loc5_:int;
         var _loc6_:int = _loc5_ = param3 ? 1 : 0;
         if(param3 && (this.buildingData.connectable || this.buildingData.isDoor))
         {
            _loc6_ = -_loc6_;
            this._bufferMin = new Point(-_loc5_,-_loc6_);
            this._bufferMax = new Point(_loc5_,_loc6_);
         }
         else
         {
            this._bufferMin = new Point(-_loc5_,-_loc6_);
            this._bufferMax = new Point(_loc5_,_loc6_);
         }
         if(this.mesh_footprint != null)
         {
            this.mesh_footprint.dispose();
            this.mesh_footprint = null;
         }
         this.mesh_footprint = new BuildingFootprint(param1,param2,_loc5_,_loc6_);
         if(this._footprintVisible)
         {
            asset.addChild(this.mesh_footprint);
         }
      }
      
      public function setOpacity(param1:Number) : void
      {
         var _loc4_:Mesh = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:StandardMaterial = null;
         var _loc8_:Boolean = false;
         this._alpha = param1;
         if(this.mesh_building == null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = this.mesh_building.numChildren;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this.mesh_building.getChildAt(_loc2_) as Mesh;
            if(_loc4_ != null)
            {
               _loc5_ = 0;
               _loc6_ = _loc4_.numSurfaces;
               while(_loc5_ < _loc6_)
               {
                  _loc7_ = _loc4_.getSurface(_loc5_).material as StandardMaterial;
                  if(_loc7_ != null)
                  {
                     _loc8_ = _loc7_.opacityMap != null || this._alpha < 1;
                     _loc7_.alpha = this._alpha;
                     _loc7_.alphaThreshold = _loc8_ ? 1 : 0;
                     _loc7_.transparentPass = _loc8_;
                     _loc7_.opaquePass = true;
                  }
                  _loc5_++;
               }
            }
            _loc2_++;
         }
      }
      
      public function hideAssignPositions() : void
      {
         var _loc2_:UIAssignmentPosition = null;
         if(this._assignPositionMarkers == null)
         {
            return;
         }
         this._showingAssignPositions = false;
         var _loc1_:int = 0;
         while(_loc1_ < this._assignPositionMarkers.length)
         {
            _loc2_ = this._assignPositionMarkers[_loc1_];
            if(_loc2_.parent != null)
            {
               asset.removeChild(_loc2_);
            }
            _loc1_++;
         }
         this.updateRangeDisplay();
         this.buildingData.assignmentChanged.remove(this.onBuildingAssignmentChanged);
      }
      
      public function showAssignPosition(param1:int = -1) : void
      {
         var _loc2_:int = 0;
         var _loc4_:UIAssignmentPosition = null;
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(scene == null || !this.buildingData.assignable)
         {
            return;
         }
         var _loc3_:XMLList = this.buildingData.xml.assign;
         this._showingAssignPositions = true;
         if(this._assignPositionMarkers == null)
         {
            this._assignPositionMarkers = new Vector.<UIAssignmentPosition>(_loc3_.length(),true);
            for each(_loc5_ in _loc3_)
            {
               _loc6_ = int(_loc5_.@x.toString());
               _loc7_ = int(_loc5_.@y.toString());
               _loc4_ = new UIAssignmentPosition();
               _loc4_.x = _loc6_ * scene.map.cellSize;
               _loc4_.y = _loc7_ * scene.map.cellSize;
               _loc4_.z = _loc5_.hasOwnProperty("@height") ? Number(_loc5_.@height.toString()) : 0;
               var _loc10_:*;
               this._assignPositionMarkers[_loc10_ = _loc2_++] = _loc4_;
            }
         }
         _loc2_ = 0;
         while(_loc2_ < this._assignPositionMarkers.length)
         {
            _loc4_ = this._assignPositionMarkers[_loc2_];
            if(param1 == -1 || _loc2_ == param1)
            {
               _loc4_.showArrow = param1 != -1;
               _loc4_.assigned = this.buildingData.assignedSurvivors[_loc2_] != null;
               asset.addChild(_loc4_);
            }
            else if(_loc4_.parent != null)
            {
               asset.removeChild(_loc4_);
            }
            _loc2_++;
         }
         if(this.ui_range == null)
         {
            this.ui_range = new UIRangeIndicator(0);
            this.ui_range.entity = this;
         }
         this.updateRangeDisplay();
         this.buildingData.assignmentChanged.add(this.onBuildingAssignmentChanged);
         assetInvalidated.dispatch(this);
      }
      
      public function showAssignFlags(param1:Boolean = true) : void
      {
         var _loc2_:Object3D = null;
         this._showAssignFlags = param1;
         if(this.mesh_building != null)
         {
            _loc2_ = this.mesh_building.getChildByName("flag");
            if(_loc2_ != null)
            {
               _loc2_.visible = param1 && this.buildingData.numAssignedSurvivors > 0;
            }
         }
      }
      
      public function showDecoyMarker(param1:Boolean) : void
      {
         var _loc2_:Object3D = null;
         this._showDecoyMarker = param1;
         if(this.mesh_building != null)
         {
            _loc2_ = this.mesh_building.getChildByName("decoy");
            if(_loc2_ != null)
            {
               _loc2_.visible = param1;
            }
         }
         if(this.mesh_damaged != null)
         {
            _loc2_ = this.mesh_damaged.getChildByName("decoy");
            if(_loc2_ != null)
            {
               _loc2_.visible = param1;
            }
         }
      }
      
      public function showDamaged(param1:Boolean) : void
      {
         if(this.mesh_damaged != null)
         {
            asset.visible = true;
            this.mesh_damaged.visible = param1;
            if(this.mesh_building != null)
            {
               this.mesh_building.visible = !param1;
            }
         }
         else if(this.mesh_building != null)
         {
            asset.visible = true;
            this.mesh_building.visible = true;
         }
         else
         {
            asset.visible = false;
         }
      }
      
      public function updateRangeDisplay() : void
      {
         if(this.ui_range == null || this.buildingData == null)
         {
            return;
         }
         if(!this._showingAssignPositions)
         {
            if(scene != null)
            {
               scene.removeEntity(this.ui_range);
            }
            return;
         }
         var _loc1_:Object = this.buildingData.getAttackRanges();
         this.ui_range.minEffectiveRange = _loc1_.minEffective;
         this.ui_range.minRange = _loc1_.min;
         this.ui_range.range = _loc1_.max;
         if(this.ui_range.range > 300)
         {
            if(scene != null && this.ui_range.scene == null)
            {
               scene.addEntity(this.ui_range);
               this.ui_range.assetInvalidated.dispatch(this.ui_range);
               this.ui_range.transitionIn();
            }
         }
         else if(scene != null)
         {
            scene.removeEntity(this.ui_range);
         }
         this.ui_range.updatePosition(1,true);
      }
      
      private function isCellPlaceable(param1:Cell, param2:Boolean) : Boolean
      {
         var _loc4_:GameEntity = null;
         if(param1 == null || param1.baseCost == 0)
         {
            return false;
         }
         if(!param2 && param1.bufferCount > 0)
         {
            return false;
         }
         var _loc3_:Vector.<GameEntity> = scene.map.getEntitiesOccupyingCell(param1);
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_ != this)
            {
               if(_loc4_ is BuildingEntity && !(_loc4_.flags & EntityFlags.REMOVABLE_JUNK))
               {
                  return false;
               }
               if(!(_loc4_.flags & EntityFlags.REMOVABLE_JUNK))
               {
               }
               if(!_loc4_.passable && param1.baseCost >= 0)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function updateCenterPoint() : void
      {
         var _loc1_:BoundBox = null;
         if(asset == null || scene == null)
         {
            return;
         }
         _loc1_ = BoundingBoxUtils.transformBounds(asset,asset.matrix,_loc1_);
         var _loc2_:Number = _loc1_.maxX - _loc1_.minX;
         var _loc3_:Number = _loc1_.maxY - _loc1_.minY;
         var _loc4_:Number = _loc1_.maxZ - _loc1_.minZ;
         this._centerPoint.x = _loc1_.minX + _loc2_ * 0.5;
         this._centerPoint.y = _loc1_.minY + _loc3_ * 0.5;
         this._centerPoint.z = _loc1_.minZ + _loc4_ * 0.5;
      }
      
      private function updateFootprintDisplay(param1:Boolean) : void
      {
         if(this.mesh_footprint == null)
         {
            return;
         }
         this._footprintValid = param1;
         this.mesh_footprint.valid = this._footprintValid;
         if(scene != null)
         {
            assetInvalidated.dispatch(this);
         }
      }
      
      override protected function updateCoverArea(param1:CoverEntity) : void
      {
      }
      
      private function onBuildingAssignmentChanged(param1:Building, param2:Survivor, param3:int) : void
      {
         this._assignPositionMarkers[param3].assigned = param2 != null;
         this.showAssignFlags(this._showAssignFlags);
         assetInvalidated.dispatch(this);
      }
      
      protected function onMeshReady() : void
      {
         var _loc5_:Object3D = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(asset == null)
         {
            return;
         }
         this._meshLoaded = true;
         if(this._assetURI != null)
         {
            this.mesh_building = new MeshGroup();
            this.mesh_building.addChildrenFromResource(this._assetURI);
            this.mesh_building.mouseEnabled = this.mesh_building.mouseChildren = false;
            this.mesh_building.name = "meshEntity";
            asset.addChild(this.mesh_building);
            _loc5_ = this.mesh_building.getChildByName("decoy");
            if(_loc5_ != null)
            {
               _loc5_.visible = this._showDecoyMarker;
            }
         }
         if(this._assetDamagedURI != null)
         {
            this.mesh_damaged = new MeshGroup();
            this.mesh_damaged.addChildrenFromResource(this._assetDamagedURI);
            this.mesh_damaged.mouseEnabled = this.mesh_damaged.mouseChildren = false;
            this.mesh_damaged.name = "meshEntityDamaged";
            this.mesh_damaged.visible = false;
            asset.addChild(this.mesh_damaged);
            _loc5_ = this.mesh_damaged.getChildByName("decoy");
            if(_loc5_ != null)
            {
               _loc5_.visible = this._showDecoyMarker;
            }
         }
         if(this.buildingData != null && this.buildingData.health <= 0 && this.buildingData.maxHealth > 0 && this._assetDamagedURI != null)
         {
            if(this.mesh_building != null)
            {
               this.mesh_building.visible = false;
            }
            if(this.mesh_damaged != null)
            {
               this.mesh_damaged.visible = true;
            }
         }
         if(this.mesh_building != null)
         {
            this.mesh_building.boundBox = new BoundBox();
            Object3DUtils.calculateHierarchyBoundBox(this.mesh_building,this.mesh_building,this.mesh_building.boundBox);
         }
         else
         {
            asset.boundBox = new BoundBox();
            Object3DUtils.calculateHierarchyBoundBox(asset,asset,asset.boundBox);
         }
         var _loc1_:BoundBox = this.mesh_building != null ? this.mesh_building.boundBox : asset.boundBox;
         var _loc2_:int = Math.min(_loc1_.maxZ - _loc1_.minZ,MAX_BOUND_HEIGHT);
         if(!(flags & GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP))
         {
            _loc6_ = _loc1_.maxX - _loc1_.minX;
            _loc7_ = _loc1_.maxY - _loc1_.minY;
            this.mesh_hitArea.scaleX = _loc6_ * 0.75;
            this.mesh_hitArea.scaleY = _loc7_ * 0.75;
            this.mesh_hitArea.x = _loc1_.minX + _loc6_ * 0.5;
            this.mesh_hitArea.y = _loc1_.minY + _loc7_ * 0.5;
            _loc2_ *= 0.75;
         }
         this.mesh_hitArea.scaleZ = _loc2_;
         this.mesh_hitArea.z = _loc1_.minZ + _loc2_ * 0.5;
         this.mesh_hitArea.calculateBoundBox();
         _coverArea = this.mesh_hitArea;
         if(!this._footprintVisible)
         {
            if(this.mesh_footprint != null && this.mesh_footprint.parent != null)
            {
               this.mesh_footprint.parent.removeChild(this.mesh_footprint);
            }
         }
         if(scene != null)
         {
            if(this.mesh_building != null)
            {
               scene.addShadowCaster(this.mesh_building);
            }
            if(this.mesh_damaged != null)
            {
               scene.addShadowCaster(this.mesh_damaged);
            }
         }
         if(this.mesh_building != null)
         {
            asset.boundBox = this.mesh_building.boundBox;
         }
         var _loc3_:int = 0;
         var _loc4_:int = int(actions.length);
         while(_loc3_ < _loc4_)
         {
            actions[_loc3_].run(this,1);
            _loc3_++;
         }
         updateTransform();
         this.updateCenterPoint();
         this.showAssignFlags(this._showAssignFlags);
         asset.visible = true;
         assetInvalidated.dispatch(this);
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         if(this.mesh_building != null)
         {
            scene.addShadowCaster(this.mesh_building);
         }
         if(this.mesh_damaged != null)
         {
            scene.addShadowCaster(this.mesh_damaged);
         }
         this.buildingData.soundSource.position = transform.position;
         scene.addEntity(this.buildingData.soundSource);
      }
      
      private function onRemovedFromScene(param1:GameEntity) : void
      {
         if(this.mesh_building != null)
         {
            scene.removeShadowCaster(this.mesh_building);
         }
         if(this.mesh_damaged != null)
         {
            scene.removeShadowCaster(this.mesh_damaged);
         }
         if(this.buildingData.soundSource != null)
         {
            this.buildingData.soundSource.position = null;
            scene.removeEntity(this.buildingData.soundSource);
         }
      }
      
      private function onSettingChanged(param1:String, param2:Object) : void
      {
         var _loc3_:Light3D = null;
         if(param1 == "dynamicLights")
         {
            if(this.mesh_building == null)
            {
               return;
            }
            for each(_loc3_ in this.mesh_building.lights)
            {
               _loc3_.visible = param2 === true;
            }
         }
      }
      
      override public function set asset(param1:Object3D) : void
      {
         super.asset = param1;
         super.updateCoverArea(this);
      }
      
      public function get centerPoint() : Vector3D
      {
         return this._centerPoint;
      }
      
      public function get footprintValid() : Boolean
      {
         return this._footprintValid;
      }
      
      public function set footprintValid(param1:Boolean) : void
      {
         if(this._footprintValid == param1)
         {
            return;
         }
         this.updateFootprintDisplay(param1);
      }
      
      public function get footprintVisible() : Boolean
      {
         return this._footprintVisible;
      }
      
      public function set footprintVisible(param1:Boolean) : void
      {
         this._footprintVisible = param1;
         if(this._footprintVisible)
         {
            this._footprintVisible = true;
            if(this.mesh_footprint != null)
            {
               asset.addChild(this.mesh_footprint);
               this.updateFootprintDisplay(this._footprintValid);
            }
         }
         else if(this._meshLoaded)
         {
            if(asset != null && this.mesh_footprint != null && this.mesh_footprint.parent != null)
            {
               this.mesh_footprint.parent.removeChild(this.mesh_footprint);
            }
         }
      }
      
      public function get meshLoaded() : Boolean
      {
         return this._meshLoaded;
      }
      
      public function get buildingMesh() : MeshGroup
      {
         return this.mesh_building;
      }
      
      public function get rotation() : int
      {
         return this._rotation;
      }
      
      public function set rotation(param1:int) : void
      {
         var r:Number;
         var value:int = param1;
         if(value < 0)
         {
            value += 4;
         }
         else if(value > 3)
         {
            value -= 4;
         }
         this._rotation = value;
         if(this._footprintVisible)
         {
            this.isCurrentPositionValid();
         }
         r = this._rotation * 90;
         if(!Global.softwareRendering && asset != null && asset.visible && scene != null)
         {
            TweenMaxDelta.to(this._tweenDummy,0.15,{
               "shortRotation":{"rotationZ":r},
               "onUpdate":function():void
               {
                  if(!asset)
                  {
                     return;
                  }
                  transform.setRotationEuler(0,0,_tweenDummy.rotationZ * Math.PI / 180);
                  updateTransform();
               },
               "onComplete":function():void
               {
                  updateCenterPoint();
               }
            });
         }
         else if(asset)
         {
            this._tweenDummy.rotationZ = r;
            transform.setRotationEuler(0,0,this._tweenDummy.rotationZ * Math.PI / 180);
            updateTransform();
            this.updateCenterPoint();
         }
      }
   }
}

