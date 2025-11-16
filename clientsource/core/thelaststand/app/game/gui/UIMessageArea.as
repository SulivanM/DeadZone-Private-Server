package thelaststand.app.game.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.GradientType;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TextFieldTyper;
   
   public class UIMessageArea extends Sprite
   {
      
      private var _timer:Timer;
      
      private var _notifications:Vector.<BodyTextField>;
      
      private var _messsage:String;
      
      private var txt_message:BodyTextField;
      
      private var mc_messageBackground:Shape;
      
      public function UIMessageArea()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.mc_messageBackground = new Shape();
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":15,
            "bold":true,
            "autoSize":"center"
         });
         this.txt_message.text = " ";
         this.txt_message.filters = [Effects.STROKE_MEDIUM];
         this.txt_message.visible = false;
         addChild(this.txt_message);
         this._notifications = new Vector.<BodyTextField>();
         this._timer = new Timer(0,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
         visible = true;
      }
      
      public function addNotification(param1:String, param2:uint, param3:Number = 3, param4:Boolean = false) : void
      {
         var _loc9_:BodyTextField = null;
         var _loc5_:BodyTextField = new BodyTextField({
            "color":param2,
            "autoSize":"center",
            "size":15,
            "bold":true
         });
         _loc5_.text = param1;
         _loc5_.filters = [Effects.STROKE_MEDIUM];
         _loc5_.x = -int(_loc5_.width * 0.5);
         _loc5_.y = 74;
         addChild(_loc5_);
         var _loc6_:int = _loc5_.y;
         var _loc7_:int = int(this._notifications.length - 1);
         while(_loc7_ >= 0)
         {
            _loc9_ = this._notifications[_loc7_];
            if(!TweenMax.isTweening(_loc9_))
            {
               _loc6_ -= int(_loc9_.height - 4);
               TweenMax.killDelayedCallsTo(_loc9_);
               TweenMax.to(_loc9_,0.25,{
                  "y":_loc6_,
                  "onComplete":this.fadeOutNotification,
                  "onCompleteParams":[0.25,_loc9_]
               });
            }
            _loc7_--;
         }
         var _loc8_:TextFieldTyper = new TextFieldTyper(_loc5_);
         _loc8_.type(param1,60);
         TweenMax.delayedCall(param3 + 0.15,this.fadeOutNotification,[0,_loc5_,_loc8_]);
         this._notifications.push(_loc5_);
      }
      
      public function dispose() : void
      {
         var _loc1_:BodyTextField = null;
         var _loc2_:int = 0;
         TweenMax.killChildTweensOf(this);
         TweenMax.killDelayedCallsTo(this.fadeOutNotification);
         if(parent)
         {
            parent.removeChild(this);
         }
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         this._timer = null;
         for each(_loc1_ in this._notifications)
         {
            _loc1_.dispose();
         }
         this._notifications = null;
         this.txt_message.dispose();
         this.txt_message = null;
         _loc2_ = this.numChildren - 1;
         while(_loc2_ >= 0)
         {
            _loc1_ = this.getChildAt(_loc2_) as BodyTextField;
            if(_loc1_ != null)
            {
               _loc1_.dispose();
            }
            _loc2_--;
         }
      }
      
      public function setMessage(param1:String, param2:Number = 6, param3:uint = 16777215) : void
      {
         this._timer.stop();
         TweenMax.killTweensOf(this.txt_message);
         TweenMax.killTweensOf(this.mc_messageBackground);
         this.txt_message.visible = true;
         this.txt_message.alpha = 1;
         this.txt_message.textColor = param3;
         this.txt_message.htmlText = param1;
         this.txt_message.x = -int(this.txt_message.width * 0.5);
         if(param1.length > 0)
         {
            this.mc_messageBackground.alpha = 1;
            this.mc_messageBackground.scaleX = this.mc_messageBackground.scaleY = 1;
            this.drawBackground();
            this.mc_messageBackground.x = int(this.txt_message.x + (this.txt_message.width - this.mc_messageBackground.width) * 0.5);
            this.mc_messageBackground.y = int(this.txt_message.y + (this.txt_message.height - this.mc_messageBackground.height) * 0.5);
            addChildAt(this.mc_messageBackground,0);
            TweenMax.from(this.mc_messageBackground,0.25,{"transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0
            }});
         }
         else if(this.mc_messageBackground.parent != null)
         {
            this.mc_messageBackground.parent.removeChild(this.mc_messageBackground);
         }
         this._messsage = param1;
         TweenMax.from(this.txt_message,0.25,{
            "delay":0.05,
            "alpha":0
         });
         this._timer.delay = param2 * 1000;
         this._timer.reset();
         this._timer.start();
      }
      
      private function drawBackground() : void
      {
         var _loc1_:int = this.txt_message.width + 120;
         var _loc2_:int = this.txt_message.height + 10;
         var _loc3_:Matrix = new Matrix();
         _loc3_.createGradientBox(_loc1_,_loc2_);
         this.mc_messageBackground.graphics.clear();
         this.mc_messageBackground.graphics.beginGradientFill(GradientType.LINEAR,[5197647,5197647,5197647,5197647],[0,0.6,0.6,0],[0,60,195,255],_loc3_);
         this.mc_messageBackground.graphics.drawRect(0,0,_loc1_,1);
         this.mc_messageBackground.graphics.endFill();
         this.mc_messageBackground.graphics.beginGradientFill(GradientType.LINEAR,[0,0,0,0],[0,0.6,0.6,0],[0,60,195,255],_loc3_);
         this.mc_messageBackground.graphics.drawRect(0,1,_loc1_,_loc2_ - 2);
         this.mc_messageBackground.graphics.endFill();
         this.mc_messageBackground.graphics.beginGradientFill(GradientType.LINEAR,[5197647,5197647,5197647,5197647],[0,0.6,0.6,0],[0,60,195,255],_loc3_);
         this.mc_messageBackground.graphics.drawRect(0,_loc2_ - 1,_loc1_,1);
         this.mc_messageBackground.graphics.endFill();
      }
      
      private function fadeOutNotification(param1:Number, param2:BodyTextField, param3:TextFieldTyper = null) : void
      {
         var delay:Number = param1;
         var note:BodyTextField = param2;
         var typer:TextFieldTyper = param3;
         TweenMax.to(note,1,{
            "delay":delay,
            "alpha":0,
            "y":"-30",
            "ease":Linear.easeNone,
            "onComplete":function():void
            {
               var _loc1_:* = _notifications.indexOf(note);
               if(_loc1_ > -1)
               {
                  _notifications.splice(_loc1_,1);
               }
               if(typer != null)
               {
                  typer.dispose();
               }
               if(note != null)
               {
                  note.dispose();
               }
            }
         });
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         var e:TimerEvent = param1;
         TweenMax.to(this.mc_messageBackground,0.5,{
            "alpha":0,
            "overwrite":true
         });
         TweenMax.to(this.txt_message,0.5,{
            "autoAlpha":0,
            "onComplete":function():void
            {
               _messsage = null;
               txt_message.text = "";
               if(mc_messageBackground.parent != null)
               {
                  mc_messageBackground.parent.removeChild(mc_messageBackground);
               }
            }
         });
      }
      
      public function get currentMessage() : String
      {
         return this._messsage;
      }
   }
}

