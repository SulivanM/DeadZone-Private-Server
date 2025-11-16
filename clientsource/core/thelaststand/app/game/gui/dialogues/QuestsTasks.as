package thelaststand.app.game.gui.dialogues
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.gui.lists.UIQuestTaskList;
   import thelaststand.app.game.gui.lists.UIQuestTaskListItem;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.game.logic.GlobalQuestSystem;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class QuestsTasks extends Sprite
   {
      
      public static var previousQuest:String;
      
      public static var previousCategory:String = "all";
      
      private var _categoryButtons:Vector.<PushButton>;
      
      private var _selectedCategory:String;
      
      private var _selectedCategoryButton:PushButton;
      
      private var _selectedQuest:Quest;
      
      private var _xml:XML;
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var btn_all:PushButton;
      
      private var btn_collect:PushButton;
      
      private var btn_track:PushButton;
      
      private var ui_infoPanel:QuestInfoPanel;
      
      private var ui_list:UIQuestTaskList;
      
      private var ui_page:UIPagination;
      
      private var ui_dailyQuestCounter:UINotificationCount;
      
      private var ui_globalQuestCounter:UINotificationCount;
      
      public function QuestsTasks()
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:XML = null;
         var _loc8_:PushButton = null;
         var _loc9_:uint = 0;
         var _loc10_:BitmapData = null;
         var _loc11_:int = 0;
         super();
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this._xml = ResourceManager.getInstance().getResource("xml/quests.xml").content;
         this._categoryButtons = new Vector.<PushButton>();
         var _loc1_:XMLList = this._xml.types.type;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length())
         {
            _loc7_ = _loc1_[_loc2_];
            _loc8_ = new PushButton();
            _loc8_.clicked.add(this.onCategoryButtonClicked);
            _loc8_.data = _loc7_.toString();
            _loc8_.width = 28;
            _loc8_.height = 24;
            _loc9_ = Quest.getColor(_loc8_.data);
            if(_loc9_ > 0)
            {
               _loc8_.backgroundColor = new Color(_loc9_).adjustBrightness(0.75).RGB;
            }
            _loc10_ = Quest.getIcon(_loc8_.data);
            if(_loc10_ != null)
            {
               _loc8_.icon = new Bitmap(_loc10_);
            }
            addChild(_loc8_);
            this._categoryButtons.push(_loc8_);
            this._tooltip.add(_loc8_,this._lang.getString("quest_cats." + _loc8_.data),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0.1);
            _loc2_++;
         }
         _loc3_ = 35;
         _loc4_ = 302;
         this.btn_all = new PushButton(this._lang.getString("quest_cats.all"));
         this.btn_all.clicked.add(this.onCategoryButtonClicked);
         this.btn_all.data = "all";
         this.btn_all.width = 48;
         this.btn_all.x = 4;
         this.btn_all.y = _loc3_;
         addChild(this.btn_all);
         var _loc5_:int = 12;
         var _loc6_:int = _loc4_ - this.btn_all.x;
         _loc2_ = int(this._categoryButtons.length - 1);
         while(_loc2_ >= 0)
         {
            _loc8_ = this._categoryButtons[_loc2_];
            _loc8_.x = _loc6_ - _loc8_.width;
            _loc8_.y = this.btn_all.y;
            _loc6_ -= _loc8_.width + _loc5_;
            if(_loc8_.data == Quest.TYPE_DYNAMIC)
            {
               _loc11_ = QuestSystem.getInstance().numActiveDynamicQuests;
               if(_loc11_ > 0)
               {
                  this.ui_dailyQuestCounter = new UINotificationCount();
                  this.ui_dailyQuestCounter.scaleX = this.ui_dailyQuestCounter.scaleY = 0.8;
                  this.ui_dailyQuestCounter.x = _loc8_.x + _loc8_.width;
                  this.ui_dailyQuestCounter.y = _loc8_.y;
                  this.ui_dailyQuestCounter.filters = [Effects.TEXT_SHADOW_DARK];
                  this.ui_dailyQuestCounter.label = _loc11_.toString();
                  addChild(this.ui_dailyQuestCounter);
               }
            }
            else if(_loc8_.data == Quest.TYPE_WORLD)
            {
               _loc8_.enabled = GlobalQuestSystem.getInstance().numActiveQuests > 0 || GlobalQuestSystem.getInstance().numUncollectedQuests > 0;
               this.ui_globalQuestCounter = new UINotificationCount();
               this.ui_globalQuestCounter.scaleX = this.ui_globalQuestCounter.scaleY = 0.8;
               this.ui_globalQuestCounter.x = _loc8_.x + _loc8_.width;
               this.ui_globalQuestCounter.y = _loc8_.y;
               this.ui_globalQuestCounter.filters = [Effects.TEXT_SHADOW_DARK];
               this.onGlobalQuestMovedToGrace(null);
               GlobalQuestSystem.getInstance().questMovedToGrace.add(this.onGlobalQuestMovedToGrace);
               addChild(this.ui_globalQuestCounter);
            }
            _loc2_--;
         }
         this.ui_list = new UIQuestTaskList();
         this.ui_list.width = _loc4_;
         this.ui_list.height = 329;
         this.ui_list.y = int(this.btn_all.y + this.btn_all.height + 8);
         this.ui_list.changed.add(this.onQuestSelected);
         addChild(this.ui_list);
         this.ui_page = new UIPagination();
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 10);
         this.ui_page.changed.add(this.onPageChanged);
         addChild(this.ui_page);
         this.ui_infoPanel = new QuestInfoPanel();
         this.ui_infoPanel.x = int(this.ui_list.x + this.ui_list.width + 18);
         addChild(this.ui_infoPanel);
         this.btn_track = new PushButton(this._lang.getString("quests_btn_track"),new BmpIconQuestTracking(),Quest.getColor("general"));
         this.btn_track.width = 120;
         this.btn_track.x = int(this.ui_infoPanel.x + this.ui_infoPanel.width * 0.5 - this.btn_track.width - 6);
         this.btn_track.y = this.ui_page.y;
         this.btn_track.clicked.add(this.onTrackClicked);
         addChild(this.btn_track);
         this.btn_collect = new PushButton(this._lang.getString("quests_collect"),null,-1,null,4226049);
         this.btn_collect.width = this.btn_track.width;
         this.btn_collect.x = int(this.btn_track.x + this.btn_track.width + 12);
         this.btn_collect.y = this.ui_page.y;
         this.btn_collect.enabled = false;
         this.btn_collect.clicked.add(this.onCollectClicked);
         addChild(this.btn_collect);
         TooltipManager.getInstance().add(this.btn_collect,this.getCollectTooltip,new Point(Number.NaN,0),TooltipDirection.DIRECTION_DOWN);
         GlobalQuestSystem.getInstance().progressChange.add(this.onGlobalQuestProgressChange);
         GlobalQuestSystem.getInstance().questCompleted.add(this.refreshCollectButton);
         this.selectCategory(previousCategory,previousQuest);
      }
      
      public function dispose() : void
      {
         var _loc1_:PushButton = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.ui_list.dispose();
         this.ui_list = null;
         for each(_loc1_ in this._categoryButtons)
         {
            _loc1_.dispose();
         }
         if(this._selectedQuest != null)
         {
            this._selectedQuest.tracked.remove(this.onQuestTrackingChanged);
            this._selectedQuest.untracked.remove(this.onQuestTrackingChanged);
            this._selectedQuest.progressChanged.remove(this.onQuestProgressChanged);
            this._selectedQuest = null;
         }
         TooltipManager.getInstance().remove(this.btn_collect);
         this.btn_collect.dispose();
         this.btn_track.dispose();
         this.btn_all.dispose();
         GlobalQuestSystem.getInstance().questMovedToGrace.remove(this.onGlobalQuestMovedToGrace);
         GlobalQuestSystem.getInstance().progressChange.remove(this.onGlobalQuestProgressChange);
         GlobalQuestSystem.getInstance().questCompleted.remove(this.refreshCollectButton);
         if(this.ui_dailyQuestCounter != null)
         {
            this.ui_dailyQuestCounter.dispose();
         }
         if(this.ui_globalQuestCounter != null)
         {
            this.ui_globalQuestCounter.dispose();
         }
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         this._selectedCategoryButton = null;
         this._categoryButtons = null;
         this._xml = null;
         this._lang = null;
      }
      
      private function selectCategory(param1:String, param2:String = null) : void
      {
         var _loc3_:PushButton = null;
         var _loc4_:PushButton = null;
         var _loc5_:Vector.<Quest> = null;
         if(param1 == this._selectedCategory)
         {
            return;
         }
         if(this._selectedCategoryButton != null)
         {
            this._selectedCategoryButton.selected = false;
            this._selectedCategoryButton = null;
         }
         if(param1 == "all")
         {
            _loc3_ = this.btn_all;
         }
         else
         {
            for each(_loc4_ in this._categoryButtons)
            {
               if(_loc4_.data == param1)
               {
                  _loc3_ = _loc4_;
                  break;
               }
            }
         }
         this._selectedCategory = param1;
         previousCategory = param1;
         if(_loc3_ != null)
         {
            this._selectedCategoryButton = _loc3_;
            this._selectedCategoryButton.selected = true;
         }
         if(this._selectedCategory != null)
         {
            if(this._selectedCategory == "world")
            {
               _loc5_ = GlobalQuestSystem.getInstance().getTasks();
            }
            else if(this._selectedCategory == "all")
            {
               _loc5_ = GlobalQuestSystem.getInstance().getTasks().concat(QuestSystem.getInstance().getTasks(this._selectedCategory,Network.getInstance().playerData.getPlayerSurvivor().level,true));
            }
            else
            {
               _loc5_ = QuestSystem.getInstance().getTasks(this._selectedCategory,Network.getInstance().playerData.getPlayerSurvivor().level,true);
            }
            this.ui_list.quests = _loc5_;
            this.ui_page.numPages = this.ui_list.numPages;
            this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
            if(param2 != null)
            {
               this.ui_list.selectItemById(param2);
            }
            else
            {
               this.ui_list.selectItem(0);
            }
            this.ui_list.gotoPage(this.ui_list.getSelectedItemPage(),false);
            this.ui_page.currentPage = this.ui_list.currentPage;
            this.onQuestSelected();
         }
      }
      
      private function onGlobalQuestMovedToGrace(param1:Quest) : void
      {
         var _loc2_:int = GlobalQuestSystem.getInstance().numActiveQuests;
         this.ui_globalQuestCounter.label = String(_loc2_);
         this.ui_globalQuestCounter.visible = _loc2_ > 0;
      }
      
      private function onGlobalQuestProgressChange() : void
      {
         if(Boolean(this._selectedQuest) && this._selectedQuest.isGlobalQuest)
         {
            this.ui_infoPanel.setQuest(this._selectedQuest);
         }
      }
      
      private function refreshCollectButton(param1:Object = null) : void
      {
         this.btn_collect.enabled = this._selectedQuest.complete && !this._selectedQuest.collected;
      }
      
      private function getCollectTooltip() : String
      {
         if(this._selectedQuest == null)
         {
            return "";
         }
         if(this._selectedQuest.collected)
         {
            return this._lang.getString("quests_collectTip_collected");
         }
         if(this._selectedQuest.complete)
         {
            return this._lang.getString("quests_collectTip_collect");
         }
         if(this._selectedQuest.isGlobalQuest)
         {
            return this._lang.getString("quests_collectTip_globalRequirements");
         }
         return this._lang.getString("quests_collectTip_requirements");
      }
      
      private function onCategoryButtonClicked(param1:MouseEvent) : void
      {
         this.selectCategory(PushButton(param1.currentTarget).data);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
      
      private function onQuestSelected() : void
      {
         if(this.ui_list.selectedItem == null)
         {
            return;
         }
         if(this._selectedQuest != null)
         {
            this._selectedQuest.tracked.remove(this.onQuestTrackingChanged);
            this._selectedQuest.untracked.remove(this.onQuestTrackingChanged);
            this._selectedQuest.progressChanged.remove(this.onQuestProgressChanged);
            this._selectedQuest = null;
         }
         this._selectedQuest = UIQuestTaskListItem(this.ui_list.selectedItem).quest;
         if(this._selectedQuest == null)
         {
            this.btn_collect.enabled = false;
            this.btn_track.enabled = false;
            return;
         }
         previousQuest = this._selectedQuest.id;
         this._selectedQuest.progressChanged.add(this.onQuestProgressChanged);
         this._selectedQuest.tracked.add(this.onQuestTrackingChanged);
         this._selectedQuest.untracked.add(this.onQuestTrackingChanged);
         this.refreshCollectButton();
         var _loc1_:Boolean = QuestSystem.getInstance().isTracked(this._selectedQuest);
         var _loc2_:Boolean = QuestSystem.getInstance().maxNumQuestsBeingTracked();
         this.btn_track.label = _loc1_ ? this._lang.getString("quests_btn_untrack") : this._lang.getString("quests_btn_track");
         this.btn_track.enabled = !this._selectedQuest.complete && !this._selectedQuest.failed && (_loc1_ || !_loc2_) && !this._selectedQuest.isGlobalQuest && !(this._selectedQuest is DynamicQuest);
         if(_loc2_ && !this.btn_track.enabled)
         {
            this._tooltip.add(this.btn_track,this._lang.getString("quests_task_maxtracked"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else
         {
            this._tooltip.remove(this.btn_track);
         }
         this.ui_infoPanel.setQuest(this._selectedQuest);
      }
      
      private function onQuestProgressChanged(param1:Quest, param2:int, param3:int) : void
      {
         this.ui_infoPanel.setQuest(this._selectedQuest);
      }
      
      private function onCollectClicked(param1:MouseEvent) : void
      {
         var callback:Function;
         var xp:int = 0;
         var e:MouseEvent = param1;
         if(this._selectedQuest == null)
         {
            return;
         }
         xp = this._selectedQuest.getXPReward();
         callback = function(param1:Boolean):void
         {
            var _loc2_:BodyTextField = null;
            if(param1 && xp > 0)
            {
               _loc2_ = new BodyTextField({
                  "text":_lang.getString("msg_xp_awarded",NumberFormatter.format(xp,0)),
                  "color":16363264,
                  "size":15,
                  "bold":true,
                  "filters":[Effects.STROKE]
               });
               _loc2_.x = int(btn_collect.x + (btn_collect.width - _loc2_.width) * 0.5);
               _loc2_.y = int(btn_collect.y - 6);
               addChild(_loc2_);
               TweenMax.to(_loc2_,3,{
                  "alpha":0,
                  "y":"-40",
                  "ease":Linear.easeNone,
                  "onComplete":_loc2_.dispose
               });
            }
         };
         if(this._selectedQuest.isGlobalQuest)
         {
            GlobalQuestSystem.getInstance().collect(this._selectedQuest.id,callback);
         }
         else
         {
            QuestSystem.getInstance().collect(this._selectedQuest.id,callback);
         }
         this.btn_collect.enabled = false;
      }
      
      private function onTrackClicked(param1:MouseEvent) : void
      {
         if(this._selectedQuest.isGlobalQuest)
         {
            return;
         }
         QuestSystem.getInstance().toggleTracking(this._selectedQuest);
      }
      
      private function onQuestTrackingChanged(param1:Quest) : void
      {
         if(param1 != this._selectedQuest)
         {
            return;
         }
         this.btn_track.label = QuestSystem.getInstance().isTracked(this._selectedQuest) ? this._lang.getString("quests_btn_untrack") : this._lang.getString("quests_btn_track");
      }
   }
}

import com.deadreckoned.threshold.display.Color;
import com.exileetiquette.math.MathUtils;
import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.display.TitleTextField;
import thelaststand.app.game.data.Item;
import thelaststand.app.game.data.ItemQualityType;
import thelaststand.app.game.data.quests.DynamicQuest;
import thelaststand.app.game.data.quests.Quest;
import thelaststand.app.game.gui.UIItemImage;
import thelaststand.app.game.gui.UIItemInfo;
import thelaststand.app.gui.TooltipDirection;
import thelaststand.app.gui.TooltipManager;
import thelaststand.app.gui.UIImage;
import thelaststand.app.network.Network;
import thelaststand.app.utils.DateTimeUtils;
import thelaststand.common.lang.Language;

class QuestInfoPanel extends Sprite
{
   
   private const INDENT:int = 16;
   
   private var _network:Network;
   
   private var _lang:Language;
   
   private var _width:int;
   
   private var _height:int;
   
   private var _itemResImages:Vector.<QuestItemImage>;
   
   private var _rewardImages:Vector.<QuestItemImage>;
   
   private var bmp_background:Bitmap;
   
   private var bmp_rewardMorale:Bitmap;
   
   private var bmp_penaltyMorale:Bitmap;
   
   private var mc_divider1:BlueprintDivider;
   
   private var mc_divider2:BlueprintDivider;
   
   private var mc_divider3:BlueprintDivider;
   
   private var mc_reqTable:QuestRequirementTable;
   
   private var txt_title:TitleTextField;
   
   private var txt_desc:BodyTextField;
   
   private var txt_itemReqTitle:BodyTextField;
   
   private var txt_reqTitle:BodyTextField;
   
   private var txt_rewardTitle:BodyTextField;
   
   private var txt_rewardXP:BodyTextField;
   
   private var txt_rewardMorale:BodyTextField;
   
   private var txt_penaltyTitle:BodyTextField;
   
   private var txt_penaltyMorale:BodyTextField;
   
   private var ui_itemInfo:UIItemInfo;
   
   private var mc_timeContainer:Sprite;
   
   private var mc_iconTime:Sprite;
   
   private var txt_time:BodyTextField;
   
   private var mc_timeDivider:BlueprintDivider;
   
   private var refreshTimer:Timer;
   
   private var _quest:Quest;
   
   private var txt_contribute:BodyTextField;
   
   private var mc_contributeDivider:BlueprintDivider;
   
   private var mc_contributeContainer:Sprite;
   
   public function QuestInfoPanel()
   {
      super();
      this._network = Network.getInstance();
      this._lang = Language.getInstance();
      this._itemResImages = new Vector.<QuestItemImage>();
      this._rewardImages = new Vector.<QuestItemImage>();
      this.bmp_background = new Bitmap(new BmpQuestInfoBackground());
      this.bmp_background.x = -10;
      this.bmp_background.y = -7;
      addChild(this.bmp_background);
      this._width = 327;
      this._height = 396;
      var _loc1_:int = 10;
      this.txt_title = new TitleTextField({
         "text":" ",
         "color":16777215,
         "size":22,
         "autoSize":"none",
         "align":"center"
      });
      this.txt_title.width = this._width;
      this.txt_title.y = _loc1_;
      addChild(this.txt_title);
      _loc1_ += this.txt_title.height + 4;
      this.txt_desc = new BodyTextField({
         "color":16777215,
         "size":12,
         "multiline":true
      });
      this.txt_desc.width = this._width - this.INDENT * 2 - 2;
      this.txt_desc.x = int((this._width - this.txt_desc.width) * 0.5);
      this.txt_desc.y = _loc1_;
      addChild(this.txt_desc);
      this.mc_divider1 = new BlueprintDivider();
      this.mc_divider1.x = int((this._width - this.mc_divider1.width) * 0.5);
      this.mc_divider1.y = this.txt_desc.y + 38;
      addChild(this.mc_divider1);
      this.txt_itemReqTitle = new BodyTextField({
         "text":this._lang.getString("quests_item_req"),
         "color":12961221,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_itemReqTitle.x = this.INDENT - 2;
      this.mc_divider2 = new BlueprintDivider();
      this.mc_divider2.x = this.mc_divider1.x;
      this.txt_reqTitle = new BodyTextField({
         "text":this._lang.getString("quests_req"),
         "color":12961221,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_reqTitle.x = this.INDENT - 2;
      this.mc_timeContainer = new Sprite();
      addChild(this.mc_timeContainer);
      this.mc_timeContainer.y = this.mc_divider1.y;
      var _loc2_:int = 40;
      this.mc_iconTime = new IconTime();
      this.mc_iconTime.y = int((_loc2_ - this.mc_iconTime.height) * 0.5);
      this.mc_timeContainer.addChild(this.mc_iconTime);
      this.txt_time = new BodyTextField({
         "color":16777215,
         "size":18,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_time.text = " ";
      this.txt_time.y = int((_loc2_ - this.txt_time.height) * 0.5);
      this.mc_timeContainer.addChild(this.txt_time);
      this.mc_timeDivider = new BlueprintDivider();
      this.mc_timeDivider.y = _loc2_;
      this.mc_timeDivider.x = this.mc_divider1.x;
      this.mc_timeContainer.addChild(this.mc_timeDivider);
      this.refreshTimer = new Timer(500);
      this.refreshTimer.addEventListener(TimerEvent.TIMER,this.onRefreshTimer,false,0,true);
      var _loc3_:int = 40;
      this.mc_contributeContainer = new Sprite();
      addChild(this.mc_contributeContainer);
      this.txt_contribute = new BodyTextField({
         "color":16777215,
         "size":18,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_contribute.text = " ";
      this.txt_contribute.y = int((_loc3_ - this.txt_contribute.height) * 0.5);
      this.mc_contributeContainer.addChild(this.txt_contribute);
      this.mc_contributeDivider = new BlueprintDivider();
      this.mc_contributeDivider.y = _loc3_;
      this.mc_contributeDivider.x = this.mc_divider1.x;
      this.mc_contributeContainer.addChild(this.mc_contributeDivider);
      this.mc_divider3 = new BlueprintDivider();
      this.mc_divider3.x = this.mc_divider1.x;
      this.mc_divider3.y = 314;
      addChild(this.mc_divider3);
      this.txt_rewardTitle = new BodyTextField({
         "text":this._lang.getString("quests_rewards"),
         "color":12961221,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_rewardTitle.x = this.INDENT - 2;
      this.txt_rewardTitle.y = int(this.mc_divider3.y + 10);
      this.txt_rewardXP = new BodyTextField({
         "text":" ",
         "color":14260480,
         "size":18,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_rewardXP.filters = [new GlowFilter(2825493,1,4,4,10,1)];
      this.bmp_rewardMorale = new Bitmap(new BmpIconMorale5());
      this.bmp_rewardMorale.filters = [Effects.ICON_SHADOW];
      this.txt_rewardMorale = new BodyTextField({
         "text":" ",
         "color":Effects.COLOR_GOOD,
         "size":18,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_rewardMorale.filters = [new GlowFilter(new Color(Effects.COLOR_GOOD).tint(0,0.75).RGB,1,4,4,10,1)];
      this.txt_penaltyTitle = new BodyTextField({
         "text":this._lang.getString("quests_failurePenalties"),
         "color":12961221,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_penaltyTitle.x = this.INDENT - 2;
      this.txt_penaltyTitle.y = int(this.mc_divider3.y + 10);
      this.bmp_penaltyMorale = new Bitmap(new BmpIconMorale1());
      this.bmp_penaltyMorale.filters = [Effects.ICON_SHADOW];
      this.txt_penaltyMorale = new BodyTextField({
         "text":" ",
         "color":Effects.COLOR_WARNING,
         "size":18,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_penaltyMorale.filters = [new GlowFilter(new Color(Effects.COLOR_WARNING).tint(0,0.75).RGB,1,4,4,10,1)];
      this.ui_itemInfo = new UIItemInfo();
   }
   
   public function dispose() : void
   {
      var _loc1_:QuestItemImage = null;
      if(parent != null)
      {
         parent.removeChild(this);
      }
      TooltipManager.getInstance().removeAllFromParent(this);
      this._lang = null;
      for each(_loc1_ in this._itemResImages)
      {
         _loc1_.dispose();
      }
      this._itemResImages = null;
      for each(_loc1_ in this._rewardImages)
      {
         this.ui_itemInfo.removeRolloverTarget(_loc1_);
         _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.onRewardMouseOver);
         _loc1_.dispose();
      }
      this._rewardImages = null;
      this.bmp_background.bitmapData.dispose();
      this.bmp_background.bitmapData = null;
      if(this.mc_reqTable != null)
      {
         this.mc_reqTable.dispose();
      }
      this.txt_desc.dispose();
      this.txt_itemReqTitle.dispose();
      this.txt_reqTitle.dispose();
      this.txt_title.dispose();
      this.txt_time.dispose();
      this.txt_contribute.dispose();
      this.txt_rewardTitle.dispose();
      this.txt_rewardXP.dispose();
      this.txt_rewardMorale.dispose();
      this.txt_penaltyTitle.dispose();
      this.txt_penaltyMorale.dispose();
      this.bmp_rewardMorale.bitmapData.dispose();
      this.bmp_rewardMorale.filters = [];
      this.bmp_penaltyMorale.bitmapData.dispose();
      this.bmp_penaltyMorale.filters = [];
      this.refreshTimer.stop();
      this.refreshTimer.removeEventListener(TimerEvent.TIMER,this.onRefreshTimer);
      this.refreshTimer = null;
      this._network = null;
   }
   
   public function setQuest(param1:Quest) : void
   {
      var _loc2_:XML = null;
      var _loc3_:int = 0;
      var _loc4_:QuestItemImage = null;
      var _loc5_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:int = 0;
      var _loc13_:int = 0;
      var _loc14_:Object = null;
      var _loc15_:Object = null;
      var _loc16_:Object = null;
      var _loc17_:Item = null;
      var _loc18_:DynamicQuest = null;
      var _loc19_:Array = null;
      var _loc20_:Object = null;
      if(param1 == null)
      {
         return;
      }
      this._quest = param1;
      if(this.mc_reqTable != null)
      {
         this.mc_reqTable.dispose();
         this.mc_reqTable = null;
      }
      if(this.txt_rewardXP.parent != null)
      {
         this.txt_rewardXP.parent.removeChild(this.txt_rewardXP);
      }
      if(this.txt_rewardMorale.parent != null)
      {
         this.txt_rewardMorale.parent.removeChild(this.txt_rewardMorale);
      }
      if(this.bmp_rewardMorale.parent != null)
      {
         this.bmp_rewardMorale.parent.removeChild(this.bmp_rewardMorale);
      }
      if(this.txt_penaltyTitle.parent != null)
      {
         this.txt_penaltyTitle.parent.removeChild(this.txt_penaltyTitle);
      }
      if(this.txt_penaltyMorale.parent != null)
      {
         this.txt_penaltyMorale.parent.removeChild(this.txt_penaltyMorale);
      }
      if(this.bmp_penaltyMorale.parent != null)
      {
         this.bmp_penaltyMorale.parent.removeChild(this.bmp_penaltyMorale);
      }
      if(this.mc_divider2.parent != null)
      {
         this.mc_divider2.parent.removeChild(this.mc_divider2);
      }
      for each(_loc4_ in this._itemResImages)
      {
         TooltipManager.getInstance().remove(_loc4_);
         _loc4_.dispose();
      }
      this._itemResImages.length = 0;
      for each(_loc4_ in this._rewardImages)
      {
         this.ui_itemInfo.removeRolloverTarget(_loc4_);
         _loc4_.removeEventListener(MouseEvent.MOUSE_OVER,this.onRewardMouseOver);
         _loc4_.dispose();
      }
      this._rewardImages.length = 0;
      this.txt_title.text = param1.getName().toUpperCase();
      this.txt_desc.htmlText = param1.getDescription();
      this.mc_divider1.y = this.txt_desc.y + this.txt_desc.height + 10;
      _loc5_ = int(this.mc_divider1.y + 6);
      this.refreshTimer.stop();
      if(param1.endTime != null)
      {
         this.mc_timeContainer.y = this.mc_divider1.y;
         this.mc_timeContainer.visible = true;
         _loc5_ = int(this.mc_timeContainer.y + this.mc_timeDivider.y + 6);
         this.onRefreshTimer(null);
         this.refreshTimer.start();
      }
      else
      {
         this.mc_timeContainer.visible = false;
      }
      if(param1.isGlobalQuest)
      {
         this.mc_contributeContainer.y = _loc5_ - 6;
         this.mc_contributeContainer.visible = true;
         _loc5_ = int(this.mc_contributeContainer.y + this.mc_contributeDivider.y + 6);
      }
      else
      {
         this.mc_contributeContainer.visible = false;
      }
      var _loc6_:Array = param1.getItemResourceGoals();
      if(_loc6_.length > 0)
      {
         this.txt_itemReqTitle.y = _loc5_;
         addChild(this.txt_itemReqTitle);
         _loc5_ += this.txt_itemReqTitle.height + 6;
         _loc10_ = int(this.INDENT);
         _loc11_ = _loc5_;
         _loc12_ = 0;
         _loc13_ = 2;
         _loc3_ = 0;
         while(_loc3_ < _loc6_.length)
         {
            _loc14_ = _loc6_[_loc3_];
            _loc4_ = new QuestItemImage(_loc14_.image,_loc14_.prog,_loc14_.total);
            _loc4_.x = _loc10_;
            _loc4_.y = _loc11_;
            addChild(_loc4_);
            if(++_loc12_ >= _loc13_)
            {
               _loc12_ = 0;
               _loc10_ = int(this.INDENT);
               _loc11_ += _loc4_.height + 6;
            }
            else
            {
               _loc10_ += 140;
            }
            TooltipManager.getInstance().add(_loc4_,_loc14_.name,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT,0);
            this._itemResImages.push(_loc4_);
            _loc3_++;
         }
         if(_loc4_ != null)
         {
            _loc5_ = _loc4_.y + _loc4_.height + 8;
         }
      }
      else if(this.txt_itemReqTitle.parent != null)
      {
         this.txt_itemReqTitle.parent.removeChild(this.txt_itemReqTitle);
      }
      var _loc7_:Array = param1.getNonItemResourceGoals();
      if(_loc7_.length > 0)
      {
         if(_loc6_.length > 0)
         {
            this.mc_divider2.y = _loc5_;
            addChild(this.mc_divider2);
            _loc5_ += 6;
         }
         this.txt_reqTitle.y = _loc5_;
         addChild(this.txt_reqTitle);
         _loc5_ += this.txt_reqTitle.height + 4;
         this.mc_reqTable = new QuestRequirementTable(298);
         this.mc_reqTable.x = this.INDENT;
         this.mc_reqTable.y = _loc5_;
         addChild(this.mc_reqTable);
         _loc3_ = 0;
         while(_loc3_ < _loc7_.length)
         {
            _loc15_ = _loc7_[_loc3_];
            this.mc_reqTable.addRow(_loc15_.name,_loc15_.prog,_loc15_.total,param1.isGlobalQuest,param1.failed,_loc15_.userCont,_loc15_.reqCont);
            _loc3_++;
         }
      }
      else if(this.txt_reqTitle.parent != null)
      {
         this.txt_reqTitle.parent.removeChild(this.txt_reqTitle);
      }
      var _loc8_:int = 16;
      var _loc9_:Array = param1.getRewards();
      if(_loc9_.length > 0)
      {
         _loc5_ = int(this.txt_rewardTitle.y + this.txt_rewardTitle.height + 6);
         addChild(this.txt_rewardTitle);
         _loc3_ = 0;
         while(_loc3_ < _loc9_.length)
         {
            _loc16_ = _loc9_[_loc3_];
            _loc17_ = _loc16_ as Item;
            if(_loc17_ != null)
            {
               _loc4_ = new QuestItemImage(_loc17_);
               _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.onRewardMouseOver,false,0,true);
               _loc4_.x = _loc8_;
               _loc4_.y = _loc5_;
               addChild(_loc4_);
               this._rewardImages.push(_loc4_);
               this.ui_itemInfo.addRolloverTarget(_loc4_);
               _loc8_ = int(_loc4_.x + _loc4_.width + 8);
            }
            else if(_loc16_.type == "xp")
            {
               this.txt_rewardXP.text = this._lang.getString("quests_xp_reward",NumberFormatter.format(int(_loc16_.value),0));
               this.txt_rewardXP.y = int(_loc5_ + (34 - this.txt_rewardXP.height) * 0.5);
               this.txt_rewardXP.x = _loc8_;
               addChild(this.txt_rewardXP);
               _loc8_ = int(this.txt_rewardXP.x + this.txt_rewardXP.width + 10);
            }
            else if(_loc16_.type == "morale")
            {
               this.bmp_rewardMorale.x = _loc8_;
               this.bmp_rewardMorale.y = int(_loc5_ + (34 - this.bmp_rewardMorale.height) * 0.5);
               addChild(this.bmp_rewardMorale);
               _loc8_ += this.bmp_rewardMorale.width + 2;
               this.txt_rewardMorale.text = this._lang.getString("quests_morale_reward",NumberFormatter.format(int(_loc16_.value),0));
               this.txt_rewardMorale.y = int(_loc5_ + (34 - this.txt_rewardMorale.height) * 0.5);
               this.txt_rewardMorale.x = _loc8_;
               addChild(this.txt_rewardMorale);
               _loc8_ = int(this.txt_rewardMorale.x + this.txt_rewardMorale.width + 10);
            }
            _loc3_++;
         }
         _loc8_ += 30;
      }
      if(this._quest is DynamicQuest && !this._quest.complete)
      {
         _loc18_ = DynamicQuest(this._quest);
         _loc19_ = _loc18_.getFailurePenalties();
         if(_loc19_.length > 0)
         {
            this.txt_penaltyTitle.x = _loc8_;
            addChild(this.txt_penaltyTitle);
            _loc3_ = 0;
            while(_loc3_ < _loc19_.length)
            {
               _loc20_ = _loc19_[_loc3_];
               if(_loc20_.type == "morale")
               {
                  this.bmp_penaltyMorale.x = _loc8_;
                  this.bmp_penaltyMorale.y = int(_loc5_ + (34 - this.bmp_penaltyMorale.height) * 0.5);
                  addChild(this.bmp_penaltyMorale);
                  _loc8_ += this.bmp_penaltyMorale.width + 2;
                  this.txt_penaltyMorale.text = this._lang.getString("quests_morale_penalty",NumberFormatter.format(int(_loc20_.value),0));
                  this.txt_penaltyMorale.y = int(_loc5_ + (34 - this.txt_penaltyMorale.height) * 0.5);
                  this.txt_penaltyMorale.x = _loc8_;
                  addChild(this.txt_penaltyMorale);
                  _loc8_ = int(this.txt_penaltyMorale.x + this.txt_penaltyMorale.width + 10);
               }
               _loc3_++;
            }
         }
      }
   }
   
   private function onRewardMouseOver(param1:MouseEvent) : void
   {
      this.ui_itemInfo.setItem(QuestItemImage(param1.currentTarget).item);
   }
   
   private function onRefreshTimer(param1:TimerEvent) : void
   {
      var _loc3_:Boolean = false;
      var _loc4_:Number = NaN;
      var _loc5_:Number = NaN;
      var _loc6_:int = 0;
      if(this._quest.isGlobalQuest)
      {
         _loc3_ = Boolean(this._network.playerData.globalQuests.getContributed(this._quest.id));
         this.txt_contribute.text = this._lang.getString(_loc3_ ? "questStatus.contributed" : "questStatus.notContributed");
         this.txt_contribute.textColor = _loc3_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
         this.txt_contribute.x = int((this._width - this.txt_contribute.width) * 0.5);
         this.txt_contribute.alpha = 1;
      }
      var _loc2_:String = "";
      this.mc_iconTime.visible = true;
      this.txt_time.textColor = 16777215;
      if(this._quest.failed)
      {
         _loc2_ = this._lang.getString("questStatus.failed");
         this.txt_time.textColor = Effects.COLOR_WARNING;
         this.mc_iconTime.visible = false;
         this.txt_contribute.alpha = 0.5;
      }
      else if(this._quest.complete)
      {
         _loc2_ = this._lang.getString("questStatus.complete");
         this.mc_iconTime.visible = false;
      }
      else
      {
         _loc4_ = this._quest.endTime.time - this._network.serverTime;
         _loc5_ = this._quest.getTotalProgress() / this._quest.getAllGoalsTotal();
         if(_loc4_ <= 0)
         {
            _loc2_ = this._lang.getString("questStatus.calculating");
         }
         else
         {
            _loc2_ = DateTimeUtils.secondsToString(_loc4_ / 1000,false,true);
         }
      }
      this.txt_time.text = _loc2_;
      if(this.mc_iconTime.visible)
      {
         _loc6_ = this.mc_iconTime.width + this.txt_time.width + 4;
         this.mc_iconTime.x = int((this._width - _loc6_) * 0.5);
         this.txt_time.x = int((this._width - _loc6_) * 0.5 + this.mc_iconTime.width + 4);
      }
      else
      {
         this.txt_time.x = int((this._width - this.txt_time.width) * 0.5);
      }
   }
}

class QuestItemImage extends Sprite
{
   
   private var _borderSize:int = 2;
   
   private var _borderColor:uint = 5607085;
   
   private var _borderAlpha:Number = 1;
   
   private var ui_image:Sprite;
   
   private var txt_progress:BodyTextField;
   
   public var item:Item;
   
   public function QuestItemImage(param1:*, param2:int = 0, param3:int = 0)
   {
      super();
      if(param1 is String)
      {
         this.ui_image = new UIImage(32,32,0,1,true,String(param1));
      }
      else if(param1 is Item)
      {
         this.ui_image = new UIItemImage(32,32);
         UIItemImage(this.ui_image).item = param1;
         UIItemImage(this.ui_image).showQuantity = false;
         this.item = param1;
         this._borderColor = Effects["COLOR_" + ItemQualityType.getName(this.item.qualityType)];
         this._borderAlpha = 0.4;
      }
      this.ui_image.x = this.ui_image.y = this._borderSize;
      addChild(this.ui_image);
      graphics.beginFill(this._borderColor,this._borderAlpha);
      graphics.drawRect(0,0,this.ui_image.width + this._borderSize * 2,this.ui_image.height + this._borderSize * 2);
      graphics.endFill();
      if(param3 > 0)
      {
         if(param2 > param3)
         {
            param2 = param3;
         }
         this.txt_progress = new BodyTextField({
            "color":(param2 < param3 ? Effects.COLOR_WARNING : 16777215),
            "size":15,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_progress.x = int(this.ui_image.x + this.ui_image.width + 6);
         this.txt_progress.y = int(this.ui_image.y + (this.ui_image.height - this.txt_progress.height) * 0.5);
         this.txt_progress.filters = [new GlowFilter(0,1,3,3,10,1)];
         addChild(this.txt_progress);
         this.txt_progress.text = NumberFormatter.format(param2,0) + " / " + NumberFormatter.format(param3,0);
      }
      hitArea = this.ui_image;
   }
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this.ui_image["dispose"]();
      this.ui_image = null;
      if(this.txt_progress != null)
      {
         this.txt_progress.dispose();
         this.txt_progress = null;
      }
   }
}

class QuestRequirementTable extends Sprite
{
   
   private var _rowCount:int = 0;
   
   private var _rowHeight:int = 28;
   
   private var _rowSpacing:int = 1;
   
   private var _rowY:int = 0;
   
   private var _width:int;
   
   private var _textCleanUpList:Vector.<BodyTextField>;
   
   public function QuestRequirementTable(param1:int)
   {
      super();
      this._width = param1;
      this._textCleanUpList = new Vector.<BodyTextField>();
   }
   
   public function addRow(param1:String, param2:int = 0, param3:int = 0, param4:Boolean = false, param5:Boolean = false, param6:int = 0, param7:int = 0) : void
   {
      var _loc8_:BodyTextField = null;
      var _loc9_:BodyTextField = null;
      var _loc12_:Number = NaN;
      var _loc13_:* = false;
      var _loc14_:uint = 0;
      var _loc15_:uint = 0;
      var _loc16_:BodyTextField = null;
      var _loc17_:BodyTextField = null;
      var _loc10_:Boolean = param5 && param2 < param3;
      if(param3 > 0)
      {
         if(param2 > param3)
         {
            param2 = param3;
         }
         _loc12_ = param2 / param3;
         _loc9_ = new BodyTextField({
            "color":16777215,
            "size":15,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         if(param4)
         {
            _loc9_.text = Math.floor(_loc12_ * 100) + "%";
         }
         else
         {
            _loc9_.text = (_loc10_ ? "" : NumberFormatter.format(param2,0) + " / ") + NumberFormatter.format(param3,0);
         }
         _loc9_.x = int(this._width - _loc9_.width - 6);
         _loc9_.y = int(this._rowY + (this._rowHeight - _loc9_.height) * 0.5);
         addChild(_loc9_);
      }
      _loc8_ = new BodyTextField({
         "color":16777215,
         "size":15,
         "bold":true,
         "multiline":true,
         "leading":2,
         "antiAliasType":AntiAliasType.ADVANCED,
         "filters":[Effects.TEXT_SHADOW]
      });
      _loc8_.text = param1.toUpperCase();
      _loc8_.width = _loc9_ != null ? int(_loc9_.x - _loc8_.x - 4) : int(this._width - _loc8_.x * 2);
      addChild(_loc8_);
      var _loc11_:int = int(this._rowHeight);
      if(_loc8_.height <= this._rowHeight)
      {
         _loc11_ = int(this._rowHeight);
      }
      else
      {
         _loc11_ = int(_loc8_.height + 8);
      }
      _loc8_.y = int(this._rowY + (_loc11_ - _loc8_.height) * 0.5);
      _loc8_.x = 6;
      if(_loc9_ != null)
      {
         _loc9_.y = _loc8_.y;
      }
      graphics.beginFill(_loc10_ ? 10027008 : 0,this._rowCount % 2 == 0 ? 0.4 : 0.2);
      graphics.drawRect(0,this._rowY,this._width,_loc11_);
      graphics.endFill();
      if(param4)
      {
         graphics.beginFill(_loc10_ ? 11141120 : 1383971,0.6);
         graphics.drawRect(0,this._rowY,int(this._width * _loc12_),_loc11_);
         graphics.endFill();
      }
      this._textCleanUpList.push(_loc8_);
      this._textCleanUpList.push(_loc9_);
      this._rowY += _loc11_;
      if(param7 > 0)
      {
         _loc13_ = param6 >= param7;
         _loc14_ = _loc13_ ? 1582121 : 14018543;
         _loc15_ = _loc13_ ? 9022063 : 5532534;
         _loc16_ = new BodyTextField({
            "color":_loc14_,
            "size":11,
            "bold":false,
            "autosize":TextFieldAutoSize.LEFT,
            "wordwrap":false,
            "multiline":false,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         _loc16_.text = Language.getInstance().getString("questStatus.yourContribution");
         _loc16_.x = 18;
         _loc16_.y = this._rowY - 1;
         addChild(_loc16_);
         _loc17_ = new BodyTextField({
            "color":_loc14_,
            "size":11,
            "bold":false,
            "autosize":TextFieldAutoSize.LEFT,
            "wordwrap":false,
            "multiline":false,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         _loc17_.text = param6 + " / " + param7;
         _loc17_.x = this._width - _loc17_.width - 6;
         _loc17_.y = _loc16_.y;
         addChild(_loc17_);
         graphics.beginFill(4280150,0.9);
         graphics.drawRect(0,this._rowY,this._width,14);
         graphics.beginFill(_loc15_,1);
         graphics.drawRect(0,this._rowY,MathUtils.clamp(param6 / param7,0,1) * this._width,14);
         graphics.beginFill(_loc13_ ? 1582121 : 8231077);
         graphics.moveTo(9,this._rowY + 3);
         graphics.lineTo(9,this._rowY + 11);
         graphics.lineTo(13,this._rowY + 7);
         graphics.lineTo(9,this._rowY + 3);
         this._textCleanUpList.push(_loc16_);
         this._textCleanUpList.push(_loc17_);
         this._rowY += 14 + 4;
      }
      this._rowY += this._rowSpacing;
      ++this._rowCount;
   }
   
   public function dispose() : void
   {
      var _loc1_:BodyTextField = null;
      if(parent != null)
      {
         parent.removeChild(this);
      }
      for each(_loc1_ in this._textCleanUpList)
      {
         if(_loc1_ != null)
         {
            _loc1_.dispose();
         }
      }
      this._textCleanUpList = null;
   }
}
