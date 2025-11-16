package thelaststand.app.game.entities.gui
{
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import com.greensock.easing.Quad;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class UIMovementTarget extends GameEntity
   {
      
      public static const STATE_LEGAL:String = "legal";
      
      public static const STATE_ILLEGAL:String = "illegal";
      
      private var _material:TextureMaterial;
      
      private var _asset:Decal;
      
      private var _state:String;
      
      private var _size:int = 120;
      
      public function UIMovementTarget(param1:String)
      {
         super();
         this.asset = this._asset = new Decal();
         this._asset.geometry = Primitives.SIMPLE_PLANE.geometry;
         this._asset.addSurface(null,0,2);
         this._asset.mouseEnabled = this._asset.mouseChildren = false;
         this.state = param1;
         this.asset.visible = true;
      }
      
      override public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(transform.scale);
         TweenMaxDelta.killTweensOf(this._material);
         super.dispose();
      }
      
      public function pulse(param1:Boolean = true) : void
      {
         var _loc2_:Number = 0.25;
         transform.setScaleUniform(0);
         updateTransform();
         TweenMaxDelta.to(transform.scale,_loc2_,{
            "x":this._size,
            "y":this._size,
            "ease":Quad.easeOut,
            "onUpdate":updateTransform
         });
         this._material.alpha = 1;
         TweenMaxDelta.to(this._material,_loc2_,{
            "delay":_loc2_,
            "alpha":0,
            "onComplete":(param1 ? this.dispose : null)
         });
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      public function set state(param1:String) : void
      {
         this._state = param1;
         this._material = ResourceManager.getInstance().materials.getTextureMaterial("movement-indicator","images/ui/movement-" + this._state + "-indicator.png");
         this._asset.setMaterialToAllSurfaces(this._material);
      }
   }
}

