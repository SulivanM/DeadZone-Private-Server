package thelaststand.app.game.gui.mission
{
   import alternativa.engine3d.core.BoundBox;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.game.gui.UISimpleProgressBar;
   import thelaststand.engine.utils.BoundingBoxUtils;
   
   public class UIBuildingIndicator extends Sprite
   {
      
      private const COLOR_BAD:uint = 15597568;
      
      private const COLOR_GOOD:uint = 5692748;
      
      private const COLOR_NEUTRAL:uint = 15921906;
      
      private const SEG_WIDTH:int = 4;
      
      private var _building:Building;
      
      private var _maxHealth:Number;
      
      private var _targetPos:Vector3D;
      
      private var ui_healthBar:UISimpleProgressBar;
      
      private var mc_segments:Shape;
      
      public function UIBuildingIndicator(param1:Building)
      {
         super();
         this._building = param1;
         this._maxHealth = this._building.maxHealth;
         this._targetPos = new Vector3D();
         var _loc2_:int = 3 + param1.level;
         this.ui_healthBar = new UISimpleProgressBar();
         this.ui_healthBar.width = _loc2_ * this.SEG_WIDTH - 1;
         this.ui_healthBar.x = -int(this.ui_healthBar.width * 0.5);
         this.ui_healthBar.y = -int(this.ui_healthBar.height);
         addChild(this.ui_healthBar);
         this.mc_segments = new Shape();
         this.mc_segments.x = this.ui_healthBar.x;
         this.mc_segments.y = this.ui_healthBar.y;
         var _loc3_:int = 1;
         while(_loc3_ < _loc2_)
         {
            this.mc_segments.graphics.beginFill(0,1);
            this.mc_segments.graphics.drawRect(_loc3_ * this.SEG_WIDTH - 1,0,1,this.ui_healthBar.height);
            this.mc_segments.graphics.endFill();
            _loc3_++;
         }
         addChild(this.mc_segments);
         visible = true;
         this.calculate3DPosition();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.ui_healthBar.dispose();
         this._building = null;
      }
      
      private function calculate3DPosition() : void
      {
         if(this._building == null)
         {
            return;
         }
         var _loc1_:BuildingEntity = this._building.buildingEntity;
         if(_loc1_ == null || _loc1_.scene == null || _loc1_.asset == null)
         {
            return;
         }
         var _loc2_:BoundBox = new BoundBox();
         BoundingBoxUtils.transformBounds(_loc1_.asset,_loc1_.asset.matrix,_loc2_);
         var _loc3_:Number = _loc2_.maxX - _loc2_.minX;
         var _loc4_:Number = _loc2_.maxY - _loc2_.minY;
         var _loc5_:Number = _loc2_.maxZ - _loc2_.minZ;
         this._targetPos.x = _loc1_.transform.position.x + _loc2_.minX + _loc3_ * 0.5;
         this._targetPos.y = _loc1_.transform.position.y + _loc2_.minY + _loc4_ * 0.5;
         this._targetPos.z = _loc1_.transform.position.z + _loc2_.minZ + _loc5_ * 0.6;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.onEnterFrame(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._building.entity.asset == null || this._building.entity.scene == null)
         {
            return;
         }
         var _loc2_:Point = this._building.entity.scene.getScreenPosition(this._targetPos.x,this._targetPos.y,this._targetPos.z);
         this.x = int(_loc2_.x);
         this.y = int(_loc2_.y);
         var _loc3_:Number = this._building.health / this._maxHealth;
         this.ui_healthBar.progress = _loc3_;
         this.ui_healthBar.colorBar = _loc3_ < 0.5 ? 15597568 : 5692748;
      }
   }
}

