package thelaststand.app.game.gui.mission
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CoverData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.actors.Actor;
   import thelaststand.app.game.gui.survivor.UISurvivorHealthBarLarge;
   import thelaststand.app.game.logic.ai.AIAgentFlags;
   import thelaststand.app.gui.UICircleProgress;
   
   public class UISurvivorIndicator extends Sprite
   {
      
      private const COLOR_BAD:uint = 15597568;
      
      private const COLOR_GOOD:uint = 5692748;
      
      private const COLOR_NEUTRAL:uint = 15921906;
      
      private var _survivor:Survivor;
      
      private var _maxHealth:Number;
      
      private var _coverRating:int;
      
      private var bmp_healing:Bitmap;
      
      private var bmp_cover:Bitmap;
      
      private var mc_healthBar:UISurvivorHealthBarLarge;
      
      private var mc_reloadProgress:UICircleProgress;
      
      private var mc_suppression:UISuppressedIndicator;
      
      private var mc_healing:UIHealingParticles;
      
      private var txt_name:BodyTextField;
      
      private var ui_ammo:UIAmmoCapacity;
      
      public function UISurvivorIndicator(param1:Survivor)
      {
         super();
         this._survivor = param1;
         this._survivor.reloadStarted.add(this.onReloadStarted);
         this._survivor.reloadCompleted.add(this.onReloadCompletedOrInterrupted);
         this._survivor.reloadInterrupted.add(this.onReloadCompletedOrInterrupted);
         this._survivor.agentData.coverRatingChanged.add(this.onCoverRatingChanged);
         this._survivor.healthChanged.add(this.onHealthChanged);
         this._maxHealth = this._survivor.maxHealth;
         mouseEnabled = mouseChildren = false;
         this.bmp_healing = new Bitmap(new BmpIconHealing());
         this.bmp_healing.x = -int(this.bmp_healing.width * 0.5);
         this.bmp_cover = new Bitmap();
         var _loc2_:int = 0;
         if(!this._survivor.weaponData.isMelee && this._survivor.weaponData.capacity > 0)
         {
            this.ui_ammo = new UIAmmoCapacity();
            this.ui_ammo.weaponData = this._survivor.weaponData;
            this.ui_ammo.x = -int(this.ui_ammo.width * 0.5);
            this.ui_ammo.y = -int(this.ui_ammo.height);
            addChild(this.ui_ammo);
            _loc2_ = this.ui_ammo.y - 2;
         }
         this.mc_healthBar = new UISurvivorHealthBarLarge(this._survivor);
         this.mc_healthBar.width = 40;
         this.mc_healthBar.x = -int(this.mc_healthBar.width * 0.5);
         this.mc_healthBar.y = _loc2_ - int(this.mc_healthBar.height);
         addChild(this.mc_healthBar);
         this.mc_healing = new UIHealingParticles();
         this.mc_healing.y = int(this.mc_healthBar.y - 6);
         this.txt_name = new BodyTextField({
            "color":this.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_name.text = this._survivor.fullName;
         this.txt_name.x = -int(this.txt_name.width * 0.5);
         this.txt_name.y = int(this.mc_healthBar.y - this.txt_name.height - 1);
         this.txt_name.filters = [Effects.STROKE];
         addChild(this.txt_name);
         this.mc_reloadProgress = new UICircleProgress(13500416,4210752,8);
         this.mc_suppression = new UISuppressedIndicator(this._survivor);
         this.mc_suppression.updatePosition = false;
         visible = true;
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
         this.mc_healthBar.dispose();
         this.mc_healthBar = null;
         this.mc_reloadProgress.dispose();
         this.mc_reloadProgress = null;
         this.mc_suppression.dispose();
         this.mc_suppression = null;
         this.mc_healing.dispose();
         this.mc_healing = null;
         this.bmp_healing.bitmapData.dispose();
         this.bmp_healing.bitmapData = null;
         this.bmp_healing = null;
         this.bmp_cover.bitmapData = null;
         this.bmp_cover = null;
         if(this.ui_ammo != null)
         {
            this.ui_ammo.dispose();
         }
         this._survivor.reloadStarted.remove(this.onReloadStarted);
         this._survivor.reloadCompleted.remove(this.onReloadCompletedOrInterrupted);
         this._survivor.reloadInterrupted.remove(this.onReloadCompletedOrInterrupted);
         this._survivor.agentData.coverRatingChanged.remove(this.onCoverRatingChanged);
         this._survivor.healthChanged.remove(this.onHealthChanged);
         this._survivor = null;
      }
      
      private function updateCoverDisplay() : void
      {
         this.bmp_cover.visible = this.txt_name.visible;
         this._coverRating = this._survivor.agentData.coverRating;
         if(this._coverRating > 0)
         {
            this.bmp_cover.bitmapData = CoverData.getCoverIconSmall(this._coverRating);
            addChild(this.bmp_cover);
         }
         else if(this.bmp_cover.parent != null)
         {
            this.bmp_cover.parent.removeChild(this.bmp_cover);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.updateCoverDisplay();
         this.onEnterFrame(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(!this.mc_healthBar.visible && !this.txt_name.visible && !this.mc_reloadProgress)
         {
            return;
         }
         var _loc2_:Actor = this._survivor.actor;
         if(_loc2_.scene == null)
         {
            return;
         }
         var _loc3_:Vector3D = _loc2_.transform.position;
         var _loc4_:Point = _loc2_.scene.getScreenPosition(_loc3_.x,_loc3_.y,_loc3_.z + _loc2_.getHeight() + 50);
         this.x = int(_loc4_.x);
         this.y = int(_loc4_.y);
         if(this._survivor.agentData.reloading)
         {
            this.mc_reloadProgress.progress = this._survivor.agentData.reloadProgress;
            this.mc_suppression.visible = false;
            if(this.txt_name.visible)
            {
               this.mc_reloadProgress.y = int(this.txt_name.y - this.mc_reloadProgress.height * 0.5 - 2);
            }
            else if(this.mc_healthBar.visible)
            {
               this.mc_reloadProgress.y = int(this.mc_healthBar.y - this.mc_reloadProgress.height * 0.5 - 4);
            }
            else
            {
               this.mc_reloadProgress.y = -int(this.mc_reloadProgress.height * 0.5);
            }
         }
         else if(this._survivor.agentData.suppressionRating > 0)
         {
            this.mc_suppression.visible = true;
            if(this.mc_suppression.parent == null)
            {
               addChild(this.mc_suppression);
            }
            if(this.ui_ammo != null)
            {
               this.ui_ammo.visible = false;
            }
            if(this.txt_name.visible)
            {
               this.mc_suppression.y = int(this.txt_name.y - this.mc_suppression.height * 0.5 - 2);
            }
            else if(this.mc_healthBar.visible)
            {
               this.mc_suppression.y = int(this.mc_healthBar.y - this.mc_suppression.height * 0.5 - 4);
            }
            else
            {
               this.mc_suppression.y = -int(this.mc_suppression.height * 0.5);
            }
         }
         if(this.bmp_cover.parent != null && this.bmp_cover.visible)
         {
            this.bmp_cover.x = int(this.txt_name.x - this.bmp_cover.width - 2);
            this.bmp_cover.y = int(this.txt_name.y + (this.txt_name.height - this.bmp_cover.height) * 0.5);
         }
         if(this._survivor.flags & AIAgentFlags.BEING_HEALED)
         {
            if(this.bmp_healing.parent != null)
            {
               this.bmp_healing.parent.removeChild(this.bmp_healing);
            }
            if(this.mc_healing.parent == null)
            {
               addChild(this.mc_healing);
            }
            if(this.mc_reloadProgress.parent != null)
            {
               this.mc_healing.y = int(this.mc_reloadProgress.y - 6);
            }
            else if(this.txt_name.visible)
            {
               this.mc_healing.y = int(this.txt_name.y - 6);
            }
            else if(this.mc_healthBar.visible)
            {
               this.mc_healing.y = int(this.mc_healthBar.y - 6);
            }
            else
            {
               this.mc_healing.y = -6;
            }
         }
         else if(this._survivor.flags & AIAgentFlags.IS_HEALING_TARGET)
         {
            if(this.mc_healing.parent != null)
            {
               this.mc_healing.parent.removeChild(this.mc_healing);
            }
            if(this.bmp_healing.parent == null)
            {
               addChild(this.bmp_healing);
            }
            if(this.mc_reloadProgress.parent != null)
            {
               this.bmp_healing.y = int(this.mc_reloadProgress.y - this.bmp_healing.height - 3);
            }
            else if(this.txt_name.visible)
            {
               this.bmp_healing.y = int(this.txt_name.y - this.bmp_healing.height - 3);
            }
            else if(this.mc_healthBar.visible)
            {
               this.bmp_healing.y = int(this.mc_healthBar.y - this.bmp_healing.height - 3);
            }
            else
            {
               this.bmp_healing.y = -int(this.bmp_healing.height + 3);
            }
         }
         else
         {
            if(this.mc_healing.parent != null)
            {
               this.mc_healing.parent.removeChild(this.mc_healing);
            }
            if(this.bmp_healing.parent != null)
            {
               this.bmp_healing.parent.removeChild(this.bmp_healing);
            }
         }
      }
      
      private function onReloadStarted(param1:Survivor) : void
      {
         addChild(this.mc_reloadProgress);
      }
      
      private function onReloadCompletedOrInterrupted(param1:Survivor) : void
      {
         if(this.mc_reloadProgress.parent != null)
         {
            this.mc_reloadProgress.parent.removeChild(this.mc_reloadProgress);
         }
      }
      
      private function onCoverRatingChanged() : void
      {
         this.updateCoverDisplay();
      }
      
      private function onHealthChanged(param1:Survivor) : void
      {
         var _loc2_:* = this._survivor.health < this._survivor.maxHealth * 0.5;
         this.txt_name.textColor = _loc2_ ? this.COLOR_BAD : this.COLOR_NEUTRAL;
      }
      
      public function get showName() : Boolean
      {
         return this.txt_name.visible;
      }
      
      public function set showName(param1:Boolean) : void
      {
         this.txt_name.visible = param1;
         this.bmp_cover.visible = param1 && this._coverRating > 0;
      }
      
      public function get showHealth() : Boolean
      {
         return this.mc_healthBar.visible;
      }
      
      public function set showHealth(param1:Boolean) : void
      {
         this.mc_healthBar.visible = param1;
      }
      
      public function get showAmmo() : Boolean
      {
         return this.ui_ammo != null ? this.ui_ammo.visible : false;
      }
      
      public function set showAmmo(param1:Boolean) : void
      {
         if(this.ui_ammo != null)
         {
            this.ui_ammo.visible = param1;
         }
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
   }
}

