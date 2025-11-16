package thelaststand.app.game.entities.gui
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import com.greensock.easing.Back;
   import flash.geom.Vector3D;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class UIRangeIndicator extends GameEntity
   {
      
      private var _range:Number;
      
      private var _minRange:Number;
      
      private var _minEffectiveRange:Number;
      
      private var _entity:GameEntity;
      
      private var _yellow:Boolean;
      
      private var decal_maxRange:Decal;
      
      private var decal_minRange:Decal;
      
      private var decal_minEffRange:Decal;
      
      public function UIRangeIndicator(param1:Number = 0, param2:Number = 0)
      {
         super();
         asset = new Object3D();
         asset.mouseEnabled = asset.mouseChildren = false;
         asset.visible = true;
         this.decal_maxRange = new Decal();
         this.decal_maxRange.geometry = Primitives.SIMPLE_PLANE.geometry;
         this.decal_maxRange.addSurface(null,0,2);
         this.decal_minRange = new Decal();
         this.decal_minRange.geometry = Primitives.SIMPLE_PLANE.geometry;
         this.decal_minRange.addSurface(null,0,2);
         this.decal_minEffRange = new Decal();
         this.decal_minEffRange.geometry = Primitives.SIMPLE_PLANE.geometry;
         this.decal_minEffRange.addSurface(null,0,2);
         this.updateRange(param1);
         this.updateMinRange(param2);
         this.updateMinEffectiveRange(this.minEffectiveRange);
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(this.decal_maxRange);
         TweenMaxDelta.killTweensOf(this.decal_minRange);
         TweenMaxDelta.killTweensOf(this.decal_minEffRange);
         super.dispose();
         this._entity = null;
         this.decal_minEffRange.setMaterialToAllSurfaces(null);
         this.decal_minRange.setMaterialToAllSurfaces(null);
         this.decal_maxRange.setMaterialToAllSurfaces(null);
         this.decal_minEffRange.geometry = null;
         this.decal_minRange.geometry = null;
         this.decal_maxRange.geometry = null;
      }
      
      public function transitionIn() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.decal_maxRange.parent != null)
         {
            _loc1_ = this._range * 2;
            this.decal_maxRange.scaleX = this.decal_maxRange.scaleY = 0;
            TweenMaxDelta.to(this.decal_maxRange,0.4,{
               "scaleX":_loc1_,
               "scaleY":_loc1_,
               "overwrite":true,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
         }
         if(this.decal_minRange.parent != null)
         {
            _loc2_ = this._minRange * 2;
            this.decal_minRange.scaleX = this.decal_minRange.scaleY = 0;
            TweenMaxDelta.to(this.decal_minRange,0.4,{
               "scaleX":_loc2_,
               "scaleY":_loc2_,
               "overwrite":true,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
         }
         if(this.decal_minEffRange.parent != null)
         {
            _loc3_ = this._minEffectiveRange * 2;
            this.decal_minEffRange.scaleX = this.decal_minEffRange.scaleY = 0;
            TweenMaxDelta.to(this.decal_minEffRange,0.4,{
               "scaleX":_loc3_,
               "scaleY":_loc3_,
               "overwrite":true,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
         }
      }
      
      public function updatePosition(param1:Number = 1, param2:Boolean = false) : void
      {
         if(this._entity == null)
         {
            return;
         }
         var _loc3_:Vector3D = this._entity.transform.position;
         var _loc4_:Number = _loc3_.x;
         var _loc5_:Number = _loc3_.y;
         if(this._entity is BuildingEntity)
         {
            _loc4_ += BuildingEntity(this._entity).centerPoint.x;
            _loc5_ += BuildingEntity(this._entity).centerPoint.y;
         }
         if(param2 || _loc4_ != transform.position.x || _loc5_ != transform.position.y)
         {
            transform.position.x = _loc4_;
            transform.position.y = _loc5_;
            updateTransform(param1);
         }
      }
      
      override public function update(param1:Number = 1) : void
      {
         var _loc2_:Vector3D = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._entity != null)
         {
            _loc2_ = this._entity.transform.position;
            _loc3_ = _loc2_.x;
            _loc4_ = _loc2_.y;
            if(this._entity is BuildingEntity)
            {
               _loc3_ += BuildingEntity(this._entity).centerPoint.x;
               _loc4_ += BuildingEntity(this._entity).centerPoint.y;
            }
            if(_loc3_ != transform.position.x || _loc4_ != transform.position.y)
            {
               transform.position.x = _loc3_;
               transform.position.y = _loc4_;
               updateTransform(param1);
            }
         }
         super.update(param1);
      }
      
      private function updateRange(param1:Number) : void
      {
         this._range = param1;
         if(this._range <= 0)
         {
            if(this.decal_maxRange.parent != null)
            {
               this.decal_maxRange.parent.removeChild(this.decal_maxRange);
            }
            return;
         }
         if(this.decal_maxRange.parent == null)
         {
            asset.addChild(this.decal_maxRange);
         }
         var _loc2_:TextureMaterial = ResourceManager.getInstance().materials.getTextureMaterial("range-indicator",this.getTextureURI());
         _loc2_.alpha = 0.75;
         this.decal_maxRange.setMaterialToAllSurfaces(_loc2_);
         this.decal_maxRange.scaleX = this.decal_maxRange.scaleY = this._range * 2;
         assetInvalidated.dispatch(this);
      }
      
      private function updateMinRange(param1:Number) : void
      {
         this._minRange = param1;
         if(this._minRange <= 0)
         {
            if(this.decal_minRange.parent != null)
            {
               this.decal_minRange.parent.removeChild(this.decal_minRange);
            }
            return;
         }
         if(this.decal_minRange.parent == null)
         {
            asset.addChild(this.decal_minRange);
         }
         var _loc2_:Number = this._minRange * 2;
         var _loc3_:TextureMaterial = ResourceManager.getInstance().materials.getTextureMaterial("range-indicator","images/ui/range-indicator-minrange.png");
         _loc3_.alpha = 0.75;
         this.decal_minRange.setMaterialToAllSurfaces(_loc3_);
         this.decal_minRange.scaleX = this.decal_minRange.scaleY = _loc2_;
         assetInvalidated.dispatch(this);
      }
      
      private function updateMinEffectiveRange(param1:Number) : void
      {
         var _loc3_:TextureMaterial = null;
         this._minEffectiveRange = param1;
         if(this._minEffectiveRange <= 0)
         {
            if(this.decal_minEffRange.parent != null)
            {
               this.decal_minEffRange.parent.removeChild(this.decal_minEffRange);
            }
            return;
         }
         if(this.decal_minEffRange.parent == null)
         {
            asset.addChild(this.decal_minEffRange);
         }
         var _loc2_:Number = this._minEffectiveRange * 2;
         _loc3_ = ResourceManager.getInstance().materials.getTextureMaterial("range-indicator","images/ui/range-indicator-small-red.png");
         _loc3_.alpha = 0.75;
         this.decal_minEffRange.setMaterialToAllSurfaces(_loc3_);
         this.decal_minEffRange.scaleX = this.decal_minEffRange.scaleY = _loc2_;
         assetInvalidated.dispatch(this);
      }
      
      private function getTextureURI() : String
      {
         var _loc1_:* = null;
         var _loc2_:Number = this._range * 2;
         if(_loc2_ > 2000)
         {
            _loc1_ = "large";
         }
         else if(_loc2_ <= 500)
         {
            _loc1_ = "extrasmall";
         }
         else
         {
            _loc1_ = "small";
         }
         if(this._yellow)
         {
            _loc1_ += "-yellow";
         }
         return "images/ui/range-indicator-" + _loc1_ + ".png";
      }
      
      public function get entity() : GameEntity
      {
         return this._entity;
      }
      
      public function set entity(param1:GameEntity) : void
      {
         this._entity = param1;
      }
      
      public function get range() : Number
      {
         return this._range;
      }
      
      public function set range(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this.updateRange(param1);
      }
      
      public function get minRange() : Number
      {
         return this._minRange;
      }
      
      public function set minRange(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this.updateMinRange(param1);
      }
      
      public function get minEffectiveRange() : Number
      {
         return this._minEffectiveRange;
      }
      
      public function set minEffectiveRange(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this.updateMinEffectiveRange(param1);
      }
      
      public function get yellow() : Boolean
      {
         return this._yellow;
      }
      
      public function set yellow(param1:Boolean) : void
      {
         if(param1 == this._yellow)
         {
            return;
         }
         this._yellow = param1;
         this.updateRange(this._range);
      }
   }
}

