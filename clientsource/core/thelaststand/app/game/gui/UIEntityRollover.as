package thelaststand.app.game.gui
{
   import alternativa.engine3d.core.BoundBox;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.utils.BoundingBoxUtils;
   
   public class UIEntityRollover extends Sprite
   {
      
      private const MIN_SIZE:int = 80;
      
      private const MAX_SIZE:int = 140;
      
      private const CORNER_SIZE:int = 14;
      
      private var _targetPoint:Vector3D;
      
      private var _bounds:BoundBox;
      
      private var _entity:GameEntity;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _showBuildingAssignments:Boolean = true;
      
      private var _label:String;
      
      private var mc_border:Shape;
      
      private var txt_label:BodyTextField;
      
      public function UIEntityRollover()
      {
         super();
         mouseEnabled = mouseChildren = false;
         visible = true;
         this._targetPoint = new Vector3D();
         this._bounds = new BoundBox();
         this.mc_border = new Shape();
         this.mc_border.filters = [Effects.STROKE];
         addChild(this.mc_border);
         this.txt_label = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":12,
            "bold":true,
            "align":"center",
            "multiline":true,
            "width":140,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_label);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.mc_border.filters = [];
         this.txt_label.dispose();
         this._targetPoint = null;
         this._bounds = null;
         TweenMax.killChildTweensOf(this);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function draw(param1:int, param2:int, param3:Number = 1) : void
      {
         if(param1 < this.MIN_SIZE)
         {
            param1 = this.MIN_SIZE;
         }
         if(param1 > this.MAX_SIZE)
         {
            param1 = this.MAX_SIZE;
         }
         if(param2 < this.MIN_SIZE)
         {
            param2 = this.MIN_SIZE;
         }
         if(param2 > this.MAX_SIZE)
         {
            param2 = this.MAX_SIZE;
         }
         param1 *= param3;
         param2 *= param3;
         if(this._width == param1 && this._height == param2)
         {
            return;
         }
         var _loc4_:int = this.CORNER_SIZE * param3;
         var _loc5_:Graphics = this.mc_border.graphics;
         _loc5_.clear();
         _loc5_.beginFill(16777215);
         _loc5_.drawRect(0,0,param1,param2);
         _loc5_.drawRect(1,1,param1 - 2,param2 - 2);
         _loc5_.drawRect(0,_loc4_,1,param2 - _loc4_ * 2);
         _loc5_.drawRect(param1 - 1,_loc4_,1,param2 - _loc4_ * 2);
         _loc5_.drawRect(_loc4_,0,param1 - _loc4_ * 2,1);
         _loc5_.drawRect(_loc4_,param2 - 1,param1 - _loc4_ * 2,1);
         _loc5_.endFill();
         this._width = param1;
         this._height = param2;
      }
      
      private function calculateSizeAndPosition() : void
      {
         if(this._entity == null || this._entity.scene == null || this._entity.asset == null)
         {
            return;
         }
         BoundingBoxUtils.transformBounds(this._entity.asset,this._entity.asset.matrix,this._bounds);
         var _loc1_:Number = this._bounds.maxX - this._bounds.minX;
         var _loc2_:Number = this._bounds.maxY - this._bounds.minY;
         var _loc3_:Number = this._bounds.maxZ - this._bounds.minZ;
         var _loc4_:int = (_loc1_ + _loc2_) * 0.25;
         var _loc5_:int = _loc3_ * 0.375;
         this.draw(_loc4_,_loc5_,this._entity.scene.getCurrentZoom());
         this._targetPoint.x = this._bounds.minX + _loc1_ * 0.5;
         this._targetPoint.y = this._bounds.minY + _loc2_ * 0.5;
         this._targetPoint.z = this._bounds.minZ + _loc5_ * 0.5;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._entity == null || this._entity.scene == null || this._targetPoint == null)
         {
            return;
         }
         var _loc2_:Number = this._entity.transform.position.x + this._targetPoint.x;
         var _loc3_:Number = this._entity.transform.position.y + this._targetPoint.y;
         var _loc4_:Number = this._entity.transform.position.z + this._targetPoint.z;
         var _loc5_:Point = this._entity.scene.getScreenPosition(_loc2_,_loc3_,_loc4_);
         x = int(_loc5_.x - this._width * 0.5);
         y = int(_loc5_.y - this._height * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._entity != null)
         {
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      public function get entity() : GameEntity
      {
         return this._entity;
      }
      
      public function set entity(param1:GameEntity) : void
      {
         var _loc2_:Building = null;
         if(param1 == this._entity)
         {
            return;
         }
         if(this._entity is BuildingEntity)
         {
            BuildingEntity(this._entity).hideAssignPositions();
         }
         this._entity = param1;
         TweenMax.killTweensOf(this.mc_border);
         if(this._entity != null)
         {
            this.calculateSizeAndPosition();
            addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
            this.onEnterFrame(null);
            if(this._showBuildingAssignments)
            {
               if(this._entity is BuildingEntity)
               {
                  _loc2_ = BuildingEntity(this._entity).buildingData;
                  if(_loc2_.maxHealth == 0 || _loc2_.health > 0)
                  {
                     BuildingEntity(this._entity).showAssignPosition();
                  }
               }
            }
            this.mc_border.x = this.mc_border.y = 0;
            this.mc_border.scaleX = this.mc_border.scaleY = 1;
            TweenMax.from(this.mc_border,0.15,{
               "transformAroundCenter":{
                  "scaleX":1.2,
                  "scaleY":1.2
               },
               "ease":Quad.easeOut
            });
            this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
            this.txt_label.y = -int(this.txt_label.height + 38);
         }
         else
         {
            removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      public function get showBuildingAssignments() : Boolean
      {
         return this._showBuildingAssignments;
      }
      
      public function set showBuildingAssignments(param1:Boolean) : void
      {
         this._showBuildingAssignments = param1;
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.txt_label.htmlText = (this._label || "").toUpperCase();
         this.txt_label.visible = this._label != null;
      }
   }
}

