package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UIQuestTaskListItem extends UIPagedListItem
   {
      
      private static const BMP_TRACKING:BitmapData = new BmpIconQuestTracking();
      
      private static const BMP_COMPLETE:BitmapData = new BmpExitZoneOK();
      
      private static const BMP_FAILED:BitmapData = new BmpExitZoneBad();
      
      private static const BMP_NEW:BitmapData = new BmpIconNewItem();
      
      private static const CT_COMPLETE:ColorTransform = new ColorTransform();
      
      private static const CT_FAILED:ColorTransform = new ColorTransform();
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_SELECTED:int = 5000268;
      
      internal static const COLOR_OVER:int = 3158064;
      
      CT_COMPLETE.color = 3892495;
      CT_FAILED.color = 9706765;
      
      private var _alternating:Boolean;
      
      private var _quest:Quest;
      
      private var _lang:Language;
      
      private var mc_background:Sprite;
      
      private var mc_iconBackground:Shape;
      
      private var mc_progress:Shape;
      
      private var bmp_icon:Bitmap;
      
      private var mc_tracking:Sprite;
      
      private var bmp_trackingIcon:Bitmap;
      
      private var bmp_iconNew:Bitmap;
      
      private var txt_title:TitleTextField;
      
      public function UIQuestTaskListItem()
      {
         super();
         _width = 296;
         _height = 26;
         this._lang = Language.getInstance();
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         this.mc_background.mouseEnabled = false;
         addChild(this.mc_background);
         this.mc_iconBackground = new Shape();
         this.mc_iconBackground.graphics.beginFill(0);
         this.mc_iconBackground.graphics.drawRect(0,0,24,24);
         this.mc_iconBackground.graphics.endFill();
         addChild(this.mc_iconBackground);
         this.mc_progress = new Shape();
         this.mc_progress.graphics.beginFill(16777215);
         this.mc_progress.graphics.drawRect(0,0,10,_height - 2);
         this.mc_progress.graphics.endFill();
         addChild(this.mc_iconBackground);
         this.bmp_icon = new Bitmap();
         this.bmp_iconNew = new Bitmap(BMP_NEW);
         this.bmp_trackingIcon = new Bitmap();
         this.mc_tracking = new Sprite();
         this.mc_tracking.addChild(this.bmp_trackingIcon);
         this.mc_tracking.addEventListener(MouseEvent.CLICK,this.onClickTracking,false,0,true);
         this.txt_title = new TitleTextField({
            "text":" ",
            "color":16777215,
            "size":16,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.mouseEnabled = false;
         hitArea = this.mc_background;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.quest = null;
         this._lang = null;
         this.txt_title.dispose();
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
            this.bmp_icon.bitmapData = null;
         }
         this.bmp_iconNew.bitmapData = null;
         this.bmp_trackingIcon.bitmapData = null;
      }
      
      private function updateDisplay() : void
      {
         var _loc2_:Boolean = false;
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
            this.bmp_icon.bitmapData = null;
         }
         if(this._quest == null || this._quest.isAchievement)
         {
            if(this.mc_iconBackground.parent != null)
            {
               this.mc_iconBackground.parent.removeChild(this.mc_iconBackground);
            }
            if(this.bmp_icon.parent != null)
            {
               this.bmp_icon.parent.removeChild(this.bmp_icon);
            }
            if(this.bmp_trackingIcon.parent != null)
            {
               this.bmp_trackingIcon.parent.removeChild(this.bmp_trackingIcon);
            }
            if(this.txt_title.parent != null)
            {
               this.txt_title.parent.removeChild(this.txt_title);
            }
            if(this.mc_progress.parent != null)
            {
               this.mc_progress.parent.removeChild(this.mc_progress);
            }
            return;
         }
         this.mc_progress.x = this.mc_iconBackground.x + this.mc_iconBackground.width + 2;
         this.mc_progress.y = 1;
         addChild(this.mc_progress);
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.color = Quest.getColor(this._quest.type);
         this.mc_iconBackground.transform.colorTransform = _loc1_;
         this.mc_iconBackground.x = this.mc_iconBackground.y = 1;
         addChild(this.mc_iconBackground);
         this.bmp_icon.bitmapData = Quest.getIcon(this._quest.type);
         this.bmp_icon.x = int(this.mc_iconBackground.x + (this.mc_iconBackground.width - this.bmp_icon.width) * 0.5);
         this.bmp_icon.y = int(this.mc_iconBackground.y + (this.mc_iconBackground.height - this.bmp_icon.height) * 0.5);
         addChild(this.bmp_icon);
         this.txt_title.text = this._quest.getName().toUpperCase();
         this.txt_title.x = int(this.mc_iconBackground.x + this.mc_iconBackground.width + 2);
         this.txt_title.y = int(this.mc_background.y + (this.mc_background.height - this.txt_title.height) * 0.5);
         addChild(this.txt_title);
         if(this._quest.complete || this._quest.failed)
         {
            if(this._quest.collected)
            {
               this.bmp_trackingIcon.bitmapData = null;
            }
            else
            {
               this.bmp_trackingIcon.bitmapData = this._quest.failed ? BMP_FAILED : BMP_COMPLETE;
               this.bmp_trackingIcon.alpha = 1;
               this.bmp_trackingIcon.filters = [Effects.ICON_SHADOW];
               this.bmp_trackingIcon.smoothing = true;
               this.bmp_trackingIcon.scaleX = this.bmp_trackingIcon.scaleY = 0.6;
            }
            this.mc_progress.width = int(this.mc_background.width - this.mc_progress.x - 1);
            this.mc_progress.transform.colorTransform = this._quest.failed ? CT_FAILED : CT_COMPLETE;
            this.mc_progress.alpha = 0.5;
            this.bmp_trackingIcon.visible = true;
         }
         else
         {
            _loc2_ = QuestSystem.getInstance().isTracked(this._quest);
            this.bmp_trackingIcon.bitmapData = BMP_TRACKING;
            this.bmp_trackingIcon.alpha = _loc2_ ? 1 : 0.3;
            this.bmp_trackingIcon.filters = [];
            this.bmp_trackingIcon.smoothing = false;
            this.bmp_trackingIcon.scaleX = this.bmp_trackingIcon.scaleY = 1;
            this.bmp_trackingIcon.visible = !this._quest.isGlobalQuest && !(this._quest is DynamicQuest);
            this.mc_progress.width = int(this._quest.getTotalProgress() / this._quest.getAllGoalsTotal() * (this.mc_background.width - this.mc_progress.x - 1));
            this.mc_progress.transform.colorTransform = Effects.CT_DEFAULT;
            this.mc_progress.alpha = 0.1;
         }
         this.mc_tracking.x = int(this.mc_background.x + (this.mc_background.width - this.mc_tracking.width - 4));
         this.mc_tracking.y = int(this.mc_background.y + (this.mc_background.height - this.mc_tracking.height) * 0.5);
         addChild(this.mc_tracking);
         TooltipManager.getInstance().add(this.mc_tracking,this.getTrackingTooltip,new Point(this.mc_tracking.width,NaN),TooltipDirection.DIRECTION_LEFT,0.15);
         if(this._quest.isNew)
         {
            this.bmp_iconNew.x = int(this.mc_tracking.x - this.bmp_iconNew.width - 4);
            this.bmp_iconNew.y = int((_height - this.bmp_iconNew.height) * 0.5);
            addChild(this.bmp_iconNew);
         }
         else if(this.bmp_iconNew.parent != null)
         {
            this.bmp_iconNew.parent.removeChild(this.bmp_iconNew);
         }
         alpha = this._quest.collected ? 0.4 : 1;
      }
      
      private function getBackgroundColor() : uint
      {
         return selected ? uint(COLOR_SELECTED) : (this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL));
      }
      
      private function getTrackingTooltip() : String
      {
         if(this._quest == null)
         {
            return "";
         }
         if(this._quest.complete)
         {
            return this._lang.getString("quests_task_complete");
         }
         if(this._quest.failed)
         {
            return this._lang.getString("quests_task_failed");
         }
         if(QuestSystem.getInstance().isTracked(this._quest))
         {
            return this._lang.getString("quests_task_untrack");
         }
         if(QuestSystem.getInstance().maxNumQuestsBeingTracked())
         {
            return this._lang.getString("quests_task_maxtracked");
         }
         return this._lang.getString("quests_task_track");
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
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onClickTracking(param1:MouseEvent) : void
      {
         if(this._quest == null || this._quest.isAchievement || this._quest.complete || this._quest.isGlobalQuest || this._quest.failed || this._quest is DynamicQuest)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
         var _loc2_:String = QuestSystem.getInstance().toggleTracking(this._quest);
         if(_loc2_ == Quest.TRACKING_MAX_TRACKED)
         {
            TooltipManager.getInstance().show(this.mc_tracking);
         }
      }
      
      private function onRewardCollected(param1:Quest) : void
      {
         this.updateDisplay();
      }
      
      private function onProgressChanged(param1:Quest, param2:int, param3:int) : void
      {
         this.updateDisplay();
      }
      
      private function onCompleted(param1:Quest) : void
      {
         this.updateDisplay();
      }
      
      private function onTrackingChanged(param1:Quest) : void
      {
         if(this._quest == null || this._quest != param1)
         {
            return;
         }
         var _loc2_:Boolean = QuestSystem.getInstance().isTracked(this._quest);
         this.bmp_trackingIcon.alpha = _loc2_ ? 1 : 0.3;
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
      
      override public function set selected(param1:Boolean) : void
      {
         if(this._quest == null)
         {
            param1 = false;
         }
         super.selected = param1;
         TweenMax.killTweensOf(this.mc_background);
         var _loc2_:ColorTransform = this.mc_background.transform.colorTransform;
         _loc2_.color = this.getBackgroundColor();
         this.mc_background.transform.colorTransform = _loc2_;
      }
      
      public function get quest() : Quest
      {
         return this._quest;
      }
      
      public function set quest(param1:Quest) : void
      {
         if(this._quest != null)
         {
            this._quest.tracked.remove(this.onTrackingChanged);
            this._quest.untracked.remove(this.onTrackingChanged);
            this._quest.progressChanged.remove(this.onProgressChanged);
            this._quest.rewardCollected.remove(this.onRewardCollected);
            this._quest.completed.remove(this.onCompleted);
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         }
         this._quest = param1;
         mouseEnabled = this._quest != null;
         this.updateDisplay();
         if(this._quest != null)
         {
            this._quest.tracked.add(this.onTrackingChanged);
            this._quest.untracked.add(this.onTrackingChanged);
            this._quest.progressChanged.add(this.onProgressChanged);
            this._quest.rewardCollected.add(this.onRewardCollected);
            this._quest.completed.add(this.onCompleted);
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         }
      }
   }
}

