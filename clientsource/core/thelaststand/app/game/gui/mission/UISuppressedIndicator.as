package thelaststand.app.game.gui.mission
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.gui.UICircleProgress;
   
   public class UISuppressedIndicator extends Sprite
   {
      
      private var _agent:AIActorAgent;
      
      private var _updatePosition:Boolean = true;
      
      private var bmp_icon:Bitmap;
      
      private var mc_pulse:SuppressionIndicatorPulse;
      
      private var ui_timer:UICircleProgress;
      
      public function UISuppressedIndicator(param1:AIActorAgent)
      {
         super();
         this._agent = param1;
         this.mc_pulse = new SuppressionIndicatorPulse();
         addChild(this.mc_pulse);
         this.ui_timer = new UICircleProgress(16761096,8349209,8);
         addChild(this.ui_timer);
         this.bmp_icon = new Bitmap(new BmpIconSuppressed());
         this.bmp_icon.x = -Math.round(this.bmp_icon.width * 0.5);
         this.bmp_icon.y = -Math.round(this.bmp_icon.height * 0.5);
         addChild(this.bmp_icon);
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
         this._agent = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.ui_timer.dispose();
         removeChild(this.mc_pulse);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Point = null;
         var _loc2_:Number = this._agent.agentData.suppressionRating / this._agent.agentData.suppressionPoints;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         this.mc_pulse.visible = this._agent.agentData.suppressed;
         this.mc_pulse.alpha = _loc2_;
         this.ui_timer.progress = _loc2_;
         this.alpha = !this._agent.agentData.suppressed ? _loc2_ : 1;
         if(this._updatePosition)
         {
            if(this._agent.entity.scene == null)
            {
               return;
            }
            _loc3_ = this._agent.entity.transform.position;
            _loc4_ = this._agent.entity.scene.getScreenPosition(_loc3_.x,_loc3_.y,_loc3_.z + this._agent.actor.getHeight() + 50);
            this.x = int(_loc4_.x);
            this.y = int(_loc4_.y);
         }
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
      
      public function get updatePosition() : Boolean
      {
         return this._updatePosition;
      }
      
      public function set updatePosition(param1:Boolean) : void
      {
         this._updatePosition = param1;
      }
      
      override public function get width() : Number
      {
         return this.ui_timer.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.ui_timer.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

