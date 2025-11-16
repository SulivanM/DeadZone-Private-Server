package thelaststand.app.game.gui.mission
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.enemies.EnemyEliteType;
   import thelaststand.app.game.entities.actors.Actor;
   import thelaststand.app.game.gui.survivor.UIActorHealthBarLarge;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   
   public class UIEliteEnemyIndicator extends Sprite
   {
      
      private var _agent:AIActorAgent;
      
      private var _maxHealth:Number;
      
      private var bmp_icon:Bitmap;
      
      private var mc_healthBar:UIActorHealthBarLarge;
      
      public function UIEliteEnemyIndicator(param1:AIActorAgent)
      {
         var _loc2_:uint = 0;
         var _loc3_:BitmapData = null;
         super();
         this._agent = param1;
         this._maxHealth = this._agent.maxHealth;
         mouseEnabled = mouseChildren = false;
         if(this._agent.eliteType == EnemyEliteType.RARE)
         {
            _loc2_ = Effects.COLOR_RARE;
            _loc3_ = new BmpIconEliteRare();
         }
         else if(this._agent.eliteType == EnemyEliteType.UNIQUE)
         {
            _loc2_ = Effects.COLOR_UNIQUE;
            _loc3_ = new BmpIconEliteUnique();
         }
         else
         {
            _loc2_ = Effects.COLOR_WARNING;
            _loc3_ = null;
         }
         this.mc_healthBar = new UIActorHealthBarLarge(this._agent,_loc2_);
         this.mc_healthBar.width = 40;
         this.mc_healthBar.x = -int(this.mc_healthBar.width * 0.5);
         this.mc_healthBar.y = int(this.mc_healthBar.height);
         addChild(this.mc_healthBar);
         if(_loc3_ != null)
         {
            this.bmp_icon = new Bitmap(_loc3_);
            this.bmp_icon.x = -int(this.bmp_icon.width * 0.5);
            this.bmp_icon.y = int(this.mc_healthBar.y - this.bmp_icon.height - 8);
            addChild(this.bmp_icon);
         }
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
         if(this.bmp_icon != null)
         {
            this.bmp_icon.bitmapData.dispose();
            this.bmp_icon.bitmapData = null;
            this.bmp_icon = null;
         }
         this._agent = null;
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
         var _loc2_:Actor = this._agent.actor;
         if(_loc2_.scene == null)
         {
            return;
         }
         visible = _loc2_.asset.visible && this._agent.health > 0 && this._agent.agentData.inLOS;
         if(!visible)
         {
            return;
         }
         var _loc3_:Vector3D = _loc2_.transform.position;
         var _loc4_:Point = _loc2_.scene.getScreenPosition(_loc3_.x,_loc3_.y,_loc3_.z + _loc2_.getHeight() + 50);
         this.x = int(_loc4_.x);
         this.y = int(_loc4_.y);
      }
      
      public function get agent() : AIActorAgent
      {
         return this._agent;
      }
   }
}

