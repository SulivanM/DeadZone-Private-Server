package thelaststand.app.game.scenes
{
   import flash.geom.Vector3D;
   import thelaststand.app.game.entities.buildings.StreetStructure;
   import thelaststand.common.resources.ResourceManager;
   
   public class StreetScene extends BaseScene
   {
      
      private const TYPE_CITY_COMMERCIAL:String = "city-comm";
      
      private const TYPE_CITY_RESIDENTIAL:String = "city-res";
      
      private const TYPE_CITY_SHOP:String = "city-shop";
      
      private const TYPE_SUBURBAN_COMMERCIAL:String = "sub-comm";
      
      private const TYPE_SUBURBAN_RESIDENTIAL:String = "sub-res";
      
      private const TYPE_SUBURBAN_SHOP:String = "sub-shop";
      
      private const TYPE_INDUSTRIAL:String = "ind";
      
      private var _structures:Vector.<StreetStructure>;
      
      public function StreetScene()
      {
         super();
         addSceneLight();
         this._structures = new Vector.<StreetStructure>();
         _noiseVolumeMultiplier = 2;
      }
      
      override public function dispose() : void
      {
         this.clearStructures();
         this._structures = null;
         super.dispose();
      }
      
      private function clearStructures() : void
      {
         var _loc1_:StreetStructure = null;
         for each(_loc1_ in this._structures)
         {
            _loc1_.dispose();
         }
         this._structures.length = 0;
      }
      
      override protected function populateRandomizedElements(param1:Number = 0) : void
      {
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         this.clearStructures();
         super.populateRandomizedElements(param1);
         var _loc2_:XMLList = _xmlDescriptor.structs.group;
         var _loc3_:String = _xmlDescriptor.structs.hasOwnProperty("@type") ? _xmlDescriptor.structs.@type.toString() : this.TYPE_CITY_COMMERCIAL;
         for each(_loc4_ in _loc2_)
         {
            _loc5_ = _loc4_.hasOwnProperty("@maxfloors") ? int(_loc4_.@maxfloors) : -1;
            _loc6_ = _loc4_.hasOwnProperty("@rotationZ") ? Number(_loc4_.@rotationZ) * Math.PI / 180 : 0;
            this.createStructures(int(_loc4_.@x),int(_loc4_.@y),int(_loc4_.@width),int(_loc4_.@height),_loc3_,_loc5_,_loc6_);
         }
         rotation = int(Math.random() * ROTATION_STEPS);
      }
      
      private function createStructures(param1:int, param2:int, param3:int, param4:int, param5:String, param6:int = -1, param7:Number = 0) : void
      {
         var structSets:XMLList = null;
         var numSets:int = 0;
         var positions:Array = null;
         var maxSpawnY:int = 0;
         var minSpawnY:int = 0;
         var i:int = 0;
         var setData:XML = null;
         var bWidth:int = 0;
         var bLength:int = 0;
         var data:Object = null;
         var b:StreetStructure = null;
         var x:int = param1;
         var y:int = param2;
         var gridWidth:int = param3;
         var gridHeight:int = param4;
         var type:String = param5;
         var maxfloors:int = param6;
         var bldRotationZ:Number = param7;
         structSets = ResourceManager.getInstance().getResource("xml/streetstructs.xml").content.set.(@type.toString().indexOf(type) > -1);
         numSets = int(structSets.length());
         positions = [];
         maxSpawnY = _map.position.y - _map.cellSize * 26;
         minSpawnY = _map.position.y - (_map.size.y * _map.cellSize - _map.cellSize * 26);
         i = 0;
         while(i < 16)
         {
            setData = structSets[_rand.getIntInRange(0,numSets)];
            bWidth = int(setData.@sizeX.toString());
            bLength = int(setData.@sizeY.toString());
            if(this.addStructure(positions,gridWidth,gridHeight,bWidth,bLength))
            {
               data = positions[positions.length - 1];
               b = new StreetStructure("struct" + this._structures.length);
               b.generate(setData.@id.toString(),_rand.seed,data.x > 0 ? 3 : -1,maxfloors);
               addEntity(b);
               b.transform.setRotationEuler(0,0,bldRotationZ);
               b.transform.position.setTo(x - data.x * _map.cellSize + b.asset.boundBox.minX,y - data.y * _map.cellSize + b.asset.boundBox.minY + _rand.getRandom() * _map.cellSize * 0.25,0);
               b.updateTransform();
               if(data.x == 0 && b.transform.position.y >= minSpawnY && b.transform.position.y < maxSpawnY)
               {
                  spawnPointsPortals.push(new Vector3D(x - _map.cellSize * 4,b.transform.position.y + b.asset.boundBox.minY - _map.cellSize * 0.5,0));
               }
               this._structures.push(b);
               addShadowCaster(b.asset);
            }
            i++;
         }
      }
      
      private function addStructure(param1:Array, param2:int, param3:int, param4:int, param5:int, param6:int = 1) : Boolean
      {
         var _loc7_:Boolean = false;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         param4 += param6;
         param5 += param6;
         while(true)
         {
            _loc7_ = false;
            _loc10_ = _loc8_ + param4 - 1;
            _loc11_ = _loc9_ + param5 - 1;
            for each(_loc12_ in param1)
            {
               _loc13_ = int(_loc12_.x);
               _loc14_ = int(_loc12_.y);
               _loc15_ = _loc12_.x + _loc12_.width - 1;
               _loc16_ = _loc12_.y + _loc12_.height - 1;
               if(_loc8_ >= _loc13_ && _loc8_ <= _loc15_ && (_loc9_ >= _loc14_ && _loc9_ <= _loc16_ || _loc11_ >= _loc14_ && _loc11_ <= _loc16_))
               {
                  _loc7_ = true;
                  break;
               }
               if(_loc8_ < _loc13_ && _loc10_ >= _loc13_ && !(_loc11_ < _loc14_ || _loc9_ > _loc16_))
               {
                  _loc7_ = true;
                  break;
               }
               if(_loc9_ < _loc14_ && _loc11_ >= _loc14_ && !(_loc10_ < _loc13_ || _loc8_ > _loc15_))
               {
                  _loc7_ = true;
                  break;
               }
            }
            if(_loc7_)
            {
               _loc8_ += _loc12_.x - _loc8_ + _loc12_.width;
               if(_loc8_ >= param2 - param4)
               {
                  _loc8_ = 0;
                  _loc9_++;
               }
            }
            if(_loc9_ >= param3 - param5)
            {
               break;
            }
            if(!_loc7_)
            {
               param1.push({
                  "x":_loc8_,
                  "y":_loc9_,
                  "width":param4,
                  "height":param5
               });
               return true;
            }
         }
         return false;
      }
   }
}

