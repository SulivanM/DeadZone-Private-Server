package thelaststand.app.game.entities.gui
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import com.greensock.easing.Cubic;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class UIDeploymentPip extends GameEntity
   {
      
      private static var _nextId:int = 0;
      
      private var _asset:Decal;
      
      private var _size:int = 100;
      
      private var _inCover:Boolean = false;
      
      public function UIDeploymentPip()
      {
         var _loc1_:TextureMaterial = null;
         super();
         name = "deploymentCursor" + _nextId++;
         _loc1_ = ResourceManager.getInstance().materials.getTextureMaterial("deployarea-indicator","images/ui/selected-indicator.png");
         this.asset = this._asset = new Decal();
         this._asset.geometry = Primitives.SIMPLE_PLANE.geometry;
         this._asset.addSurface(_loc1_,0,2);
         this._asset.scaleX = this._asset.scaleY = this._size;
         this._asset.mouseEnabled = this._asset.mouseChildren = false;
         transform.setScaleUniform(this._size);
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
      }
      
      public function get inCover() : Boolean
      {
         return this._inCover;
      }
      
      public function set inCover(param1:Boolean) : void
      {
         if(param1 == this._inCover)
         {
            return;
         }
         this._inCover = param1;
         var _loc2_:TextureMaterial = ResourceManager.getInstance().materials.getTextureMaterial("deployarea-indicator",this._inCover ? "images/ui/selected-indicator.png" : "images/ui/selected-indicator-aggressive.png");
         this._asset.setMaterialToAllSurfaces(_loc2_);
         assetInvalidated.dispatch(this);
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(transform.scale);
         super.dispose();
      }
      
      public function playPulseAnim() : void
      {
         transform.setScaleUniform(this._size);
         updateTransform();
         var _loc1_:Number = this._size + 100;
         TweenMaxDelta.to(transform.scale,2,{
            "x":_loc1_,
            "y":_loc1_,
            "yoyo":true,
            "repeat":-1,
            "overwrite":true,
            "onUpdate":updateTransform,
            "ease":Cubic.easeInOut
         });
      }
      
      public function playMarkAnim(param1:Function = null) : void
      {
         var onComplete:Function = param1;
         var s:Number = this._size + 120;
         TweenMaxDelta.to(transform.scale,0.25,{
            "x":s,
            "y":s,
            "ease":Cubic.easeInOut,
            "overwrite":true,
            "onUpdate":updateTransform,
            "onComplete":function():void
            {
               TweenMaxDelta.to(transform.scale,0.5,{
                  "x":_size * 0.75,
                  "y":_size * 0.75,
                  "ease":Cubic.easeInOut,
                  "onUpdate":updateTransform,
                  "onComplete":onComplete
               });
            }
         });
      }
   }
}

