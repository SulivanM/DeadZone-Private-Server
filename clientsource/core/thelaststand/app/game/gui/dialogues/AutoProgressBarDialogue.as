package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.skills.SkillState;
   import thelaststand.app.game.gui.UILargeProgressBar;
   import thelaststand.app.game.gui.skills.UISkillXpBar;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   
   public class AutoProgressBarDialogue extends BaseDialogue
   {
      
      private const TRACK_GLOW:GlowFilter;
      
      private var _time:Number = 3;
      
      private var _skills:Vector.<SkillState>;
      
      private var _skillBars:Vector.<UISkillXpBar>;
      
      private var mc_container:Sprite;
      
      private var mc_track:Shape;
      
      private var txt_message:BodyTextField;
      
      private var ui_bar:UILargeProgressBar;
      
      public var completed:Signal;
      
      public function AutoProgressBarDialogue(param1:String, param2:uint, param3:Number = 3, param4:Vector.<SkillState> = null)
      {
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:UISkillXpBar = null;
         this.TRACK_GLOW = new GlowFilter(7039851,1,3,3,3,2);
         this.mc_container = new Sprite();
         super("auto-progress",this.mc_container,false);
         _autoSize = false;
         _width = 300;
         this._time = param3;
         this._skills = param4;
         this.completed = new Signal();
         var _loc5_:int = int(_width - _padding * 2);
         this.txt_message = new BodyTextField({
            "color":11908533,
            "size":14,
            "bold":true,
            "align":"center",
            "multiline":true
         });
         this.txt_message.htmlText = param1;
         this.txt_message.width = int(_width - _padding * 2);
         this.mc_container.addChild(this.txt_message);
         _loc6_ = _loc5_;
         var _loc7_:int = 26;
         this.mc_track = new Shape();
         this.mc_track.graphics.beginFill(2631204);
         this.mc_track.graphics.drawRect(0,0,_loc6_,_loc7_);
         this.mc_track.graphics.endFill();
         this.mc_track.filters = [this.TRACK_GLOW];
         this.mc_track.cacheAsBitmap = true;
         this.mc_track.x = int((_loc5_ - this.mc_track.width) * 0.5);
         this.mc_track.y = int(this.txt_message.y + this.txt_message.height + 12);
         this.mc_container.addChildAt(this.mc_track,0);
         this.ui_bar = new UILargeProgressBar(param2,_loc6_ - 4,_loc7_ - 4);
         this.ui_bar.x = int(this.mc_track.x + 2);
         this.ui_bar.y = int(this.mc_track.y + 2);
         this.ui_bar.value = 0;
         this.ui_bar.maxValue = 1;
         this.mc_container.addChild(this.ui_bar);
         var _loc8_:int = int(this.mc_track.y + this.mc_track.height);
         if(this._skills != null && this._skills.length > 0)
         {
            _loc8_ += 10;
            this._skillBars = new Vector.<UISkillXpBar>();
            _loc9_ = 0;
            while(_loc9_ < this._skills.length)
            {
               _loc10_ = new UISkillXpBar();
               _loc10_.skillState = this._skills[_loc9_];
               _loc10_.showName = true;
               _loc10_.width = this.mc_track.width;
               _loc10_.height = this.mc_track.height;
               _loc10_.x = int(this.mc_track.x);
               _loc10_.y = _loc8_;
               this.mc_container.addChild(_loc10_);
               _loc8_ += _loc10_.height + 6;
               this._skillBars.push(_loc10_);
               _loc9_++;
            }
            _loc8_ -= 6;
         }
         _height = int(_loc8_ + _padding * 2);
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = 0;
         super.dispose();
         TweenMax.killChildTweensOf(this.ui_bar);
         this.completed.removeAll();
         this.txt_message.dispose();
         this.ui_bar.dispose();
         if(this._skillBars != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this._skillBars.length)
            {
               this._skillBars[_loc1_].dispose();
               _loc1_++;
            }
         }
         this._skillBars = null;
         this._skills = null;
      }
      
      override public function open() : void
      {
         super.open();
         TweenMax.to(this.ui_bar,this._time,{
            "value":1,
            "ease":Linear.easeNone,
            "onComplete":function():void
            {
               completed.dispatch();
            }
         });
      }
   }
}

