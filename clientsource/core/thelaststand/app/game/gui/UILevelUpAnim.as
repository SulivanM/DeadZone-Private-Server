package thelaststand.app.game.gui
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import thelaststand.common.lang.Language;
   
   public class UILevelUpAnim extends Sprite
   {
      
      private var _level:int;
      
      private var _textLabelSet:Boolean = false;
      
      private var _textLevelSet:Boolean = false;
      
      private var mc_anim:LevelUpAnim;
      
      private var txt_label:TextField;
      
      private var txt_level:TextField;
      
      public function UILevelUpAnim()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.mc_anim = new LevelUpAnim();
         this.mc_anim.stop();
         addChild(this.mc_anim);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.FRAME_CONSTRUCTED,this.onEnterFrame);
         TweenMax.killChildTweensOf(this);
         if(this.mc_anim.parent != null)
         {
            this.mc_anim.parent.removeChild(this.mc_anim);
         }
         this.mc_anim = null;
      }
      
      public function play(param1:int) : void
      {
         this._level = param1;
         this._textLabelSet = false;
         this._textLevelSet = false;
         this.txt_label = this.txt_level = null;
         this.mc_anim.gotoAndPlay(0);
         addEventListener(Event.FRAME_CONSTRUCTED,this.onEnterFrame,false,0,true);
         this.onEnterFrame(null);
      }
      
      private function applyTextStyle(param1:TextField, param2:int) : void
      {
         var _loc3_:TextFormat = new TextFormat(Language.getInstance().getFontName("title"),param2);
         param1.setTextFormat(_loc3_);
         param1.defaultTextFormat = _loc3_;
         param1.embedFonts = true;
         param1.selectable = false;
         param1.multiline = param1.wordWrap = false;
         param1.autoSize = TextFieldAutoSize.CENTER;
         param1.mouseEnabled = false;
         param1.mouseWheelEnabled = false;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this.txt_label == null)
         {
            this.txt_label = this.mc_anim.getChildByName("txt_label") as TextField;
         }
         if(this.txt_level == null)
         {
            this.txt_level = this.mc_anim.getChildByName("txt_level") as TextField;
         }
         if(this.txt_label != null && !this._textLabelSet)
         {
            this._textLabelSet = true;
            this.applyTextStyle(this.txt_label,25);
            this.txt_label.text = Language.getInstance().getString("level_up");
            if(this.txt_label.width > 140)
            {
               this.txt_label.scaleX = 140 / width;
               this.txt_label.scaleY = scaleX;
            }
            this.txt_label.x = -int(this.txt_label.width * 0.5);
            TweenMax.from(this.txt_label,0.1,{"alpha":0});
         }
         if(this.txt_level != null && !this._textLevelSet)
         {
            this._textLevelSet = true;
            this.applyTextStyle(this.txt_level,60);
            this.txt_level.text = this._level.toString();
            TweenMax.from(this.txt_level,0.1,{"alpha":0});
         }
         if(this.mc_anim.currentFrame >= this.mc_anim.totalFrames)
         {
            removeEventListener(Event.FRAME_CONSTRUCTED,this.onEnterFrame);
            if(parent != null)
            {
               parent.removeChild(this);
            }
         }
      }
   }
}

