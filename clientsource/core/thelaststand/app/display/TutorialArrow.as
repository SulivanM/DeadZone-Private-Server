package thelaststand.app.display
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.engine.objects.GameEntity;
   
   public class TutorialArrow extends Sprite
   {
      
      public static const RIGHT:Number = 0;
      
      public static const LEFT:Number = 180;
      
      public static const UP:Number = -90;
      
      public static const DOWN:Number = 90;
      
      private var _target:Object;
      
      private var _offset:Point;
      
      private var _rotation:Number = 0;
      
      private var bmp_arrow:Bitmap;
      
      private var mc_container:Sprite;
      
      public function TutorialArrow(param1:Object, param2:Number = 0, param3:Point = null)
      {
         super();
         this._offset = param3;
         this._target = param1;
         this._rotation = param2;
         mouseEnabled = mouseChildren = false;
         this.mc_container = new Sprite();
         this.mc_container.rotation = this._rotation;
         addChild(this.mc_container);
         this.bmp_arrow = new Bitmap(new BmpTutorialArrow(),"auto",true);
         this.bmp_arrow.x = -this.bmp_arrow.width;
         this.bmp_arrow.y = -int(this.bmp_arrow.height * 0.5);
         this.bmp_arrow.filters = [new DropShadowFilter(2,45,0,0.8,10,10,1,1)];
         this.mc_container.addChild(this.bmp_arrow);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_arrow.bitmapData.dispose();
         this.bmp_arrow.bitmapData = null;
         this.bmp_arrow = null;
         this._target = null;
         this._offset = null;
      }
      
      private function update(param1:Event) : void
      {
         var _loc2_:Point = null;
         var _loc5_:DisplayObject = null;
         var _loc6_:Point = null;
         var _loc7_:Object3D = null;
         var _loc8_:BoundBox = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Vector3D = null;
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         if(this._target is DisplayObject)
         {
            _loc5_ = DisplayObject(this._target);
            if(_loc5_.parent == null)
            {
               return;
            }
            _loc6_ = parent.globalToLocal(_loc5_.parent.localToGlobal(new Point(_loc5_.x,_loc5_.y)));
            _loc3_ = _loc6_.x;
            _loc4_ = _loc6_.y;
         }
         else if(this._target is Point)
         {
            _loc3_ = Number(this._target.x);
            _loc4_ = Number(this._target.y);
         }
         else if(this._target is GameEntity)
         {
            if(this._target.scene == null)
            {
               return;
            }
            _loc7_ = this._target.asset.getChildByName("meshEntity") != null ? this._target.asset.getChildByName("meshEntity") : this._target.asset;
            if(_loc7_ == null)
            {
               return;
            }
            _loc8_ = _loc7_.boundBox;
            if(_loc8_ == null)
            {
               return;
            }
            _loc9_ = _loc8_.maxX - _loc8_.minX;
            _loc10_ = _loc8_.maxY - _loc8_.minY;
            _loc11_ = _loc8_.maxZ - _loc8_.minZ;
            _loc12_ = this._target.asset.matrix.deltaTransformVector(new Vector3D(_loc8_.minX + _loc9_ * 0.5,_loc8_.minY + _loc10_ * 0.5,_loc8_.minZ + _loc11_ * 0.5));
            _loc2_ = this._target.scene.getScreenPosition(this._target.transform.position.x + _loc12_.x,this._target.transform.position.y + _loc12_.y,this._target.transform.position.z + _loc12_.z);
            x = _loc2_.x;
            y = _loc2_.y;
         }
         if(this._offset != null)
         {
            _loc3_ += this._offset.x;
            _loc4_ += this._offset.y;
         }
         this.mc_container.x = _loc3_;
         this.mc_container.y = _loc4_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.update,false,0,true);
         this.update(null);
         this.bmp_arrow.x = -this.bmp_arrow.width;
         TweenMax.to(this.bmp_arrow,1,{
            "x":"-20",
            "yoyo":true,
            "repeat":-1,
            "ease":Cubic.easeInOut
         });
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.update);
         TweenMax.killTweensOf(this.bmp_arrow);
      }
      
      override public function get rotation() : Number
      {
         return this._rotation;
      }
      
      override public function set rotation(param1:Number) : void
      {
         this._rotation = param1;
         this.mc_container.rotation = this._rotation;
      }
      
      public function get target() : Object
      {
         return this._target;
      }
      
      public function set target(param1:Object) : void
      {
         this._target = param1;
      }
      
      public function get offset() : Point
      {
         return this._offset;
      }
      
      public function set offset(param1:Point) : void
      {
         this._offset = param1;
      }
   }
}

