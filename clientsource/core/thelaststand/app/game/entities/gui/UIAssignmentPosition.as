package thelaststand.app.game.entities.gui
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import alternativa.engine3d.objects.Sprite3D;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import com.greensock.easing.Cubic;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.common.utils.BitmapUtils;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class UIAssignmentPosition extends Object3D
   {
      
      private static var MATERIAL_ARROW:TextureMaterial;
      
      private static var MATERIAL_CIRCLE_UNASSIGNED:TextureMaterial;
      
      private static var MATERIAL_CIRCLE_ASSIGNED:TextureMaterial;
      
      private var _assigned:Boolean;
      
      private var spr_marker:Sprite3D;
      
      private var dcl_marker:Decal;
      
      public function UIAssignmentPosition()
      {
         super();
         if(MATERIAL_ARROW == null)
         {
            MATERIAL_ARROW = new TextureMaterial(new BitmapTextureResource(BitmapUtils.resizeToPowerOf2(new BmpTutorialArrow())));
            MATERIAL_ARROW.alphaThreshold = 0.9;
            MATERIAL_ARROW.transparentPass = true;
            MATERIAL_ARROW.alpha = 0.5;
         }
         if(MATERIAL_CIRCLE_UNASSIGNED == null)
         {
            MATERIAL_CIRCLE_UNASSIGNED = new TextureMaterial(ResourceManager.getInstance().materials.getBitmapTextureResource("images/ui/selected-indicator.png"));
            MATERIAL_CIRCLE_UNASSIGNED.alphaThreshold = 0.9;
            MATERIAL_CIRCLE_UNASSIGNED.transparentPass = true;
         }
         if(MATERIAL_CIRCLE_ASSIGNED == null)
         {
            MATERIAL_CIRCLE_ASSIGNED = new TextureMaterial(ResourceManager.getInstance().materials.getBitmapTextureResource("images/ui/selected-indicator-aggressive.png"));
            MATERIAL_CIRCLE_ASSIGNED.alphaThreshold = 0.9;
            MATERIAL_CIRCLE_ASSIGNED.transparentPass = true;
         }
         mouseChildren = mouseEnabled = false;
         var _loc1_:Number = 104;
         var _loc2_:Number = 73;
         var _loc3_:Number = 2;
         this.spr_marker = new Sprite3D(_loc1_ * _loc3_,_loc2_ * _loc3_,MATERIAL_ARROW);
         this.spr_marker.rotation = Math.PI * 0.5;
         this.spr_marker.z = _loc1_ + 50;
         this.spr_marker.mouseChildren = false;
         this.spr_marker.mouseEnabled = false;
         addChild(this.spr_marker);
         this.dcl_marker = new Decal();
         this.dcl_marker.geometry = Primitives.SIMPLE_PLANE.geometry;
         this.dcl_marker.addSurface(MATERIAL_CIRCLE_UNASSIGNED,0,2);
         this.dcl_marker.scaleX = this.dcl_marker.scaleY = 100;
         this.dcl_marker.mouseChildren = false;
         this.dcl_marker.mouseEnabled = false;
         addChild(this.dcl_marker);
      }
      
      public function dispose() : void
      {
         TweenMaxDelta.killTweensOf(this.spr_marker);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeChildren();
         this.spr_marker.material = null;
         this.spr_marker = null;
         this.dcl_marker.setMaterialToAllSurfaces(null);
         this.dcl_marker.geometry = null;
         this.dcl_marker = null;
      }
      
      private function animateArrow() : void
      {
         this.spr_marker.z = this.spr_marker.width - 50;
         TweenMaxDelta.to(this.spr_marker,2,{
            "z":this.spr_marker.width,
            "ease":Cubic.easeInOut,
            "yoyo":true,
            "repeat":-1
         });
      }
      
      public function get assigned() : Boolean
      {
         return this._assigned;
      }
      
      public function set assigned(param1:Boolean) : void
      {
         this._assigned = param1;
         this.dcl_marker.setMaterialToAllSurfaces(this._assigned ? MATERIAL_CIRCLE_ASSIGNED : MATERIAL_CIRCLE_UNASSIGNED);
      }
      
      public function get showArrow() : Boolean
      {
         return this.spr_marker.visible;
      }
      
      public function set showArrow(param1:Boolean) : void
      {
         this.spr_marker.visible = param1;
         if(param1)
         {
            this.animateArrow();
         }
         else
         {
            TweenMaxDelta.killTweensOf(this.spr_marker);
         }
      }
   }
}

