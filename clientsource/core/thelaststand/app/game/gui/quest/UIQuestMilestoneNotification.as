package thelaststand.app.game.gui.quest
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Cubic;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TextFieldTyper;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.gui.UISimpleProgressBar;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIQuestMilestoneNotification extends Sprite
   {
      
      private const CM_INCOMPLETE:ColorMatrix;
      
      private var _width:int = 264;
      
      private var _height:int = 54;
      
      private var _timer:Timer;
      
      private var _quest:Quest;
      
      private var _conditionIndex:int;
      
      private var bmp_lock:Bitmap;
      
      private var mc_background:Shape;
      
      private var ui_image:UIImage;
      
      private var txt_name:TitleTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_prog:BodyTextField;
      
      private var ui_prog:UISimpleProgressBar;
      
      public var completed:Signal;
      
      public function UIQuestMilestoneNotification(param1:Quest, param2:int)
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         this.CM_INCOMPLETE = new ColorMatrix();
         super();
         mouseEnabled = mouseChildren = false;
         this.CM_INCOMPLETE.desaturate();
         this.CM_INCOMPLETE.adjustBrightness(-100);
         this._quest = param1;
         this._conditionIndex = param2;
         this._timer = new Timer(5000,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
         this.mc_background = new Shape();
         addChild(this.mc_background);
         this.ui_image = new UIImage(40,40,0,1,false,param1.imageStartURI);
         this.ui_image.getBitmap().filters = [this.CM_INCOMPLETE.filter];
         this.ui_image.filters = [Effects.STROKE];
         addChild(this.ui_image);
         this.bmp_lock = new Bitmap(new BmpIconLocked(),"auto",true);
         this.bmp_lock.filters = [Effects.ICON_SHADOW];
         addChild(this.bmp_lock);
         this.txt_name = new TitleTextField({
            "text":param1.getName().toUpperCase(),
            "color":11287838,
            "size":18,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_name);
         this.txt_desc = new BodyTextField({
            "text":param1.getDescription().toUpperCase(),
            "color":16777215,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_desc);
         if(param1.isTimeBased)
         {
            _loc4_ = Math.floor(param1.getTotalProgress() / param1.getAllGoalsTotal() * 100);
            if(_loc4_ < 0)
            {
               _loc4_ = 0;
            }
            else if(_loc4_ > 100)
            {
               _loc4_ = 100;
            }
            _loc3_ = Language.getInstance().getString("perc_complete",_loc4_);
         }
         else
         {
            _loc3_ = NumberFormatter.format(param1.getProgress(param2),0) + " / " + NumberFormatter.format(param1.getGoalTotal(param2),0);
         }
         this.txt_prog = new BodyTextField({
            "text":_loc3_,
            "color":7237230,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_prog);
         this.ui_prog = new UISimpleProgressBar(7829367,2960685);
         this.ui_prog.filters = [Effects.STROKE];
         this.ui_prog.width = 200;
         this.ui_prog.height = 4;
         this.ui_prog.progress = param1.getProgress(param2) / param1.getGoalTotal(param2);
         addChild(this.ui_prog);
         this.completed = new Signal();
         this.draw();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this._quest = null;
         this._timer.stop();
      }
      
      public function transitionIn() : void
      {
         var strName:String = null;
         var strDesc:String = null;
         this._timer.start();
         strName = this.txt_name.text;
         strDesc = this.txt_desc.text;
         this.txt_name.text = "";
         this.txt_desc.text = "";
         this.txt_prog.alpha = 0;
         this.ui_prog.alpha = 0;
         TweenMax.from(this.mc_background,0.3,{
            "x":this.mc_background.width,
            "width":0,
            "ease":Cubic.easeOut
         });
         TweenMax.from(this.bmp_lock,0.3,{
            "delay":0.45,
            "transformAroundCenter":{
               "scaleX":1.5,
               "scaleY":1.5
            },
            "ease":Cubic.easeOut
         });
         TweenMax.from(this.bmp_lock,0.15,{
            "delay":0.45,
            "alpha":0
         });
         TweenMax.from(this.ui_image,0.3,{
            "delay":0.2,
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeOut,
            "onComplete":function():void
            {
               new TextFieldTyper(txt_name).type(strName,60);
               new TextFieldTyper(txt_desc).type(strDesc,50);
               TweenMax.to(txt_prog,0.25,{"alpha":1});
               TweenMax.to(ui_prog,0.25,{"alpha":1});
            }
         });
      }
      
      public function transitionOut() : void
      {
         this._timer.stop();
         TweenMax.to(this.ui_prog,0.15,{"alpha":0});
         TweenMax.to(this.txt_prog,0.15,{"alpha":0});
         TweenMax.to(this.txt_name,0.15,{
            "x":"+10",
            "alpha":0
         });
         TweenMax.to(this.txt_desc,0.15,{
            "x":"+10",
            "alpha":0
         });
         TweenMax.to(this.ui_image,0.2,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeIn
         });
         TweenMax.to(this.bmp_lock,0.2,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeIn
         });
         TweenMax.to(this.mc_background,0.2,{
            "delay":0.15,
            "x":this.mc_background.width,
            "width":0,
            "ease":Cubic.easeIn,
            "onComplete":function():void
            {
               completed.dispatch();
               dispose();
            }
         });
      }
      
      private function draw() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         _loc1_ = int((this._height - this.ui_image.height) * 0.5);
         var _loc2_:int = 20;
         _loc3_ = Math.max(this.txt_desc.width,this.txt_name.width + _loc2_ + this.txt_prog.width);
         this._width = _loc3_ + _loc1_ + (this.ui_image.width + _loc1_ * 2);
         var _loc4_:Matrix = new Matrix();
         _loc4_.createGradientBox(this._width,this._height);
         this.mc_background.graphics.beginGradientFill("linear",[0,0],[0,0.65],[0,50],_loc4_);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.txt_prog.x = int(this._width - this.txt_prog.width - _loc1_);
         this.txt_prog.y = _loc1_ - 2;
         this.txt_desc.x = int(this._width - _loc3_ - _loc1_);
         this.txt_desc.y = int(this._height - this.txt_desc.height - _loc1_ - 6);
         this.txt_name.x = int(this.txt_desc.x);
         this.txt_name.y = _loc1_ - 4;
         this.ui_prog.width = _loc3_;
         this.ui_prog.x = int(this._width - this.ui_prog.width - _loc1_);
         this.ui_prog.y = int(this._height - this.ui_prog.height - _loc1_);
         this.ui_image.x = int(this.txt_name.x - this.ui_image.width - _loc1_);
         this.ui_image.y = _loc1_;
         this.bmp_lock.x = int(this.ui_image.x + (this.ui_image.width - this.bmp_lock.width) * 0.5);
         this.bmp_lock.y = int(this.ui_image.y + (this.ui_image.height - this.bmp_lock.height) * 0.5);
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         this.transitionOut();
      }
   }
}

