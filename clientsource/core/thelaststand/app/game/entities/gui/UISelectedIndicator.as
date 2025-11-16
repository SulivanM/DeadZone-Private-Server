package thelaststand.app.game.entities.gui
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import com.greensock.easing.Back;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class UISelectedIndicator extends GameEntity
   {
      
      private static var MATERIAL_NORMAL:TextureMaterial;
      
      private static var MATERIAL_AGGRESSIVE:TextureMaterial;
      
      private static var _nextId:int = 0;
      
      public static const MODE_NORMAL:String = "modeNormal";
      
      public static const MODE_AGGRESSIVE:String = "modeAggressive";
      
      private var _alpha:Number = 1;
      
      private var _mode:String = "modeNormal";
      
      private var _material:TextureMaterial;
      
      private var _asset:Decal;
      
      private var _size:int = 150;
      
      public function UISelectedIndicator()
      {
         super();
         if(MATERIAL_NORMAL == null)
         {
            MATERIAL_NORMAL = ResourceManager.getInstance().materials.getTextureMaterial("selected-indicator","images/ui/selected-indicator.png");
         }
         if(MATERIAL_AGGRESSIVE == null)
         {
            MATERIAL_AGGRESSIVE = ResourceManager.getInstance().materials.getTextureMaterial("selected-indicator","images/ui/selected-indicator-aggressive.png");
         }
         name = "selectedIndicator" + _nextId++;
         this._material = MATERIAL_NORMAL;
         this.asset = this._asset = new Decal();
         this._asset.geometry = Primitives.SIMPLE_PLANE.geometry;
         this._asset.addSurface(this._material,0,2);
         this._asset.scaleX = this._asset.scaleY = this._asset.scaleZ = this._size;
         this._asset.mouseEnabled = this._asset.mouseChildren = false;
         this.asset.visible = true;
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(transform.scale);
         this._asset.geometry.dispose();
         this._material = null;
         super.dispose();
      }
      
      public function transitionIn() : void
      {
         var _loc1_:Number = 0.2;
         this._material.alpha = this._alpha;
         transform.setScaleUniform(0);
         updateTransform();
         TweenMaxDelta.to(transform.scale,0.4,{
            "x":this._size,
            "y":this._size,
            "overwrite":true,
            "onUpdate":updateTransform,
            "ease":Back.easeOut,
            "easeParams":[0.75]
         });
      }
      
      public function transitionOut(param1:Function = null) : void
      {
         TweenMaxDelta.to(transform.scale,0.3,{
            "x":0,
            "y":0,
            "ease":Back.easeIn,
            "easeParams":[0.75],
            "overwrite":true,
            "onUpdate":updateTransform,
            "onComplete":param1
         });
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._alpha = param1;
         this._material.alpha = this._alpha;
      }
      
      public function get mode() : String
      {
         return this._mode;
      }
      
      public function set mode(param1:String) : void
      {
         if(param1 == this._mode)
         {
            return;
         }
         this._mode = param1;
         this._material = this._mode == MODE_AGGRESSIVE ? MATERIAL_AGGRESSIVE : MATERIAL_NORMAL;
         this._material.alpha = this._alpha;
         this._asset.scaleX = this._asset.scaleY = this._size * 0.75;
         TweenMaxDelta.to(this._asset,0.4,{
            "scaleX":this._size,
            "scaleY":this._size,
            "ease":Back.easeOut,
            "easeParams":[0.75]
         });
         if(this._asset != null)
         {
            this._asset.setMaterialToAllSurfaces(this._material);
            assetInvalidated.dispatch(this);
         }
      }
   }
}

