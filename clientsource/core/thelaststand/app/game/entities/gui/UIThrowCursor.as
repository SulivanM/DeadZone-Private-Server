package thelaststand.app.game.entities.gui
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import com.greensock.easing.Back;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class UIThrowCursor extends GameEntity
   {
      
      private var _range:Number;
      
      private var _mtlDot:TextureMaterial;
      
      private var _mtlDotRed:TextureMaterial;
      
      private var _mtlRange:TextureMaterial;
      
      private var _mtlRangeRed:TextureMaterial;
      
      private var _valid:Boolean = true;
      
      private var decal_dot:Decal;
      
      private var decal_range:Decal;
      
      public function UIThrowCursor(param1:Number = 0)
      {
         super();
         asset = new Object3D();
         asset.mouseEnabled = asset.mouseChildren = false;
         asset.visible = true;
         this._mtlDot = ResourceManager.getInstance().materials.getTextureMaterial("throw-range-dot","images/ui/active-dot.png");
         this._mtlDotRed = ResourceManager.getInstance().materials.getTextureMaterial("throw-range-dot-red","images/ui/movement-illegal-indicator.png");
         this._mtlRange = ResourceManager.getInstance().materials.getTextureMaterial("throw-range-ring","images/ui/active-circle.png");
         this._mtlRangeRed = ResourceManager.getInstance().materials.getTextureMaterial("throw-range-ring-red","images/ui/active-circle-red.png");
         this.decal_dot = new Decal();
         this.decal_dot.geometry = Primitives.SIMPLE_PLANE.geometry;
         this.decal_dot.scaleX = this.decal_dot.scaleY = 30;
         this.decal_dot.scaleZ = 1;
         this.decal_dot.z = 2;
         this.decal_dot.addSurface(null,0,2);
         this.decal_dot.setMaterialToAllSurfaces(this._mtlDot);
         asset.addChild(this.decal_dot);
         this.decal_range = new Decal();
         this.decal_range.geometry = Primitives.SIMPLE_PLANE.geometry;
         this.decal_range.addSurface(null,0,2);
         this.updateRange(param1);
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(this.decal_range);
         super.dispose();
         this.decal_range.setMaterialToAllSurfaces(null);
         this.decal_range.geometry = null;
      }
      
      public function transitionIn() : void
      {
         var _loc1_:Number = NaN;
         if(this.decal_range.parent != null)
         {
            _loc1_ = this._range * 2;
            this.decal_range.scaleX = this.decal_range.scaleY = 0;
            TweenMaxDelta.to(this.decal_range,0.4,{
               "scaleX":_loc1_,
               "scaleY":_loc1_,
               "overwrite":true,
               "ease":Back.easeOut,
               "easeParams":[0.75]
            });
         }
      }
      
      override public function update(param1:Number = 1) : void
      {
         updateTransform(param1);
         super.update(param1);
      }
      
      private function updateRange(param1:Number) : void
      {
         this._range = param1;
         if(this._range <= 0)
         {
            if(this.decal_range.parent != null)
            {
               this.decal_range.parent.removeChild(this.decal_range);
            }
            return;
         }
         if(this.decal_range.parent == null)
         {
            asset.addChild(this.decal_range);
         }
         this.decal_range.setMaterialToAllSurfaces(this._valid ? this._mtlRange : this._mtlRangeRed);
         this.decal_range.scaleX = this.decal_range.scaleY = this.range;
         assetInvalidated.dispatch(this);
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
      
      public function get valid() : Boolean
      {
         return this._valid;
      }
      
      public function set valid(param1:Boolean) : void
      {
         if(param1 == this._valid)
         {
            return;
         }
         this._valid = param1;
         this.decal_dot.setMaterialToAllSurfaces(this._valid ? this._mtlDot : this._mtlDotRed);
         this.decal_dot.scaleX = this.decal_dot.scaleY = this._valid ? 30 : 60;
         this.decal_range.setMaterialToAllSurfaces(this._valid ? this._mtlRange : this._mtlRangeRed);
         assetInvalidated.dispatch(this);
      }
   }
}

