package thelaststand.app.game.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.TextFieldTyper;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   
   public class UISpeechBubble extends Sprite
   {
      
      private const ARROW_SIZE:int = 8;
      
      private const BUBBLE_STROKE:GlowFilter = new GlowFilter(6974057,1,2,2,10,1);
      
      private const BUBBLE_PADDING_X:int = 12;
      
      private const BUBBLE_PADDING_Y:int = 5;
      
      private const BMP_PADDING:int = 4;
      
      private var _agent:AIActorAgent;
      
      private var _timer:Timer;
      
      private var _typer:TextFieldTyper;
      
      private var _message:String;
      
      private var bmp_bubble:Bitmap;
      
      private var txt_message:BodyTextField;
      
      public var timerCompleted:Signal;
      
      public function UISpeechBubble(param1:AIActorAgent, param2:String, param3:int = 1, param4:Number = 4)
      {
         super();
         mouseEnabled = mouseChildren = false;
         visible = true;
         this._agent = param1;
         this._message = param2;
         this._timer = new Timer(param4 * 1000,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
         this.timerCompleted = new Signal();
         this.bmp_bubble = new Bitmap();
         this.bmp_bubble.alpha = 0.6;
         addChild(this.bmp_bubble);
         this.txt_message = new BodyTextField({
            "color":13421772,
            "autoSize":"center"
         });
         this.txt_message.text = param2;
         this.txt_message.x = this.BUBBLE_PADDING_X;
         this.txt_message.y = this.BUBBLE_PADDING_Y;
         addChild(this.txt_message);
         var _loc5_:Point = this.drawBubble(this.txt_message.width + this.BUBBLE_PADDING_X * 2,this.txt_message.height + this.BUBBLE_PADDING_Y * 2,param3);
         this.bmp_bubble.x = -_loc5_.x;
         this.bmp_bubble.y = -_loc5_.y;
         this.txt_message.x = this.bmp_bubble.x + this.BUBBLE_PADDING_X + this.BMP_PADDING;
         this.txt_message.y = this.bmp_bubble.y + this.BUBBLE_PADDING_Y + this.BMP_PADDING - 1;
         this._typer = new TextFieldTyper(this.txt_message);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(this._timer == null)
         {
            return;
         }
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         this._timer = null;
         this.timerCompleted.removeAll();
         TweenMax.killTweensOf(this.bmp_bubble);
         TweenMax.killDelayedCallsTo(this._typer.type);
         if(this.bmp_bubble.bitmapData != null)
         {
            this.bmp_bubble.bitmapData.dispose();
            this.bmp_bubble.bitmapData = null;
         }
         this.txt_message.dispose();
         this.txt_message = null;
         this._typer.dispose();
         this._typer = null;
         this._agent = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function transitionIn() : void
      {
         TweenMax.killTweensOf(this.bmp_bubble);
         TweenMax.killDelayedCallsTo(this._typer.type);
         this.bmp_bubble.scaleX = this.bmp_bubble.scaleY = 1;
         TweenMax.from(this.bmp_bubble,0.25,{
            "transformAroundPoint":{
               "point":new Point(),
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeOut,
            "easeParams":[0.75]
         });
         TweenMax.delayedCall(0.15,this._typer.type,[this._message]);
         this._timer.reset();
         this._timer.start();
      }
      
      private function drawBubble(param1:int, param2:int, param3:int) : Point
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = param2 + this.BMP_PADDING * 2;
         var _loc7_:int = param1 + this.BMP_PADDING * 2;
         var _loc8_:Point = new Point();
         var _loc9_:Shape = new Shape();
         _loc9_.graphics.beginFill(394247);
         _loc9_.graphics.drawRoundRect(param3 == 2 ? this.ARROW_SIZE : 0,param3 == 3 ? this.ARROW_SIZE : 0,param1,param2,6,6);
         switch(param3)
         {
            case 0:
               _loc5_ = Math.min(param2 * 0.3,25);
               _loc9_.graphics.moveTo(param1,_loc5_);
               _loc9_.graphics.lineTo(param1 + this.ARROW_SIZE,_loc5_);
               _loc9_.graphics.lineTo(param1,_loc5_ + this.ARROW_SIZE);
               _loc7_ += this.ARROW_SIZE;
               _loc8_.x = param1 + this.ARROW_SIZE;
               _loc8_.y = _loc5_;
               break;
            case 1:
               _loc4_ = Math.min(param1 * 0.3,25);
               _loc9_.graphics.moveTo(_loc4_,param2);
               _loc9_.graphics.lineTo(_loc4_ + this.ARROW_SIZE,param2 + this.ARROW_SIZE);
               _loc9_.graphics.lineTo(_loc4_ + this.ARROW_SIZE,param2);
               _loc6_ += this.ARROW_SIZE;
               _loc8_.x = _loc4_ + this.ARROW_SIZE;
               _loc8_.y = param2 + this.ARROW_SIZE;
               break;
            case 2:
               _loc5_ = Math.min(param2 * 0.3,25);
               _loc9_.graphics.moveTo(this.ARROW_SIZE,_loc5_);
               _loc9_.graphics.lineTo(0,_loc5_);
               _loc9_.graphics.lineTo(this.ARROW_SIZE,_loc5_ + this.ARROW_SIZE);
               _loc7_ += this.ARROW_SIZE;
               _loc8_.x = 0;
               _loc8_.y = _loc5_;
               break;
            case 3:
               _loc4_ = Math.min(param1 * 0.3,25);
               _loc9_.graphics.moveTo(_loc4_,this.ARROW_SIZE);
               _loc9_.graphics.lineTo(_loc4_ + this.ARROW_SIZE,0);
               _loc9_.graphics.lineTo(_loc4_ + this.ARROW_SIZE,this.ARROW_SIZE);
               _loc6_ += this.ARROW_SIZE;
               _loc8_.x = _loc4_ + this.ARROW_SIZE;
               _loc8_.y = 0;
         }
         _loc9_.graphics.endFill();
         _loc9_.filters = [this.BUBBLE_STROKE];
         var _loc10_:Matrix = new Matrix();
         _loc10_.tx = _loc10_.ty = this.BMP_PADDING;
         var _loc11_:BitmapData = new BitmapData(_loc7_,_loc6_,true,0);
         _loc11_.draw(_loc9_,_loc10_);
         this.bmp_bubble.bitmapData = _loc11_;
         this.bmp_bubble.smoothing = true;
         return _loc8_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         if(this._typer != null)
         {
            TweenMax.killDelayedCallsTo(this._typer.type);
         }
         TweenMax.killTweensOf(this.bmp_bubble);
         TweenMax.killTweensOf(this.txt_message);
         this.timerCompleted.removeAll();
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Number = this._agent.actor.transform.position.x;
         var _loc3_:Number = this._agent.actor.transform.position.y;
         var _loc4_:Number = this._agent.actor.transform.position.z + this._agent.actor.getHeight() + 60;
         var _loc5_:Point = this._agent.actor.scene.getScreenPosition(_loc2_,_loc3_,_loc4_);
         x = int(_loc5_.x - 10);
         y = int(_loc5_.y);
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         TweenMax.killTweensOf(this.bmp_bubble);
         TweenMax.killTweensOf(this.txt_message);
         TweenMax.to(this.txt_message,0.1,{
            "delay":0.1,
            "alpha":0
         });
         TweenMax.to(this.bmp_bubble,0.2,{
            "delay":0.05,
            "transformAroundPoint":{
               "point":new Point(),
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeIn,
            "easeParams":[0.75],
            "onComplete":function():void
            {
               timerCompleted.dispatch();
               dispose();
            }
         });
      }
   }
}

