package thelaststand.app.game.gui.lists
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIAchievementListItem extends UIPagedListItem
   {
      
      private static const CM_INCOMPLETE:ColorMatrix = new ColorMatrix();
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      internal static const COLOR_COMPLETE:uint = 8827692;
      
      internal static const COLOR_INCOMPLETE:uint = 12632256;
      
      CM_INCOMPLETE.desaturate();
      CM_INCOMPLETE.adjustBrightness(-50);
      
      private var _alternating:Boolean;
      
      private var _achievement:Quest;
      
      private var _lang:Language;
      
      private var mc_background:Sprite;
      
      private var txt_title:TitleTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_xp:BodyTextField;
      
      private var txt_progress:BodyTextField;
      
      private var ui_image:UIImage;
      
      private var mc_progress:Shape;
      
      public function UIAchievementListItem()
      {
         super();
         _width = 319;
         _height = 70;
         this._lang = Language.getInstance();
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         this.mc_background.mouseEnabled = false;
         addChild(this.mc_background);
         this.mc_progress = new Shape();
         this.mc_progress.graphics.beginFill(16777215);
         this.mc_progress.graphics.drawRect(0,0,_width - 2,_height - 2);
         this.mc_progress.graphics.endFill();
         this.mc_progress.x = this.mc_progress.y = 1;
         this.mc_progress.scaleX = 0;
         addChild(this.mc_progress);
         this.ui_image = new UIImage(64,64,0,1,false);
         this.ui_image.x = this.ui_image.y = 3;
         this.txt_title = new TitleTextField({
            "text":" ",
            "color":COLOR_INCOMPLETE,
            "size":18,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.x = int(this.ui_image.x + this.ui_image.width + 4);
         this.txt_title.y = int(this.ui_image.y + 2);
         this.txt_progress = new BodyTextField({
            "text":"0 / 0",
            "color":13882323,
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_progress.x = int(_width - this.txt_title.width - 8);
         this.txt_progress.y = int(this.txt_title.y + this.txt_title.height - this.txt_progress.height - 2);
         this.txt_desc = new BodyTextField({
            "text":" ",
            "color":7697781,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_desc.x = int(this.txt_title.x);
         this.txt_desc.y = int(this.txt_title.y + this.txt_title.height - 2);
         this.txt_xp = new BodyTextField({
            "text":" ",
            "color":15180544,
            "size":12,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_xp.x = int(this.txt_title.x);
         this.txt_xp.y = int(this.txt_desc.y + this.txt_desc.height - 2);
         this.txt_xp.alpha = 0.75;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this);
         if(this._achievement != null)
         {
            this._achievement.progressChanged.remove(this.onProgressChanged);
            this._achievement.completed.remove(this.onCompleted);
            this._achievement = null;
         }
         this._lang = null;
         this.txt_desc.dispose();
         this.txt_progress.dispose();
         this.txt_title.dispose();
         this.txt_xp.dispose();
         this.ui_image.dispose();
      }
      
      private function updateDisplay() : void
      {
         var _loc4_:ColorTransform = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         if(this._achievement == null)
         {
            return;
         }
         var _loc1_:int = this._achievement.getTotalProgress();
         var _loc2_:int = this._achievement.getAllGoalsTotal();
         this.ui_image.uri = this._achievement.secretLevel == Quest.SECRET_HIDDEN && !this._achievement.complete ? "images/achievements/secret.jpg" : this._achievement.imageStartURI;
         addChild(this.ui_image);
         this.txt_title.text = this._achievement.getName().toUpperCase();
         addChild(this.txt_title);
         if(this._achievement.complete)
         {
            _loc4_ = new ColorTransform();
            _loc4_.color = COLOR_COMPLETE;
            this.mc_progress.transform.colorTransform = _loc4_;
            this.mc_progress.alpha = this._alternating ? 0.15 : 0.1;
            this.mc_progress.scaleX = 1;
            this.ui_image.getBitmap().filters = [];
            this.txt_title.textColor = COLOR_COMPLETE;
            this.txt_desc.textColor = 16777215;
         }
         else
         {
            this.mc_progress.transform.colorTransform = new ColorTransform();
            this.mc_progress.alpha = this._alternating ? 0.12 : 0.08;
            this.mc_progress.scaleX = _loc1_ / _loc2_;
            this.ui_image.getBitmap().filters = [CM_INCOMPLETE.filter];
            this.txt_title.textColor = COLOR_INCOMPLETE;
            this.txt_desc.textColor = 7697781;
         }
         this.txt_desc.text = this._achievement.getDescription().toUpperCase();
         this.txt_desc.maxWidth = int(_width - this.txt_desc.x - 6);
         addChild(this.txt_desc);
         var _loc3_:int = this._achievement.getXPReward();
         if(_loc3_ > 0)
         {
            this.txt_xp.text = this._lang.getString("msg_xp_awarded",NumberFormatter.format(_loc3_,0));
            addChild(this.txt_xp);
         }
         else if(this.txt_xp.parent != null)
         {
            this.txt_xp.parent.removeChild(this.txt_xp);
         }
         if(this._achievement.complete || this._achievement.secretLevel <= Quest.SECRET_NONE)
         {
            if(this._achievement.isTimeBased)
            {
               _loc7_ = Math.floor(_loc1_ / _loc2_ * 100);
               if(_loc7_ < 0)
               {
                  _loc7_ = 0;
               }
               else if(_loc7_ > 100)
               {
                  _loc7_ = 100;
               }
               this.txt_progress.text = this._lang.getString("perc_complete",_loc7_);
            }
            else
            {
               _loc5_ = NumberFormatter.format(_loc1_,0);
               _loc6_ = NumberFormatter.format(_loc2_,0);
               this.txt_progress.text = _loc5_ + " / " + _loc6_;
            }
            this.txt_progress.x = int(_width - this.txt_progress.width - 8);
            addChild(this.txt_progress);
         }
         else if(this.txt_progress.parent != null)
         {
            this.txt_progress.parent.removeChild(this.txt_progress);
         }
         addChildAt(this.mc_progress,getChildIndex(this.mc_background) + 1);
      }
      
      private function getBackgroundColor() : uint
      {
         return this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":this.getBackgroundColor()});
      }
      
      private function onProgressChanged(param1:Quest, param2:int, param3:int) : void
      {
         this.updateDisplay();
      }
      
      private function onCompleted(param1:Quest) : void
      {
         this.updateDisplay();
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!selected)
         {
            TweenMax.killTweensOf(this.mc_background);
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this.getBackgroundColor();
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      public function get achievement() : Quest
      {
         return this._achievement;
      }
      
      public function set achievement(param1:Quest) : void
      {
         if(this._achievement != null)
         {
            this._achievement.progressChanged.remove(this.onProgressChanged);
            this._achievement.completed.remove(this.onCompleted);
         }
         this._achievement = param1;
         mouseEnabled = this._achievement != null;
         this.updateDisplay();
         if(this._achievement != null)
         {
            this._achievement.progressChanged.add(this.onProgressChanged);
            this._achievement.completed.add(this.onCompleted);
         }
      }
   }
}

