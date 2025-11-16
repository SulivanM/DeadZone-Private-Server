package thelaststand.app.game.gui.compound
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   
   public class UIBuildingIcon extends Sprite
   {
      
      private var _building:Building;
      
      private var _iconClass:Class;
      
      private var _zOffset:Number = 0;
      
      private var bmp_icon:Bitmap;
      
      public function UIBuildingIcon(param1:Building, param2:Class, param3:Number = 0)
      {
         super();
         this._building = param1;
         this._zOffset = param3;
         mouseEnabled = mouseChildren = false;
         this.bmp_icon = new Bitmap();
         addChild(this.bmp_icon);
         this.iconClass = param2;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._building != null && this._building.entity != null)
         {
            this._building.entity.assetInvalidated.remove(this.onBuildingAssetInvalidated);
         }
         this._building = null;
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
            this.bmp_icon.bitmapData = null;
         }
         this.bmp_icon = null;
         this._iconClass = null;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.onEnterFrame(null);
         if(this._building != null && this._building.entity != null)
         {
            this._building.entity.assetInvalidated.add(this.onBuildingAssetInvalidated);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         if(this._building != null && this._building.entity != null)
         {
            this._building.entity.assetInvalidated.remove(this.onBuildingAssetInvalidated);
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._building == null)
         {
            return;
         }
         var _loc2_:BuildingEntity = this._building.buildingEntity;
         if(_loc2_ == null || _loc2_.scene == null || _loc2_.asset == null)
         {
            return;
         }
         var _loc3_:Number = _loc2_.transform.position.x + _loc2_.centerPoint.x;
         var _loc4_:Number = _loc2_.transform.position.y + _loc2_.centerPoint.y;
         var _loc5_:Number = _loc2_.transform.position.z + _loc2_.centerPoint.z + this._zOffset;
         var _loc6_:Point = _loc2_.scene.getScreenPosition(_loc3_,_loc4_,_loc5_);
         x = _loc6_.x;
         y = _loc6_.y;
      }
      
      private function onBuildingAssetInvalidated(param1:BuildingEntity) : void
      {
      }
      
      public function get building() : Building
      {
         return this._building;
      }
      
      public function get iconClass() : Class
      {
         return this._iconClass;
      }
      
      public function set iconClass(param1:Class) : void
      {
         this._iconClass = param1;
         if(this.bmp_icon != null && this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
         }
         this.bmp_icon.bitmapData = new this._iconClass();
         this.bmp_icon.x = -int(this.bmp_icon.width * 0.5);
         this.bmp_icon.y = -int(this.bmp_icon.height * 0.5);
      }
   }
}

