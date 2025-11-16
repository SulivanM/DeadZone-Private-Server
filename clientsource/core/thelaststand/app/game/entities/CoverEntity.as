package thelaststand.app.game.entities
{
   import alternativa.engine3d.core.Object3D;
   import flash.geom.Rectangle;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.engine.map.Cell;
   import thelaststand.engine.objects.GameEntity;
   
   public class CoverEntity extends GameEntity
   {
      
      private var _coverRating:int;
      
      private var _coverTiles:Vector.<Cell>;
      
      private var _coveredAgents:Vector.<AIActorAgent>;
      
      protected var _coverArea:Object3D;
      
      public function CoverEntity()
      {
         super();
         this._coveredAgents = new Vector.<AIActorAgent>();
         addedToScene.add(this.updateCoverArea);
         assetInvalidated.add(this.updateCoverArea);
      }
      
      public function get coverArea() : Object3D
      {
         return this._coverArea;
      }
      
      public function get coveredAgents() : Vector.<AIActorAgent>
      {
         return this._coveredAgents;
      }
      
      public function get coverRating() : int
      {
         return this._coverRating;
      }
      
      public function set coverRating(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._coverRating = param1;
      }
      
      protected function updateCoverArea(param1:CoverEntity) : void
      {
         this._coverArea = asset != null ? asset.getChildByName("meshEntity") || asset : asset;
      }
      
      override public function dispose() : void
      {
         addedToScene.remove(this.updateCoverArea);
         assetInvalidated.remove(this.updateCoverArea);
         this._coverTiles = null;
         this._coveredAgents = null;
         super.dispose();
      }
      
      public function addAgentToCover(param1:AIActorAgent) : void
      {
         if(this._coverRating <= 0)
         {
            return;
         }
         if(this._coveredAgents.indexOf(param1) == -1)
         {
            this._coveredAgents.push(param1);
         }
      }
      
      public function removeAgentFromCover(param1:AIActorAgent) : void
      {
         if(this._coveredAgents == null)
         {
            return;
         }
         var _loc2_:int = int(this._coveredAgents.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._coveredAgents.splice(_loc2_,1);
      }
      
      public function getOccupyingRectangle() : Rectangle
      {
         var _loc8_:Cell = null;
         var _loc1_:Rectangle = new Rectangle();
         if(scene == null)
         {
            return _loc1_;
         }
         var _loc2_:Vector.<Cell> = this.scene.map.getCellsEntityIsOccupying(this);
         if(_loc2_.length == 0)
         {
            return _loc1_;
         }
         var _loc3_:int = int.MAX_VALUE;
         var _loc4_:int = int.MAX_VALUE;
         var _loc5_:int = int.MIN_VALUE;
         var _loc6_:int = int.MIN_VALUE;
         var _loc7_:int = 0;
         while(_loc7_ < _loc2_.length)
         {
            _loc8_ = _loc2_[_loc7_];
            if(_loc8_.x < _loc3_)
            {
               _loc3_ = _loc8_.x;
            }
            if(_loc8_.x > _loc5_)
            {
               _loc5_ = _loc8_.x;
            }
            if(_loc8_.y < _loc4_)
            {
               _loc4_ = _loc8_.y;
            }
            if(_loc8_.y > _loc6_)
            {
               _loc6_ = _loc8_.y;
            }
            _loc7_++;
         }
         _loc3_ = Math.max(_loc3_,0);
         _loc4_ = Math.max(_loc4_,0);
         _loc5_ = Math.min(_loc5_,scene.map.cellMap.width - 1);
         _loc6_ = Math.min(_loc6_,scene.map.cellMap.height - 1);
         _loc1_.x = _loc3_;
         _loc1_.y = _loc4_;
         _loc1_.width = _loc5_ - _loc3_;
         _loc1_.height = _loc6_ - _loc4_;
         return _loc1_;
      }
      
      public function getCoverTiles() : Vector.<Cell>
      {
         var _loc6_:Cell = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(this._coverTiles != null)
         {
            return this._coverTiles;
         }
         if(scene == null)
         {
            return null;
         }
         this._coverTiles = new Vector.<Cell>();
         if(this._coverRating == 0)
         {
            return this._coverTiles;
         }
         var _loc1_:Vector.<Cell> = scene.map.getCellsEntityIsOccupying(this);
         var _loc2_:int = int.MAX_VALUE;
         var _loc3_:int = int.MAX_VALUE;
         var _loc4_:int = int.MIN_VALUE;
         var _loc5_:int = int.MIN_VALUE;
         for each(_loc6_ in _loc1_)
         {
            if(_loc6_.x < _loc2_)
            {
               _loc2_ = _loc6_.x;
            }
            if(_loc6_.y < _loc3_)
            {
               _loc3_ = _loc6_.y;
            }
            if(_loc6_.x > _loc4_)
            {
               _loc4_ = _loc6_.x;
            }
            if(_loc6_.y > _loc5_)
            {
               _loc5_ = _loc6_.y;
            }
            if(_loc6_.cost < 0)
            {
               this._coverTiles.push(_loc6_);
            }
         }
         _loc2_--;
         _loc3_--;
         _loc4_++;
         _loc5_++;
         _loc7_ = _loc2_;
         while(_loc7_ <= _loc4_)
         {
            _loc8_ = _loc3_;
            while(_loc8_ <= _loc5_)
            {
               _loc6_ = scene.map.cellMap.getCell(_loc7_,_loc8_);
               if(_loc6_ != null)
               {
                  this._coverTiles.push(_loc6_);
               }
               _loc8_++;
            }
            _loc7_++;
         }
         return this._coverTiles;
      }
   }
}

