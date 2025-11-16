package thelaststand.engine.map
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.utils.Object3DUtils;
   import com.deadreckoned.threshold.data.Graph;
   import com.deadreckoned.threshold.ns.threshold;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.utils.DictionaryUtils;
   import thelaststand.engine.ns.tls;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.objects.ICellFootprint;
   
   use namespace threshold;
   
   public class Map
   {
      
      private var _connectionDirs:Array = [1,0,0,1];
      
      private var _connectionDirsLen:int = this._connectionDirs.length;
      
      private var _position:Point = new Point();
      
      private var _size:Point = new Point();
      
      private var _cellMap:CellMap;
      
      private var _cellSize:int = 100;
      
      private var _navGraph:Graph;
      
      private var _navCells:Vector.<NavCell>;
      
      private var _navCellsWidth:int = 0;
      
      private var _navCellsHeight:int = 0;
      
      private var _pathfinder:Pathfinder;
      
      private var _navCellSize:int = 0;
      
      private var _cellsByEntity:Dictionary;
      
      private var _entitiesByCell:Dictionary;
      
      private var _pathfinderOptions:PathfinderOptions = new PathfinderOptions();
      
      private var _tmpCellList:Vector.<Cell> = new Vector.<Cell>();
      
      private var _tmpNavCellList:Vector.<NavCell> = new Vector.<NavCell>();
      
      private var _tmpVector1:Vector3D = new Vector3D();
      
      private var _tmpVector2:Vector3D = new Vector3D();
      
      private var _tmpRect:Rectangle = new Rectangle();
      
      private var _tmpBounds:BoundBox = new BoundBox();
      
      private var _tmpEntList:Vector.<GameEntity>;
      
      private var _tmpCost:int = 0;
      
      private var _tmpCellA:Cell = new Cell(-1,-1);
      
      private var _tmpCellB:Cell = new Cell(-1,-1);
      
      public var changed:Signal = new Signal();
      
      private var _nextTraversalAreaId:int = 1;
      
      private var _traversalAreasById:Dictionary = new Dictionary(true);
      
      public function Map()
      {
         super();
         this._cellMap = new CellMap();
         this._navGraph = new Graph();
         this._cellsByEntity = new Dictionary(true);
         this._entitiesByCell = new Dictionary(true);
      }
      
      public function get position() : Point
      {
         return this._position;
      }
      
      public function get size() : Point
      {
         return this._size;
      }
      
      public function get cellMap() : CellMap
      {
         return this._cellMap;
      }
      
      public function get cellSize() : int
      {
         return this._cellSize;
      }
      
      public function get navGraph() : Graph
      {
         return this._navGraph;
      }
      
      public function get pathfinder() : Pathfinder
      {
         return this._pathfinder;
      }
      
      public function dispose() : void
      {
         this._cellsByEntity = null;
         this._entitiesByCell = null;
         this._cellMap.dispose();
         this._navGraph.clear();
         this.changed.removeAll();
      }
      
      public function clearEntities() : void
      {
         DictionaryUtils.clear(this._cellsByEntity);
         DictionaryUtils.clear(this._entitiesByCell);
      }
      
      public function set(param1:int, param2:int, param3:int, param4:int, param5:Array) : void
      {
         var _loc8_:Cell = null;
         var _loc6_:int = param3 * param4;
         if(param5.length != _loc6_)
         {
            throw new Error("Map size must match cost list size.");
         }
         this._position.setTo(param1,param2);
         this._size.setTo(param3,param4);
         this._cellMap.setSize(param3,param4);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = this._cellMap.tls::_cells[_loc7_];
            _loc8_.baseCost = int(param5[_loc7_]);
            this.updateCellCost(_loc8_);
            _loc7_++;
         }
      }
      
      public function getCellCoords(param1:int, param2:int, param3:Vector3D = null) : Vector3D
      {
         param3 ||= new Vector3D();
         param3.setTo(this._position.x + this._cellSize * param1 + this._cellSize * 0.5,this._position.y - this._cellSize * param2 - this._cellSize * 0.5,0);
         return param3;
      }
      
      public function getCellAtCoords(param1:Number, param2:Number) : Cell
      {
         var _loc3_:int = int((param1 - this._position.x) / this._cellSize);
         var _loc4_:int = int((this._position.y - param2) / this._cellSize);
         if(_loc3_ < 0 || _loc4_ < 0 || _loc3_ >= this._size.x || _loc4_ >= this._size.y)
         {
            return null;
         }
         return this._cellMap.tls::_cells[_loc3_ + _loc4_ * this._size.x];
      }
      
      public function getCellAtCoords2(param1:Vector3D) : Cell
      {
         return this.getCellAtCoords(param1.x,param1.y);
      }
      
      public function getCellsAround(param1:int, param2:int, param3:int = 5, param4:Boolean = false, param5:Vector.<Cell> = null) : Vector.<Cell>
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         param5 ||= new Vector.<Cell>();
         var _loc6_:Cell = this._cellMap.getCell(param1,param2);
         if(_loc6_ != null)
         {
            param5.push(_loc6_);
         }
         var _loc7_:int = 1;
         while(_loc7_ <= param3)
         {
            _loc8_ = param1 - _loc7_;
            _loc9_ = param2 - _loc7_;
            _loc10_ = param1 + _loc7_;
            _loc11_ = param2 + _loc7_;
            _loc12_ = _loc8_;
            while(_loc12_ <= _loc10_)
            {
               if(!(_loc12_ < 0 || _loc12_ >= this._size.x))
               {
                  if(_loc9_ >= 0)
                  {
                     _loc6_ = this._cellMap.tls::_cells[_loc12_ + _loc9_ * this._size.x];
                     if(!param4 || this.isPassableCell(_loc6_))
                     {
                        if(param5.indexOf(_loc6_) == -1)
                        {
                           param5.push(_loc6_);
                        }
                     }
                  }
                  if(_loc11_ < this._size.y)
                  {
                     _loc6_ = this._cellMap.tls::_cells[_loc12_ + _loc11_ * this._size.x];
                     if(!param4 || this.isPassableCell(_loc6_))
                     {
                        if(param5.indexOf(_loc6_) == -1)
                        {
                           param5.push(_loc6_);
                        }
                     }
                  }
                  _loc13_ = _loc9_ + 1;
                  while(_loc13_ <= _loc11_ - 1)
                  {
                     if(!(_loc13_ < 0 || _loc13_ >= this._size.y))
                     {
                        if(_loc8_ >= 0)
                        {
                           _loc6_ = this._cellMap.tls::_cells[_loc8_ + _loc13_ * this._size.x];
                           if(!param4 || this.isPassableCell(_loc6_))
                           {
                              if(param5.indexOf(_loc6_) == -1)
                              {
                                 param5.push(_loc6_);
                              }
                           }
                        }
                        if(_loc10_ < this._size.x)
                        {
                           _loc6_ = this._cellMap.tls::_cells[_loc10_ + _loc13_ * this._size.x];
                           if(!param4 || this.isPassableCell(_loc6_))
                           {
                              if(param5.indexOf(_loc6_) == -1)
                              {
                                 param5.push(_loc6_);
                              }
                           }
                        }
                     }
                     _loc13_++;
                  }
               }
               _loc12_++;
            }
            _loc7_++;
         }
         return param5;
      }
      
      public function getRandomPassableCellAround(param1:int, param2:int, param3:int = 1) : Cell
      {
         var _loc9_:int = 0;
         var _loc4_:int = param1 - param3;
         var _loc5_:int = param1 + param3;
         var _loc6_:int = param2 - param3;
         var _loc7_:int = param2 + param3;
         var _loc8_:Cell = null;
         while(_loc8_ == null && _loc9_++ < 50)
         {
            param1 = _loc4_ + int((_loc5_ - _loc4_) * Math.random());
            param2 = _loc6_ + int((_loc7_ - _loc6_) * Math.random());
            if(!(param1 < 0 || param2 < 0 || param1 >= this._size.x || param2 >= this._size.y))
            {
               _loc8_ = this._cellMap.tls::_cells[param1 + param2 * this._size.x];
               if(_loc8_.cost + _loc8_.penaltyCost > 0)
               {
                  _loc8_ = null;
               }
            }
         }
         return _loc8_;
      }
      
      public function getCellsEntityIsOccupying(param1:GameEntity) : Vector.<Cell>
      {
         return this._cellsByEntity[param1] || new Vector.<Cell>();
      }
      
      public function getEntitiesOccupyingCell(param1:Cell) : Vector.<GameEntity>
      {
         return this._entitiesByCell[param1] || new Vector.<GameEntity>();
      }
      
      public function getPassableCellAroundCellClosestToPoint(param1:int, param2:int, param3:Vector3D, param4:int = 5, param5:int = 2147483647) : Cell
      {
         return this.getClosestCellFromListToPoint(this.getPassableCellsAround(param1,param2,param4,param5),param3);
      }
      
      public function getPassableCellAroundEntityClosestToPoint(param1:GameEntity, param2:Vector3D, param3:int = 2147483647) : Cell
      {
         return this.getClosestCellFromListToPoint(this.getPassableCellsAroundEntity(param1,1,param3),param2);
      }
      
      public function getClosestCellFromListToPoint(param1:Vector.<Cell>, param2:Vector3D) : Cell
      {
         var _loc4_:Cell = null;
         var _loc5_:Cell = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc3_:Number = Number.MAX_VALUE;
         for each(_loc5_ in param1)
         {
            this.getCellCoords(_loc5_.x,_loc5_.y,this._tmpVector1);
            _loc6_ = param2.x - this._tmpVector1.x;
            _loc7_ = param2.y - this._tmpVector1.y;
            _loc8_ = _loc6_ * _loc6_ + _loc7_ * _loc7_;
            if(_loc8_ < _loc3_)
            {
               _loc3_ = _loc8_;
               _loc4_ = _loc5_;
            }
         }
         return _loc4_;
      }
      
      public function getPassableCellsAroundEntity(param1:GameEntity, param2:int = 1, param3:int = 2147483647, param4:Vector.<Cell> = null) : Vector.<Cell>
      {
         var _loc6_:Cell = null;
         param4 ||= new Vector.<Cell>();
         var _loc5_:Vector.<Cell> = this.getCellsEntityIsOccupying(param1);
         for each(_loc6_ in _loc5_)
         {
            this.getPassableCellsAround(_loc6_.x,_loc6_.y,param2,param3,param4);
         }
         return param4;
      }
      
      public function getPassableCellsAround(param1:int, param2:int, param3:int = 5, param4:int = 2147483647, param5:Vector.<Cell> = null) : Vector.<Cell>
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         param5 ||= new Vector.<Cell>();
         var _loc6_:Cell = this._cellMap.getCell(param1,param2);
         if(_loc6_ != null && this.isPassableCell(_loc6_))
         {
            param5.push(_loc6_);
            return param5;
         }
         var _loc7_:int = 1;
         while(_loc7_ <= param3)
         {
            _loc8_ = param1 - _loc7_;
            _loc9_ = param2 - _loc7_;
            _loc10_ = param1 + _loc7_;
            _loc11_ = param2 + _loc7_;
            if(_loc8_ < 0)
            {
               _loc8_ = 0;
            }
            if(_loc9_ < 0)
            {
               _loc9_ = 0;
            }
            if(_loc10_ >= this._size.x)
            {
               _loc10_ = this._size.x - 1;
            }
            if(_loc11_ >= this._size.y)
            {
               _loc11_ = this._size.y - 1;
            }
            _loc12_ = _loc8_;
            while(_loc12_ <= _loc10_)
            {
               _loc13_ = _loc9_;
               while(_loc13_ <= _loc11_)
               {
                  _loc6_ = this._cellMap.tls::_cells[_loc12_ + _loc13_ * this._size.x];
                  if(_loc6_.cost + _loc6_.penaltyCost > 0)
                  {
                     param5.push(_loc6_);
                  }
                  _loc13_++;
               }
               _loc12_++;
            }
            _loc7_++;
            if(param5.length >= param4)
            {
               break;
            }
         }
         return param5;
      }
      
      private function isPassableForEntity(param1:Cell, param2:GameEntity, param3:Vector.<GameEntity> = null, param4:Vector.<Class> = null) : Boolean
      {
         var _loc6_:GameEntity = null;
         var _loc7_:Class = null;
         var _loc5_:Vector.<GameEntity> = this._entitiesByCell[param1];
         if(_loc5_ == null)
         {
            return true;
         }
         for each(_loc6_ in _loc5_)
         {
            if(_loc6_ != param2)
            {
               if(!(param3 != null && param3.indexOf(_loc6_) > -1))
               {
                  if(param1.cost >= 0)
                  {
                     if(!_loc6_.passable && param1.baseCost >= 0 || (_loc6_.flags & GameEntityFlags.FORCE_UNPASSABLE) != 0)
                     {
                        return false;
                     }
                  }
                  if(param4 != null)
                  {
                     for each(_loc7_ in param4)
                     {
                        if(_loc6_ is _loc7_)
                        {
                           return false;
                        }
                     }
                  }
               }
            }
         }
         return true;
      }
      
      public function getAccessibleCellsAroundEntity(param1:GameEntity, param2:Vector.<GameEntity> = null, param3:Vector.<Class> = null, param4:Vector.<Cell> = null) : Vector.<Cell>
      {
         var _loc7_:Cell = null;
         var _loc8_:Cell = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         param4 ||= new Vector.<Cell>();
         var _loc5_:Vector.<Cell> = this.getCellsEntityIsOccupying(param1);
         var _loc6_:* = param1 is ICellFootprint;
         for each(_loc7_ in _loc5_)
         {
            if(this.isPassableForEntity(_loc7_,param1,param2,param3))
            {
               if(this.isPassableCell(_loc7_) && !_loc6_)
               {
                  param4.push(_loc7_);
               }
               else
               {
                  _loc9_ = -1;
                  while(_loc9_ <= 1)
                  {
                     _loc8_ = this._cellMap.getCell(_loc7_.x + _loc9_,_loc7_.y);
                     if(this.isPassableCell(_loc8_))
                     {
                        param4.push(_loc8_);
                     }
                     _loc9_ += 2;
                  }
                  _loc10_ = -1;
                  while(_loc10_ <= 1)
                  {
                     _loc8_ = this._cellMap.getCell(_loc7_.x,_loc7_.y + _loc10_);
                     if(this.isPassableCell(_loc8_))
                     {
                        param4.push(_loc8_);
                     }
                     _loc10_ += 2;
                  }
               }
            }
         }
         _loc9_ = int(param4.length - 1);
         while(_loc9_ >= 0)
         {
            if(!this.isPassableForEntity(param4[_loc9_],param1,param2,param3))
            {
               param4.splice(_loc9_,1);
            }
            _loc9_--;
         }
         return param4;
      }
      
      public function isPassable(param1:int, param2:int) : Boolean
      {
         if(param1 < 0 || param2 < 0 || param1 >= this._size.x || param2 >= this._size.y)
         {
            return false;
         }
         return this.isPassableCell(this._cellMap.tls::_cells[param1 + param2 * this._size.x]);
      }
      
      public function isPassableWorld(param1:Vector3D) : Boolean
      {
         return this.isPassableCell(this.getCellAtCoords(param1.x,param1.y));
      }
      
      private function updateCellCost(param1:Cell) : void
      {
         param1.cost = this._isPassableCell(param1) ? (param1.baseCost ^ param1.baseCost >> 31) - (param1.baseCost >> 31) : 0;
      }
      
      private function _isPassableCell(param1:Cell) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:GameEntity = null;
         if(param1 == null)
         {
            return false;
         }
         this._tmpCost = param1.baseCost;
         this._tmpCost = (this._tmpCost ^ this._tmpCost >> 31) - (this._tmpCost >> 31);
         if(this._tmpCost == 0)
         {
            return false;
         }
         this._tmpEntList = this._entitiesByCell[param1];
         if(this._tmpEntList != null)
         {
            _loc2_ = 0;
            _loc3_ = int(this._tmpEntList.length);
            while(_loc2_ < _loc3_)
            {
               _loc4_ = this._tmpEntList[_loc2_];
               if(!(_loc4_.flags & GameEntityFlags.FORCE_PASSABLE))
               {
                  if(_loc4_.flags & GameEntityFlags.FORCE_UNPASSABLE)
                  {
                     return false;
                  }
                  if(!_loc4_.passable && param1.baseCost >= 0)
                  {
                     return false;
                  }
               }
               _loc2_++;
            }
         }
         return true;
      }
      
      public function isPassableCell(param1:Cell) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return param1.cost + param1.penaltyCost > 0;
      }
      
      public function addEntityToCell(param1:GameEntity, param2:int, param3:int) : void
      {
         if(param2 < 0 || param3 < 0 || param2 >= this._size.x || param3 >= this._size.y)
         {
            return;
         }
         var _loc4_:Cell = this._cellMap.tls::_cells[param2 + param3 * this._size.x];
         var _loc5_:Boolean = this.isPassableCell(_loc4_);
         var _loc6_:Vector.<GameEntity> = this._entitiesByCell[_loc4_];
         if(_loc6_ == null)
         {
            _loc6_ = new <GameEntity>[param1];
            this._entitiesByCell[param1] = _loc6_;
         }
         else if(_loc6_.indexOf(param1) == -1)
         {
            _loc6_.push(param1);
         }
         var _loc7_:Vector.<Cell> = this._cellsByEntity[param1];
         if(_loc7_ == null)
         {
            _loc7_ = new <Cell>[_loc4_];
            this._cellsByEntity[param1] = _loc7_;
         }
         else if(_loc7_.indexOf(_loc4_) == -1)
         {
            _loc7_.push(_loc4_);
         }
         this.updateCellCost(_loc4_);
         if(_loc5_ != this.isPassableCell(_loc4_))
         {
            this.changed.dispatch();
         }
      }
      
      public function removeEntityFromCell(param1:GameEntity, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         if(param2 < 0 || param3 < 0 || param2 >= this._size.x || param3 >= this._size.y)
         {
            return;
         }
         var _loc5_:Cell = this._cellMap.getCell(param2,param3);
         var _loc6_:Boolean = this.isPassableCell(_loc5_);
         var _loc7_:Vector.<GameEntity> = this._entitiesByCell[_loc5_];
         if(_loc7_ != null)
         {
            _loc4_ = int(_loc7_.length - 1);
            while(_loc4_ >= 0)
            {
               if(_loc7_[_loc4_] == param1)
               {
                  _loc7_.splice(_loc4_,1);
                  break;
               }
               _loc4_--;
            }
         }
         var _loc8_:Vector.<Cell> = this._cellsByEntity[param1];
         if(_loc8_ != null)
         {
            _loc4_ = int(_loc8_.length - 1);
            while(_loc4_ >= 0)
            {
               if(_loc8_[_loc4_] == _loc5_)
               {
                  _loc8_.splice(_loc4_,1);
                  break;
               }
               _loc4_--;
            }
         }
         this.updateCellCost(_loc5_);
         if(_loc6_ != this.isPassableCell(_loc5_))
         {
            this.changed.dispatch();
         }
      }
      
      public function removeEntity(param1:GameEntity) : void
      {
         var _loc4_:Cell = null;
         var _loc5_:Boolean = false;
         var _loc6_:Vector.<GameEntity> = null;
         var _loc7_:int = 0;
         var _loc2_:Boolean = false;
         var _loc3_:Vector.<Cell> = this._cellsByEntity[param1];
         if(_loc3_ != null)
         {
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = this.isPassableCell(_loc4_);
               _loc6_ = this._entitiesByCell[_loc4_];
               if(_loc6_ != null)
               {
                  _loc7_ = int(_loc6_.length - 1);
                  while(_loc7_ >= 0)
                  {
                     if(_loc6_[_loc7_] == param1)
                     {
                        _loc6_.splice(_loc7_,1);
                        break;
                     }
                     _loc7_--;
                  }
               }
               this.updateCellCost(_loc4_);
               if(_loc5_ != this.isPassableCell(_loc4_))
               {
                  _loc2_ = true;
               }
            }
         }
         delete this._cellsByEntity[param1];
         if(_loc2_)
         {
            this.changed.dispatch();
         }
      }
      
      public function setBufferCells(param1:ICellFootprint) : void
      {
         param1.getBufferCells(this._tmpCellList);
         var _loc2_:int = 0;
         var _loc3_:int = int(this._tmpCellList.length);
         while(_loc2_ < _loc3_)
         {
            ++this._tmpCellList[_loc2_].bufferCount;
            _loc2_++;
         }
      }
      
      public function clearBufferCells(param1:ICellFootprint) : void
      {
         param1.getBufferCells(this._tmpCellList);
         var _loc2_:int = 0;
         var _loc3_:int = int(this._tmpCellList.length);
         while(_loc2_ < _loc3_)
         {
            if(this._tmpCellList[_loc2_].bufferCount > 0)
            {
               --this._tmpCellList[_loc2_].bufferCount;
            }
            _loc2_++;
         }
      }
      
      public function updateCellsForEntity(param1:GameEntity, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Cell = null;
         var _loc7_:int = 0;
         var _loc9_:Vector.<GameEntity> = null;
         var _loc11_:Boolean = false;
         var _loc12_:ICellFootprint = null;
         var _loc13_:Cell = null;
         var _loc14_:Rectangle = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:Object3D = null;
         var _loc20_:Number = NaN;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         if(param1.asset == null)
         {
            return;
         }
         var _loc8_:Boolean = false;
         var _loc10_:Vector.<Cell> = this._cellsByEntity[param1];
         if(_loc10_ == null)
         {
            _loc10_ = new Vector.<Cell>();
            this._cellsByEntity[param1] = _loc10_;
         }
         else
         {
            _loc10_.length > 0;
         }
         _loc3_ = 0;
         _loc5_ = int(_loc10_.length);
         while(_loc3_ < _loc5_)
         {
            _loc9_ = this._entitiesByCell[_loc10_[_loc3_]];
            if(_loc9_ != null)
            {
               _loc4_ = int(_loc9_.length - 1);
               while(_loc4_ >= 0)
               {
                  if(_loc9_[_loc4_] == param1)
                  {
                     _loc9_.splice(_loc4_,1);
                     break;
                  }
                  _loc4_--;
               }
            }
            this.updateCellCost(_loc10_[_loc3_]);
            _loc3_++;
         }
         _loc10_.length = 0;
         if(param1.scene != null && param1.asset.boundBox != null && param1.scene.map == this)
         {
            if(param1.flags & GameEntityFlags.USE_FOOTPRINT_FOR_TILEMAP)
            {
               _loc12_ = param1 as ICellFootprint;
               _loc13_ = this.getCellAtCoords(param1.transform.position.x,param1.transform.position.y);
               _loc14_ = _loc12_.getFootprintRect(_loc13_.x,_loc13_.y);
               _loc15_ = this.max(0,_loc14_.left);
               _loc16_ = this.min(this._size.x - 1,_loc14_.right);
               _loc17_ = this.max(0,_loc14_.top);
               _loc18_ = this.min(this._size.y - 1,_loc14_.bottom);
               _loc3_ = _loc15_;
               while(_loc3_ <= _loc16_)
               {
                  _loc4_ = _loc17_;
                  while(_loc4_ <= _loc18_)
                  {
                     _loc6_ = this._cellMap.tls::_cells[_loc3_ + _loc4_ * this._size.x];
                     _loc7_ = _loc6_.cost;
                     _loc10_.push(_loc6_);
                     _loc9_ = this._entitiesByCell[_loc6_];
                     if(_loc9_ == null)
                     {
                        _loc9_ = new <GameEntity>[param1];
                        this._entitiesByCell[_loc6_] = _loc9_;
                     }
                     else
                     {
                        _loc9_.push(param1);
                     }
                     this.updateCellCost(_loc6_);
                     _loc8_ ||= _loc6_.cost != _loc7_;
                     _loc4_++;
                  }
                  _loc3_++;
               }
            }
            else if(!(param1.flags & GameEntityFlags.IGNORE_TILEMAP))
            {
               _loc19_ = param1.boundingBoxMesh != null ? param1.boundingBoxMesh : param1.asset;
               this._tmpBounds.reset();
               Object3DUtils.calculateHierarchyBoundBox(_loc19_,_loc19_,this._tmpBounds);
               this._tmpVector1.setTo(this._tmpBounds.minX,this._tmpBounds.minY,this._tmpBounds.minZ);
               this._tmpVector2.setTo(this._tmpBounds.maxX,this._tmpBounds.maxY,this._tmpBounds.maxZ);
               this._tmpVector1 = param1.asset.matrix.deltaTransformVector(this._tmpVector1);
               this._tmpVector2 = param1.asset.matrix.deltaTransformVector(this._tmpVector2);
               _loc20_ = this.min(this._tmpVector1.y,this._tmpVector2.y) + this.max(this._tmpVector1.y,this._tmpVector2.y);
               _loc21_ = Math.floor((this._tmpVector1.x - this._position.x + param1.transform.position.x) / this._cellSize);
               _loc22_ = Math.floor((this._tmpVector2.x - this._position.x + param1.transform.position.x) / this._cellSize);
               _loc23_ = Math.floor((this._tmpVector1.y + this._position.y - param1.transform.position.y - _loc20_) / this._cellSize);
               _loc24_ = Math.floor((this._tmpVector2.y + this._position.y - param1.transform.position.y - _loc20_) / this._cellSize);
               _loc25_ = this.min(_loc21_,_loc22_);
               _loc26_ = this.min(_loc23_,_loc24_);
               _loc27_ = this.max(_loc21_,_loc22_);
               _loc28_ = this.max(_loc23_,_loc24_);
               if(_loc25_ < this._size.x && _loc26_ < this._size.y && _loc27_ >= 0 && _loc28_ >= 0)
               {
                  if(_loc25_ < 0)
                  {
                     _loc25_ = 0;
                  }
                  if(_loc26_ < 0)
                  {
                     _loc26_ = 0;
                  }
                  if(_loc27_ >= this._size.x)
                  {
                     _loc27_ = this._size.x - 1;
                  }
                  if(_loc28_ >= this._size.y)
                  {
                     _loc28_ = this._size.y - 1;
                  }
                  _loc3_ = _loc25_;
                  while(_loc3_ <= _loc27_)
                  {
                     _loc4_ = _loc26_;
                     while(_loc4_ <= _loc28_)
                     {
                        _loc6_ = this._cellMap.tls::_cells[_loc3_ + _loc4_ * this._size.x];
                        _loc7_ = _loc6_.cost;
                        _loc10_.push(_loc6_);
                        _loc9_ = this._entitiesByCell[_loc6_];
                        if(_loc9_ == null)
                        {
                           _loc9_ = new <GameEntity>[param1];
                           this._entitiesByCell[_loc6_] = _loc9_;
                        }
                        else
                        {
                           _loc9_.push(param1);
                        }
                        this.updateCellCost(_loc6_);
                        _loc8_ ||= _loc6_.cost != _loc7_;
                        _loc4_++;
                     }
                     _loc3_++;
                  }
               }
            }
         }
         if(!param2 && _loc8_)
         {
            this.changed.dispatch();
         }
      }
      
      public function isReachable(param1:int, param2:int, param3:int, param4:int, param5:int = 2147483647, param6:Number = 1.7976931348623157e+308) : Boolean
      {
         var _loc7_:Cell = null;
         var _loc8_:int = 0;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         if(param1 == param3 && param2 == param4)
         {
            return true;
         }
         _loc7_ = this._cellMap.getCell(param3,param4);
         if(_loc7_ == null || _loc7_.cost + _loc7_.penaltyCost == 0)
         {
            return false;
         }
         var _loc9_:int = param3 - param1;
         var _loc10_:int = param4 - param2;
         var _loc11_:int = _loc9_ * _loc9_ + _loc10_ * _loc10_;
         if(_loc11_ == 0)
         {
            return false;
         }
         var _loc12_:int = _loc7_.x;
         var _loc13_:int = _loc7_.y;
         var _loc14_:int = this._size.y;
         var _loc15_:int = this._size.x;
         _loc11_ = Math.sqrt(_loc11_);
         var _loc16_:Number = _loc9_ / _loc11_;
         var _loc17_:Number = _loc10_ / _loc11_;
         if(param6 < _loc11_)
         {
            _loc11_ = param6;
         }
         var _loc18_:Number = 0;
         var _loc19_:Number = 1 / 2;
         var _loc20_:Cell = this._cellMap.getCell(param1,param2);
         while(_loc18_ < _loc11_)
         {
            _loc7_ = null;
            _loc21_ = param1 + _loc18_ * _loc16_ + 0.5;
            _loc22_ = param2 + _loc18_ * _loc17_ + 0.5;
            _loc23_ = int(_loc21_);
            _loc24_ = int(_loc22_);
            if(_loc23_ >= 0 && _loc23_ < _loc15_ && _loc24_ >= 0 && _loc24_ < _loc14_)
            {
               _loc7_ = this._cellMap.tls::_cells[_loc23_ + _loc24_ * _loc15_];
            }
            if(_loc20_ != _loc7_)
            {
               if(_loc7_ == null)
               {
                  break;
               }
               _loc8_ = _loc7_.cost + _loc7_.penaltyCost;
               if(_loc7_.cost == 0 || _loc8_ > param5)
               {
                  break;
               }
               _loc20_ = _loc7_;
            }
            _loc18_ += _loc19_;
         }
         return _loc18_ >= _loc11_;
      }
      
      public function isReachable2(param1:Cell, param2:Cell, param3:int = 2147483647, param4:Number = 1.7976931348623157e+308) : Boolean
      {
         if(param1 == null || param2 == null)
         {
            return false;
         }
         return this.isReachable(param1.x,param1.y,param2.x,param2.y,param3,param4);
      }
      
      public function isReachableWorld(param1:Vector3D, param2:Vector3D, param3:int = 2147483647, param4:Number = 1.7976931348623157e+308) : Boolean
      {
         var _loc5_:Cell = this.getCellAtCoords(param1.x,param1.y);
         if(_loc5_ == null)
         {
            return false;
         }
         var _loc6_:Cell = this.getCellAtCoords(param2.x,param2.y);
         if(_loc6_ == null)
         {
            return false;
         }
         return this.isReachable(_loc5_.x,_loc5_.y,_loc6_.x,_loc6_.y,param3,param4);
      }
      
      public function isReachableWithinRangeOfPoint(param1:Vector3D, param2:Vector3D, param3:Number, param4:Vector3D = null, param5:int = 2147483647) : Boolean
      {
         var _loc6_:Number = param2.x - param1.x;
         var _loc7_:Number = param2.y - param1.y;
         var _loc8_:Number = _loc6_ * _loc6_ + _loc7_ * _loc7_;
         if(_loc8_ == 0)
         {
            return true;
         }
         _loc8_ = 1 / Math.sqrt(_loc8_);
         _loc6_ *= _loc8_;
         _loc7_ *= _loc8_;
         param4 ||= new Vector3D();
         param4.x = param2.x - _loc6_ * param3;
         param4.y = param2.y - _loc7_ * param3;
         param4.z = 0;
         return this.isReachable(param1.x,param1.y,param4.x,param4.y,param5);
      }
      
      public function findPath(param1:int, param2:int, param3:int, param4:int, param5:Boolean = true, param6:PathfinderOptions = null) : Path
      {
         this._tmpCellA.x = param1;
         this._tmpCellA.y = param2;
         this._tmpCellB.x = param3;
         this._tmpCellB.y = param4;
         this._navGraph.add(this._tmpCellA);
         this._navGraph.add(this._tmpCellB);
         this.connectNavNodeToEntryNodes(this._tmpCellA,false);
         this.connectNavNodeToEntryNodes(this._tmpCellB,false);
         var _loc7_:Path = this._pathfinder.findPath(this._navGraph,this._tmpCellA,this._tmpCellB,param6);
         if(_loc7_.found)
         {
            if(!_loc7_.goalFound)
            {
               this.attachFirstObstacleWaypointToPath(_loc7_,this._tmpCellB);
            }
            if(param5)
            {
               _loc7_.waypoints = this.smoothPath(_loc7_.waypoints,false);
               _loc7_.numWaypoints = int(_loc7_.waypoints.length / 3);
            }
         }
         this._navGraph.remove(this._tmpCellA);
         this._navGraph.remove(this._tmpCellB);
         return _loc7_;
      }
      
      private function attachFirstObstacleWaypointToPath(param1:Path, param2:Cell) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:int = int(param1.waypoints.length);
         if(_loc3_ == 0)
         {
            return;
         }
         var _loc4_:int = param1.waypoints[_loc3_ - 3];
         var _loc5_:int = param1.waypoints[_loc3_ - 2];
         var _loc6_:int = param1.waypoints[_loc3_ - 1];
         var _loc7_:Path = this.findObstacles(_loc5_,_loc6_,param2.x,param2.y,false);
         if(_loc7_.numWaypoints > 0)
         {
            _loc8_ = _loc7_.waypoints[0];
            _loc9_ = _loc7_.waypoints[1];
            _loc10_ = _loc7_.waypoints[2];
            if(_loc9_ != _loc5_ || _loc10_ != _loc9_)
            {
               param1.nodes.push(_loc8_,_loc9_,_loc10_);
               ++param1.numNodes;
               param1.waypoints.push(_loc8_,_loc9_,_loc10_);
               ++param1.numWaypoints;
               param1.length += _loc7_.length;
            }
         }
      }
      
      public function findPathQueued(param1:int, param2:int, param3:int, param4:int, param5:int = 0, param6:PathfinderOptions = null) : PathfinderJob
      {
         this._tmpCellA.x = param1;
         this._tmpCellA.y = param2;
         this._tmpCellB.x = param3;
         this._tmpCellB.y = param4;
         var _loc7_:PathfinderJob = this._pathfinder.queueJob(this._navGraph,this._tmpCellA,this._tmpCellB,param5,param6);
         _loc7_.started.addOnceWithPriority(this.onPathfinderJobStarted,int.MIN_VALUE);
         _loc7_.completed.addOnceWithPriority(this.onPathfinderJobCompleted,0);
         return _loc7_;
      }
      
      public function findPathQueued2(param1:int = 0, param2:PathfinderOptions = null) : PathfinderJob
      {
         var _loc3_:PathfinderJob = this._pathfinder.queueJob(this._navGraph,null,null,param1,param2);
         _loc3_.started.addOnceWithPriority(this.onPathfinderJobStarted,int.MIN_VALUE);
         _loc3_.completed.addOnceWithPriority(this.onPathfinderJobCompleted,0);
         return _loc3_;
      }
      
      public function findObstacles(param1:int, param2:int, param3:int, param4:int, param5:Boolean = true) : Path
      {
         var _loc8_:int = 0;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc6_:Path = new Path();
         _loc6_.found = true;
         var _loc7_:Cell = this._cellMap.getCell(param3,param4);
         var _loc9_:int = param3 - param1;
         var _loc10_:int = param4 - param2;
         var _loc11_:int = _loc9_ * _loc9_ + _loc10_ * _loc10_;
         if(_loc11_ == 0)
         {
            return _loc6_;
         }
         var _loc12_:int = _loc7_.x;
         var _loc13_:int = _loc7_.y;
         var _loc14_:int = this._size.y;
         var _loc15_:int = this._size.x;
         _loc11_ = Math.sqrt(_loc11_);
         var _loc16_:Number = _loc9_ / _loc11_;
         var _loc17_:Number = _loc10_ / _loc11_;
         var _loc18_:Number = 0;
         var _loc19_:Number = 1 / 2;
         var _loc20_:Cell = this._cellMap.getCell(param1,param2);
         var _loc21_:int = _loc20_.cost + _loc20_.penaltyCost;
         while(_loc18_ < _loc11_)
         {
            _loc7_ = null;
            _loc22_ = param1 + _loc18_ * _loc16_ + 0.5;
            _loc23_ = param2 + _loc18_ * _loc17_ + 0.5;
            _loc24_ = int(_loc22_);
            _loc25_ = int(_loc23_);
            if(_loc24_ >= 0 && _loc24_ < _loc15_ && _loc25_ >= 0 && _loc25_ < _loc14_)
            {
               _loc7_ = this._cellMap.tls::_cells[_loc24_ + _loc25_ * _loc15_];
            }
            if(_loc20_ != _loc7_)
            {
               if(_loc7_ == null)
               {
                  break;
               }
               _loc8_ = _loc7_.cost + _loc7_.penaltyCost;
               if(_loc8_ == 0 && _loc21_ != 0)
               {
                  if(_loc6_.numWaypoints > 0)
                  {
                     _loc26_ = _loc6_.waypoints[_loc6_.numWaypoints * 3 + 1];
                     _loc27_ = _loc6_.waypoints[_loc6_.numWaypoints * 3 + 2];
                     _loc9_ = _loc26_ - _loc20_.x;
                     _loc10_ = _loc27_ - _loc20_.y;
                     _loc6_.length += Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
                  }
                  _loc6_.waypoints.push(0,_loc20_.x,_loc20_.y);
                  ++_loc6_.numWaypoints;
                  if(!param5)
                  {
                     break;
                  }
               }
               _loc21_ = _loc8_;
               _loc20_ = _loc7_;
            }
            _loc18_ += _loc19_;
         }
         return _loc6_;
      }
      
      public function smoothPath(param1:Vector.<int>, param2:Boolean = true) : Vector.<int>
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc18_:int = 0;
         var _loc3_:Vector.<int> = new Vector.<int>();
         if(param1.length == 0)
         {
            return _loc3_;
         }
         var _loc4_:int = param1[0];
         var _loc5_:int = param1[1];
         var _loc6_:int = param1[2];
         if(param2)
         {
            _loc3_.push(_loc4_,_loc5_,_loc6_);
         }
         var _loc10_:int = _loc4_;
         var _loc11_:int = _loc5_;
         var _loc12_:int = _loc6_;
         var _loc13_:int = 3;
         var _loc14_:int = int(param1.length);
         while(_loc13_ < _loc14_)
         {
            _loc7_ = param1[_loc13_ + 0];
            _loc8_ = param1[_loc13_ + 1];
            _loc9_ = param1[_loc13_ + 2];
            if(_loc8_ == _loc5_ && _loc9_ == _loc6_)
            {
               if(_loc3_.length >= 3)
               {
                  _loc18_ = _loc3_[_loc3_.length - 3];
                  if(_loc7_ > 0 && _loc18_ != _loc7_)
                  {
                     _loc3_[_loc3_.length - 3] = _loc7_;
                  }
               }
            }
            else
            {
               if(!this.isReachable(_loc11_,_loc12_,_loc8_,_loc9_))
               {
                  _loc3_.push(_loc4_,_loc5_,_loc6_);
                  _loc11_ = _loc5_;
                  _loc12_ = _loc6_;
                  _loc10_ = _loc4_;
               }
               if((this._cellMap.tls::_cells[_loc8_ + _loc9_ * this._size.x].flags & CellFlag.FORCE_WAYPOINT) != 0)
               {
                  _loc3_.push(_loc7_,_loc8_,_loc9_);
                  _loc11_ = _loc8_;
                  _loc12_ = _loc9_;
                  _loc10_ = _loc7_;
               }
               _loc4_ = _loc7_;
               _loc5_ = _loc8_;
               _loc6_ = _loc9_;
            }
            _loc13_ += 3;
         }
         var _loc15_:int = param1[_loc14_ - 3];
         var _loc16_:int = param1[_loc14_ - 2];
         var _loc17_:int = param1[_loc14_ - 1];
         if(_loc3_.length == 0 || _loc11_ != _loc16_ || _loc12_ != _loc17_)
         {
            if(this.isReachable(_loc11_,_loc12_,_loc16_,_loc17_))
            {
               _loc3_.push(_loc15_,_loc16_,_loc17_);
            }
         }
         return _loc3_;
      }
      
      public function buildNavGraph() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:NavCell = null;
         var _loc6_:NavCell = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:NavCell = null;
         this._navCellSize = Math.ceil(Math.max(this._cellMap.width,this._cellMap.height) / 8);
         this._navCellsWidth = Math.ceil(this._cellMap.width / this._navCellSize);
         this._navCellsHeight = Math.ceil(this._cellMap.height / this._navCellSize);
         var _loc1_:int = this._navCellsWidth * this._navCellsHeight;
         this._navGraph.clear();
         this._navCells = new Vector.<NavCell>(_loc1_,true);
         this._pathfinder = new Pathfinder(this._cellMap.size);
         DictionaryUtils.clear(this._traversalAreasById);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc5_ = new NavCell();
            _loc5_.x = int(_loc2_ % this._navCellsWidth);
            _loc5_.y = int(_loc2_ / this._navCellsWidth);
            this._navCells[_loc2_] = _loc5_;
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc6_ = this._navCells[_loc2_];
            _loc3_ = 0;
            while(_loc3_ < this._connectionDirsLen)
            {
               _loc7_ = _loc6_.x + this._connectionDirs[_loc3_ + 0];
               _loc8_ = _loc6_.y + this._connectionDirs[_loc3_ + 1];
               if(!(_loc7_ < 0 || _loc8_ < 0 || _loc7_ >= this._navCellsWidth || _loc8_ >= this._navCellsHeight))
               {
                  _loc9_ = this._navCells[_loc7_ + _loc8_ * this._navCellsWidth];
                  this.createNavGraphEntryNodes(_loc6_,_loc9_);
               }
               _loc3_ += 2;
            }
            if(_loc6_.nodeList.length > 0)
            {
               this.createNavGraphEdges(_loc6_);
            }
            _loc2_++;
         }
      }
      
      public function getTraversalArea(param1:int) : TraversalArea
      {
         return this._traversalAreasById[param1];
      }
      
      public function removeTraversalArea(param1:TraversalArea) : void
      {
         var _loc2_:Cell = null;
         var _loc3_:Cell = null;
         delete this._traversalAreasById[param1.id];
         for each(_loc2_ in param1.nodes)
         {
            _loc3_ = this._cellMap.getCell(_loc2_.x,_loc2_.y);
            if(_loc3_ != null)
            {
               _loc3_.flags &= ~CellFlag.FORCE_WAYPOINT;
            }
            this.removeNavNode(_loc2_);
         }
         param1.nodes.fixed = false;
         param1.nodes.length = 0;
         param1.edges.fixed = false;
         param1.edges.length = 0;
         param1.data = null;
         param1.x = param1.y = 0;
         param1.width = param1.height = 0;
      }
      
      public function addTraversalArea(param1:Rectangle, param2:int, param3:uint = 0, param4:uint = 0) : TraversalArea
      {
         var _loc6_:NavEdge = null;
         var _loc7_:Cell = null;
         var _loc8_:Cell = null;
         var _loc9_:Cell = null;
         var _loc10_:Cell = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:NavCell = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Path = null;
         var _loc17_:Vector.<int> = null;
         var _loc5_:TraversalArea = new TraversalArea();
         _loc5_.id = this._nextTraversalAreaId++;
         _loc5_.x = param1.x;
         _loc5_.y = param1.y;
         _loc5_.width = param1.width;
         _loc5_.height = param1.height;
         this._traversalAreasById[_loc5_.id] = _loc5_;
         if(_loc5_.height > 1)
         {
            this.createTraversalAreaEdge(_loc5_,0,param2,param3,param4);
         }
         if(_loc5_.width > 1)
         {
            this.createTraversalAreaEdge(_loc5_,1,param2,param3,param4);
         }
         this._pathfinderOptions.reset();
         this._pathfinderOptions.bounds = this._tmpRect;
         this._pathfinderOptions.maxCost = 1;
         for each(_loc7_ in _loc5_.nodes)
         {
            _loc11_ = int(_loc7_.x / this._navCellSize);
            _loc12_ = int(_loc7_.y / this._navCellSize);
            _loc13_ = this._navCells[_loc11_ + _loc12_ * this._navCellsWidth];
            this._tmpRect.x = _loc11_ * this._navCellSize;
            this._tmpRect.y = _loc12_ * this._navCellSize;
            this._tmpRect.width = this._navCellSize;
            this._tmpRect.height = this._navCellSize;
            _loc9_ = this._cellMap.tls::_cells[_loc7_.x + _loc7_.y * this._size.x];
            _loc14_ = 0;
            _loc15_ = int(_loc13_.nodeList.length);
            while(_loc14_ < _loc15_)
            {
               _loc8_ = _loc13_.nodeList[_loc14_];
               _loc10_ = this._cellMap.tls::_cells[_loc8_.x + _loc8_.y * this._size.x];
               if(!(_loc7_ == _loc8_ || _loc7_.threshold::getEdge(_loc8_) != null))
               {
                  _loc16_ = this._pathfinder.findPath(this._cellMap,_loc9_,_loc10_,this._pathfinderOptions);
                  if(_loc16_.found)
                  {
                     _loc17_ = this.smoothPath(_loc16_.nodes);
                     _loc6_ = NavEdge(_loc7_.threshold::addEdge(_loc8_,NavEdge));
                     _loc6_.waypoints = _loc17_;
                     _loc6_.length = _loc16_.length;
                     _loc6_ = NavEdge(_loc8_.threshold::addEdge(_loc7_,NavEdge));
                     _loc6_.waypoints = this.reverseCoordinateList(_loc17_);
                     _loc6_.length = _loc16_.length;
                  }
               }
               _loc14_++;
            }
         }
         for each(_loc7_ in _loc5_.nodes)
         {
            _loc11_ = int(_loc7_.x / this._navCellSize);
            _loc12_ = int(_loc7_.y / this._navCellSize);
            _loc13_ = this._navCells[_loc11_ + _loc12_ * this._navCellsWidth];
            this._navGraph.add(_loc7_);
            _loc13_.nodeList.push(_loc7_);
         }
         _loc5_.nodes.fixed = true;
         _loc5_.edges.fixed = true;
         return _loc5_;
      }
      
      private function createTraversalAreaEdge(param1:TraversalArea, param2:int, param3:int, param4:uint, param5:uint) : void
      {
         var _loc6_:Cell = null;
         var _loc7_:Cell = null;
         var _loc8_:Cell = null;
         var _loc9_:Cell = null;
         var _loc10_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:NavEdge = null;
         var _loc16_:uint = 0;
         if(param2 == 0)
         {
            _loc13_ = int(param1.y + param1.height * 0.5);
            _loc6_ = new Cell(param1.x - 1,_loc13_);
            _loc7_ = new Cell(param1.x + param1.width,_loc13_);
            _loc10_ = param1.width;
         }
         else
         {
            if(param2 != 1)
            {
               return;
            }
            _loc14_ = int(param1.x + param1.width * 0.5);
            _loc6_ = new Cell(_loc14_,param1.y - 1);
            _loc7_ = new Cell(_loc14_,param1.y + param1.height);
            _loc10_ = param1.height;
         }
         var _loc11_:uint = 0;
         var _loc12_:uint = uint(param4 | CellFlag.FORCE_WAYPOINT | CellFlag.TRAVERSAL_AREA);
         _loc8_ = this._cellMap.getCell(_loc6_.x,_loc6_.y);
         if(_loc8_ != null && _loc8_.cost != 0)
         {
            param1.nodes.push(_loc6_);
            _loc6_.traversalAreaId = param1.id;
            _loc6_.flags |= _loc12_;
            _loc8_.flags |= _loc12_;
            _loc11_ |= 1;
         }
         _loc9_ = this._cellMap.getCell(_loc7_.x,_loc7_.y);
         if(_loc9_ != null && _loc9_.cost != 0)
         {
            param1.nodes.push(_loc7_);
            _loc7_.traversalAreaId = param1.id;
            _loc7_.flags |= _loc12_;
            _loc9_.flags |= _loc12_;
            _loc11_ |= 2;
         }
         if(_loc11_ == (1 | 2))
         {
            _loc16_ = uint(param5 | NavEdgeFlag.TRAVERSAL_AREA);
            _loc15_ = NavEdge(_loc6_.threshold::addEdge(_loc7_,NavEdge));
            _loc15_.traversalAreaId = param1.id;
            _loc15_.waypoints = new <int>[param1.id,_loc6_.x,_loc6_.y,param1.id,_loc7_.x,_loc7_.y];
            _loc15_.length = _loc10_;
            _loc15_.flags |= _loc16_;
            _loc15_.cost = param3;
            param1.edges.push(_loc15_);
            _loc15_ = NavEdge(_loc7_.threshold::addEdge(_loc6_,NavEdge));
            _loc15_.traversalAreaId = param1.id;
            _loc15_.waypoints = new <int>[param1.id,_loc7_.x,_loc7_.y,param1.id,_loc6_.x,_loc6_.y];
            _loc15_.length = _loc10_;
            _loc15_.flags |= _loc16_;
            _loc15_.cost = param3;
            param1.edges.push(_loc15_);
         }
      }
      
      public function rebuildNavGraphArea(param1:Rectangle) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc11_:Cell = null;
         var _loc12_:NavCell = null;
         var _loc13_:Cell = null;
         var _loc14_:Boolean = false;
         var _loc15_:NavEdge = null;
         var _loc16_:Cell = null;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:Cell = null;
         var _loc20_:Cell = null;
         var _loc21_:Path = null;
         var _loc22_:Vector.<int> = null;
         var _loc7_:int = int(param1.topLeft.x / this._navCellSize) - 1;
         var _loc8_:int = int(param1.topLeft.y / this._navCellSize) - 1;
         var _loc9_:int = int(param1.bottomRight.x / this._navCellSize) + 1;
         var _loc10_:int = int(param1.bottomRight.y / this._navCellSize) + 1;
         this._tmpNavCellList.length = 0;
         _loc4_ = param1.left;
         while(_loc4_ <= param1.right)
         {
            _loc5_ = param1.top;
            while(_loc5_ <= param1.bottom)
            {
               this.updateCellCost(this._cellMap.tls::_cells[_loc4_ + _loc5_ * this._size.x]);
               _loc5_++;
            }
            _loc4_++;
         }
         _loc4_ = _loc7_;
         while(_loc4_ <= _loc9_)
         {
            _loc5_ = _loc8_;
            while(_loc5_ <= _loc10_)
            {
               if(!(_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= this._navCellsWidth || _loc5_ >= this._navCellsHeight))
               {
                  if(!((_loc4_ == _loc7_ || _loc4_ == _loc9_) && (_loc5_ == _loc8_ || _loc5_ == _loc10_)))
                  {
                     _loc12_ = this._navCells[_loc4_ + _loc5_ * this._navCellsWidth];
                     _loc2_ = int(_loc12_.nodeList.length - 1);
                     while(_loc2_ >= 0)
                     {
                        _loc13_ = _loc12_.nodeList[_loc2_];
                        _loc14_ = false;
                        _loc15_ = NavEdge(_loc13_.edgeList);
                        while(_loc15_ != null)
                        {
                           _loc16_ = Cell(_loc15_.node);
                           _loc17_ = int(_loc16_.x / this._navCellSize);
                           _loc18_ = int(_loc16_.y / this._navCellSize);
                           if(!(_loc17_ == _loc12_.x && _loc18_ == _loc12_.y))
                           {
                              if(_loc17_ > _loc7_ && _loc17_ < _loc9_ && _loc18_ > _loc8_ && _loc18_ < _loc10_)
                              {
                                 this.removeNavNode(_loc16_);
                                 _loc14_ = true;
                              }
                           }
                           _loc15_ = NavEdge(_loc15_.next);
                        }
                        if(_loc14_)
                        {
                           this.removeNavNode(_loc13_);
                        }
                        _loc2_--;
                     }
                     if(_loc12_.x < _loc9_ && _loc12_.y < _loc10_)
                     {
                        this._tmpNavCellList.push(_loc12_);
                     }
                  }
               }
               _loc5_++;
            }
            _loc4_++;
         }
         this._tmpCellList.length = 0;
         _loc2_ = 0;
         _loc6_ = int(this._tmpNavCellList.length);
         while(_loc2_ < _loc6_)
         {
            _loc12_ = this._tmpNavCellList[_loc2_];
            _loc3_ = 0;
            while(_loc3_ < this._connectionDirsLen)
            {
               _loc4_ = _loc12_.x + this._connectionDirs[_loc3_ + 0];
               _loc5_ = _loc12_.y + this._connectionDirs[_loc3_ + 1];
               if(!(_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= this._navCellsWidth || _loc5_ >= this._navCellsHeight))
               {
                  if(_loc4_ > _loc7_ && _loc4_ <= _loc9_ && _loc5_ > _loc8_ && _loc5_ <= _loc10_)
                  {
                     this.createNavGraphEntryNodes(_loc12_,this._navCells[_loc4_ + _loc5_ * this._navCellsWidth],this._tmpCellList);
                  }
               }
               _loc3_ += 2;
            }
            _loc2_++;
         }
         this._pathfinderOptions.reset();
         this._pathfinderOptions.bounds = this._tmpRect;
         this._pathfinderOptions.maxCost = 1;
         for each(_loc11_ in this._tmpCellList)
         {
            _loc17_ = int(_loc11_.x / this._navCellSize);
            _loc18_ = int(_loc11_.y / this._navCellSize);
            _loc12_ = this._navCells[_loc17_ + _loc18_ * this._navCellsWidth];
            _loc6_ = int(_loc12_.nodeList.length);
            this._tmpRect.x = _loc17_ * this._navCellSize;
            this._tmpRect.y = _loc18_ * this._navCellSize;
            this._tmpRect.width = this._navCellSize;
            this._tmpRect.height = this._navCellSize;
            _loc19_ = this.cellMap.tls::_cells[_loc11_.x + _loc11_.y * this._size.x];
            _loc2_ = 0;
            while(_loc2_ < _loc6_)
            {
               _loc20_ = _loc12_.nodeList[_loc2_];
               if(_loc20_ != _loc11_)
               {
                  if(_loc11_.threshold::getEdge(_loc20_) == null)
                  {
                     _loc21_ = this._pathfinder.findPath(this._cellMap,_loc19_,this._cellMap.tls::_cells[_loc20_.x + _loc20_.y * this._size.x],this._pathfinderOptions);
                     if(_loc21_.found)
                     {
                        _loc22_ = this.smoothPath(_loc21_.nodes);
                        _loc15_ = NavEdge(_loc11_.threshold::addEdge(_loc20_,NavEdge));
                        _loc15_.waypoints = _loc22_;
                        _loc15_.length = _loc21_.length;
                        _loc15_ = NavEdge(_loc20_.threshold::addEdge(_loc11_,NavEdge));
                        _loc15_.waypoints = this.reverseCoordinateList(_loc22_);
                        _loc15_.length = _loc21_.length;
                     }
                  }
               }
               _loc2_++;
            }
         }
         this.changed.dispatch();
      }
      
      private function createNavGraphEntryNodes(param1:NavCell, param2:NavCell, param3:Vector.<Cell> = null) : void
      {
         var _loc6_:Cell = null;
         var _loc7_:Cell = null;
         var _loc15_:Vector.<int> = null;
         var _loc16_:NavEdge = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:Cell = null;
         var _loc22_:Cell = null;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc4_:int = param2.x - param1.x;
         var _loc5_:int = param2.y - param1.y;
         var _loc8_:int = param1.x * this._navCellSize;
         var _loc9_:int = param1.y * this._navCellSize;
         var _loc10_:int = Math.min(_loc8_ + this._navCellSize,this._cellMap.width);
         var _loc11_:int = Math.min(_loc9_ + this._navCellSize,this._cellMap.height);
         var _loc12_:int = _loc8_ + (this._navCellSize - 1) * _loc4_;
         var _loc13_:int = _loc9_ + (this._navCellSize - 1) * _loc5_;
         var _loc14_:int = 0;
         var _loc17_:int = 0;
         while(_loc17_ <= this._navCellSize)
         {
            if(_loc4_ != 0)
            {
               _loc18_ = _loc12_;
               _loc19_ = _loc12_ + _loc4_;
               _loc20_ = param1.y * this._navCellSize + _loc17_;
               if(_loc20_ < _loc11_)
               {
                  _loc21_ = this._cellMap.getCell(_loc18_,_loc20_);
                  _loc22_ = this._cellMap.getCell(_loc19_,_loc20_);
               }
               if(_loc20_ >= _loc11_ || _loc21_.cost == 0 || _loc22_.cost == 0)
               {
                  _loc14_ = _loc20_ - _loc9_;
                  if(_loc14_ > 0)
                  {
                     _loc6_ = new Cell(_loc18_,int(_loc9_ + _loc14_ * 0.5));
                     _loc7_ = new Cell(_loc18_ + 1,int(_loc9_ + _loc14_ * 0.5));
                     param1.nodeList.push(_loc6_);
                     param2.nodeList.push(_loc7_);
                     this._navGraph.add(_loc6_);
                     this._navGraph.add(_loc7_);
                     _loc16_ = NavEdge(_loc6_.threshold::addEdge(_loc7_,NavEdge));
                     _loc16_.waypoints = new <int>[0,_loc6_.x,_loc6_.y,0,_loc7_.x,_loc7_.y];
                     _loc16_.length = 1;
                     _loc16_ = NavEdge(_loc7_.threshold::addEdge(_loc6_,NavEdge));
                     _loc16_.waypoints = new <int>[0,_loc7_.x,_loc7_.y,0,_loc6_.x,_loc6_.y];
                     _loc16_.length = 1;
                     if(param3 != null)
                     {
                        param3.push(_loc6_,_loc7_);
                     }
                  }
                  _loc9_ = _loc20_ + 1;
               }
            }
            if(_loc5_ != 0)
            {
               _loc23_ = _loc13_;
               _loc24_ = _loc13_ + _loc5_;
               _loc25_ = param1.x * this._navCellSize + _loc17_;
               if(_loc25_ < _loc10_)
               {
                  _loc21_ = this._cellMap.getCell(_loc25_,_loc23_);
                  _loc22_ = this._cellMap.getCell(_loc25_,_loc24_);
               }
               if(_loc25_ >= _loc10_ || _loc21_.cost == 0 || _loc22_.cost == 0)
               {
                  _loc14_ = _loc25_ - _loc8_;
                  if(_loc14_ > 0)
                  {
                     _loc6_ = new Cell(int(_loc8_ + _loc14_ * 0.5),_loc23_);
                     _loc7_ = new Cell(int(_loc8_ + _loc14_ * 0.5),_loc23_ + 1);
                     param1.nodeList.push(_loc6_);
                     param2.nodeList.push(_loc7_);
                     this._navGraph.add(_loc6_);
                     this._navGraph.add(_loc7_);
                     _loc16_ = NavEdge(_loc6_.threshold::addEdge(_loc7_,NavEdge));
                     _loc16_.waypoints = new <int>[0,_loc6_.x,_loc6_.y,0,_loc7_.x,_loc7_.y];
                     _loc16_.length = 1;
                     _loc16_ = NavEdge(_loc7_.threshold::addEdge(_loc6_,NavEdge));
                     _loc16_.waypoints = new <int>[0,_loc7_.x,_loc7_.y,0,_loc6_.x,_loc6_.y];
                     _loc16_.length = 1;
                     if(param3 != null)
                     {
                        param3.push(_loc6_,_loc7_);
                     }
                  }
                  _loc8_ = _loc25_ + 1;
               }
            }
            _loc17_++;
         }
      }
      
      private function createNavGraphEdges(param1:NavCell) : void
      {
         var _loc3_:Cell = null;
         var _loc4_:Cell = null;
         var _loc5_:int = 0;
         var _loc6_:Cell = null;
         var _loc7_:Path = null;
         var _loc8_:NavEdge = null;
         var _loc9_:Vector.<int> = null;
         this._tmpRect.x = param1.x * this._navCellSize;
         this._tmpRect.y = param1.y * this._navCellSize;
         this._tmpRect.width = this._navCellSize;
         this._tmpRect.height = this._navCellSize;
         this._pathfinderOptions.reset();
         this._pathfinderOptions.bounds = this._tmpRect;
         this._pathfinderOptions.maxCost = 1;
         var _loc2_:int = 0;
         while(_loc2_ < param1.nodeList.length)
         {
            _loc3_ = param1.nodeList[_loc2_];
            _loc4_ = this._cellMap.getCell(_loc3_.x,_loc3_.y);
            _loc5_ = _loc2_ + 1;
            while(_loc5_ < param1.nodeList.length)
            {
               _loc6_ = param1.nodeList[_loc5_];
               _loc7_ = this._pathfinder.findPath(this._cellMap,_loc4_,this._cellMap.getCell(_loc6_.x,_loc6_.y),this._pathfinderOptions);
               if(_loc7_.found)
               {
                  _loc9_ = this.smoothPath(_loc7_.nodes);
                  _loc8_ = NavEdge(_loc3_.threshold::addEdge(_loc6_,NavEdge));
                  _loc8_.waypoints = _loc9_;
                  _loc8_.length = _loc7_.length;
                  _loc8_ = NavEdge(_loc6_.threshold::addEdge(_loc3_,NavEdge));
                  _loc8_.waypoints = this.reverseCoordinateList(_loc9_);
                  _loc8_.length = _loc7_.length;
               }
               _loc5_++;
            }
            _loc2_++;
         }
      }
      
      private function connectNavNodeToEntryNodes(param1:Cell, param2:Boolean = true) : void
      {
         var _loc9_:Cell = null;
         var _loc10_:Path = null;
         var _loc11_:NavEdge = null;
         var _loc12_:Vector.<int> = null;
         var _loc3_:int = int(param1.x / this._navCellSize);
         var _loc4_:int = int(param1.y / this._navCellSize);
         var _loc5_:NavCell = this._navCells[_loc3_ + _loc4_ * this._navCellsWidth];
         this._tmpRect.setTo(_loc3_ * this._navCellSize,_loc4_ * this._navCellSize,this._navCellSize,this._navCellSize);
         this._pathfinderOptions.reset();
         this._pathfinderOptions.bounds = this._tmpRect;
         this._pathfinderOptions.maxCost = 1;
         var _loc6_:Cell = this._cellMap.getCell(param1.x,param1.y);
         var _loc7_:int = 0;
         var _loc8_:int = int(_loc5_.nodeList.length);
         while(_loc7_ < _loc8_)
         {
            _loc9_ = _loc5_.nodeList[_loc7_];
            _loc10_ = this._pathfinder.findPath(this._cellMap,_loc6_,this._cellMap.getCell(_loc9_.x,_loc9_.y),this._pathfinderOptions);
            if(_loc10_.found)
            {
               _loc12_ = param2 ? this.smoothPath(_loc10_.nodes) : _loc10_.nodes;
               _loc11_ = NavEdge(param1.threshold::addEdge(_loc9_,NavEdge));
               _loc11_.waypoints = _loc12_;
               _loc11_.length = _loc10_.length;
               _loc11_ = NavEdge(_loc9_.threshold::addEdge(param1,NavEdge));
               _loc11_.waypoints = this.reverseCoordinateList(_loc12_);
               _loc11_.length = _loc10_.length;
            }
            _loc7_++;
         }
      }
      
      private function removeNavNode(param1:Cell) : void
      {
         var _loc2_:int = int(param1.x / this._navCellSize);
         var _loc3_:int = int(param1.y / this._navCellSize);
         var _loc4_:NavCell = this._navCells[_loc2_ + _loc3_ * this._navCellsWidth];
         var _loc5_:int = int(_loc4_.nodeList.indexOf(param1));
         if(_loc5_ > -1)
         {
            _loc4_.nodeList.splice(_loc5_,1);
         }
         this._navGraph.remove(param1);
      }
      
      private function reverseCoordinateList(param1:Vector.<int>) : Vector.<int>
      {
         var _loc2_:Vector.<int> = new Vector.<int>();
         var _loc3_:int = int(param1.length - 1);
         while(_loc3_ >= 0)
         {
            _loc2_.push(param1[_loc3_ - 2],param1[_loc3_ - 1],param1[_loc3_]);
            _loc3_ -= 3;
         }
         return _loc2_;
      }
      
      private function onPathfinderJobStarted(param1:PathfinderJob) : void
      {
         var _loc6_:Path = null;
         var _loc7_:NavEdge = null;
         if(param1.start == null || param1.goal == null)
         {
            this._pathfinder.cancelJob(param1);
            return;
         }
         this._navGraph.add(param1.start);
         this._navGraph.add(param1.goal);
         var _loc2_:int = param1.goal.x - param1.start.x;
         var _loc3_:int = param1.goal.y - param1.start.y;
         var _loc4_:int = _loc2_ * _loc2_ + _loc3_ * _loc3_;
         var _loc5_:int = this._navCellSize;
         if(_loc4_ < _loc5_ * _loc5_)
         {
            this._tmpRect.x = param1.start.x - _loc5_;
            this._tmpRect.y = param1.start.y - _loc5_;
            this._tmpRect.width = _loc5_ * 2;
            this._tmpRect.height = _loc5_ * 2;
            this._pathfinderOptions.reset();
            this._pathfinderOptions.bounds = this._tmpRect;
            this._pathfinderOptions.maxCost = 1;
            _loc6_ = this._pathfinder.findPath(this._cellMap,this._cellMap.getCell(param1.start.x,param1.start.y),this._cellMap.getCell(param1.goal.x,param1.goal.y),this._pathfinderOptions);
            if(_loc6_.found)
            {
               _loc7_ = NavEdge(param1.start.threshold::addEdge(param1.goal,NavEdge));
               _loc7_.waypoints = _loc6_.nodes;
               _loc7_.length = _loc6_.length;
               _loc7_ = NavEdge(param1.goal.threshold::addEdge(param1.start,NavEdge));
               _loc7_.waypoints = this.reverseCoordinateList(_loc6_.nodes);
               _loc7_.length = _loc6_.length;
            }
         }
         this.connectNavNodeToEntryNodes(param1.start,false);
         this.connectNavNodeToEntryNodes(param1.goal,false);
      }
      
      private function onPathfinderJobCompleted(param1:PathfinderJob) : void
      {
         var _loc2_:Path = param1.path;
         if(_loc2_.found)
         {
            if(!_loc2_.goalFound)
            {
               this.attachFirstObstacleWaypointToPath(_loc2_,param1.goal);
            }
            _loc2_.waypoints = this.smoothPath(_loc2_.waypoints,false);
            _loc2_.numWaypoints = int(_loc2_.waypoints.length / 3);
         }
         if(param1.start != null)
         {
            this._navGraph.remove(param1.start);
         }
         if(param1.goal != null)
         {
            this._navGraph.remove(param1.goal);
         }
      }
      
      private function min(param1:Number, param2:Number) : Number
      {
         return param1 < param2 ? param1 : param2;
      }
      
      private function max(param1:Number, param2:Number) : Number
      {
         return param1 > param2 ? param1 : param2;
      }
   }
}

