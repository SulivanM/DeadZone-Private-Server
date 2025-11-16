package thelaststand.app.game.gui.compound
{
   import alternativa.engine3d.core.BoundBox;
   import com.greensock.TweenMax;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TextFieldTyper;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.task.JunkRemovalTask;
   import thelaststand.app.game.entities.buildings.BuildingEntity;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.engine.utils.BoundingBoxUtils;
   
   public class UIConstructionProgress extends Sprite
   {
      
      private var _width:int = 52;
      
      private var _height:int = 7;
      
      private var _building:Building;
      
      private var _targetPos:Vector3D = new Vector3D();
      
      private var mc_bar:Shape;
      
      private var mc_track:Shape;
      
      private var txt_label:BodyTextField;
      
      public function UIConstructionProgress(param1:Building)
      {
         super();
         mouseEnabled = mouseChildren = false;
         this._building = param1;
         this.mc_track = new Shape();
         this.mc_track.graphics.beginFill(4079166);
         this.mc_track.graphics.drawRect(0,0,this._width,this._height);
         this.mc_track.graphics.endFill();
         this.mc_track.graphics.beginFill(0);
         this.mc_track.graphics.drawRect(1,1,this._width - 2,this._height - 2);
         this.mc_track.graphics.endFill();
         this.mc_track.scale9Grid = new Rectangle(1,1,this._width - 2,this._height - 2);
         this.mc_bar = new Shape();
         this.mc_bar.graphics.beginFill(10878976);
         this.mc_bar.graphics.drawRect(0,0,this._width - 4,this._height - 4);
         this.mc_bar.graphics.endFill();
         this.mc_bar.x = this.mc_bar.y = 2;
         this.txt_label = new BodyTextField({
            "color":14869218,
            "size":11,
            "bold":true,
            "autoSize":"center",
            "align":"center"
         });
         this.txt_label.filters = [Effects.STROKE];
         this.txt_label.text = " ";
         this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
         this.txt_label.y = int(-this.txt_label.height);
         addChild(this.mc_track);
         addChild(this.mc_bar);
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
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._building = null;
         this._targetPos = null;
         this.txt_label.dispose();
         this.txt_label = null;
      }
      
      public function updateLabel() : String
      {
         var _loc3_:Task = null;
         if(this._building == null)
         {
            return "";
         }
         var _loc1_:String = "";
         var _loc2_:Language = Language.getInstance();
         if(this._building.repairTimer != null)
         {
            if(this._building.productionResource != null)
            {
               _loc1_ = _loc2_.getString("bld_restocking");
            }
            else
            {
               _loc1_ = _loc2_.getString("bld_repairing");
            }
         }
         else if(this._building.upgradeTimer != null)
         {
            _loc1_ = this._building.isUnderConstruction() ? _loc2_.getString("bld_building") : _loc2_.getString("bld_upgrading");
         }
         else if(this._building.tasks.length > 0)
         {
            _loc3_ = this._building.tasks[0];
            if(_loc3_.survivors.length == 0)
            {
               _loc1_ = _loc2_.getString("bld_onhold");
            }
            else if(_loc3_ is JunkRemovalTask)
            {
               _loc1_ = _loc2_.getString("bld_removing");
            }
         }
         else if(this._building.type == "recycler")
         {
            _loc1_ = _loc2_.getString("bld_recycling");
         }
         this.txt_label.text = _loc1_.toUpperCase();
         this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
         return _loc1_.toUpperCase();
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
         this._targetPos.z = _loc1_.transform.position.z + _loc2_.minZ + _loc5_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var _loc2_:TextFieldTyper = null;
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.calculate3DPosition();
         this.onEnterFrame(null);
         if(this._building != null)
         {
            if(this._building.entity != null)
            {
               this._building.entity.assetInvalidated.add(this.onBuildingAssetInvalidated);
            }
            this.mc_track.scaleX = 0;
            this.mc_bar.alpha = 0;
            this.mc_track.x = int(this._width * 0.5);
            TweenMax.to(this.mc_track,0.25,{
               "x":0,
               "scaleX":1,
               "overwrite":true
            });
            TweenMax.to(this.mc_bar,0.1,{
               "delay":0.25,
               "alpha":1,
               "overwrite":true
            });
            _loc2_ = new TextFieldTyper(this.txt_label);
            _loc2_.type(this.updateLabel(),30);
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
         var _loc4_:BatchRecycleJob = null;
         if(this._building == null)
         {
            return;
         }
         var _loc2_:BuildingEntity = this._building.buildingEntity;
         if(_loc2_ == null || _loc2_.scene == null || _loc2_.asset == null)
         {
            return;
         }
         var _loc3_:Point = _loc2_.scene.getScreenPosition(this._targetPos.x,this._targetPos.y,this._targetPos.z);
         x = int(_loc3_.x - this._width * 0.5);
         y = int(_loc3_.y);
         if(this._building.repairTimer != null)
         {
            this.mc_bar.scaleX = this._building.repairTimer.getProgress();
         }
         else if(this._building.upgradeTimer != null)
         {
            this.mc_bar.scaleX = this._building.upgradeTimer.getProgress();
         }
         else if(this._building.tasks.length > 0)
         {
            this.mc_bar.scaleX = Math.min(this._building.tasks[0].time / this._building.tasks[0].length,1);
         }
         else if(this._building.type == "recycler")
         {
            _loc4_ = Network.getInstance().playerData.batchRecycleJobs.getJob(0);
            if(_loc4_ != null && _loc4_.timer != null)
            {
               this.mc_bar.scaleX = _loc4_.timer.getProgress();
            }
         }
      }
      
      private function onBuildingAssetInvalidated(param1:BuildingEntity) : void
      {
         this.calculate3DPosition();
      }
      
      public function get building() : Building
      {
         return this._building;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

