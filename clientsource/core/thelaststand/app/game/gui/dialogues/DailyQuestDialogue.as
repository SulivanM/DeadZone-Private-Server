package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.data.quests.DynamicQuest;
   import thelaststand.app.game.data.quests.DynamicQuestType;
   import thelaststand.app.game.gui.survivor.UISurvivorModelView;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class DailyQuestDialogue extends BaseDialogue
   {
      
      private var _quest:DynamicQuest;
      
      private var _lang:Language;
      
      private var btn_decline:PushButton;
      
      private var txt_desc:BodyTextField;
      
      private var ui_questInfo:QuestInfo;
      
      private var ui_modelView:UISurvivorModelView;
      
      private var mc_container:Sprite;
      
      private var bmp_quote1:Bitmap;
      
      private var bmp_quote2:Bitmap;
      
      public function DailyQuestDialogue(param1:DynamicQuest)
      {
         var _loc3_:Survivor = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         this.mc_container = new Sprite();
         super("dailyQuest",this.mc_container);
         this._quest = param1;
         this._lang = Language.getInstance();
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = int(_padding * 0.5);
         var _loc2_:int = _padding * 0.5;
         if(this._quest.questType == DynamicQuestType.SURVIVOR_REQUEST)
         {
            _loc4_ = this._quest.getGoalOfType("xpInc");
            if(_loc4_ != null)
            {
               _loc3_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc4_.survivor);
            }
            else
            {
               _loc5_ = Network.getInstance().playerData.compound.survivors.length;
               if(_loc5_ == 1)
               {
                  _loc3_ = Network.getInstance().playerData.getPlayerSurvivor();
               }
               else
               {
                  while(_loc3_ == null)
                  {
                     _loc3_ = Network.getInstance().playerData.compound.survivors.getSurvivor(int(Math.random() * _loc5_));
                     if(_loc3_ == Network.getInstance().playerData.getPlayerSurvivor())
                     {
                        _loc3_ = null;
                     }
                  }
               }
            }
            addTitle(this._lang.getString("quest_dyn_title_srv",_loc3_.firstName),6398924);
            _loc2_ = int(this.drawSurvivorRequest(_loc3_,_loc2_) + _padding);
         }
         this.ui_questInfo = new QuestInfo(this._quest);
         this.ui_questInfo.y = _loc2_;
         this.mc_container.addChild(this.ui_questInfo);
         this.btn_decline = PushButton(addButton("Decline",true,{
            "width":120,
            "iconBackgroundColor":8796961,
            "icon":new Bitmap(new BmpIconButtonClose())
         }));
         this.btn_decline.clicked.addOnce(this.onClickDecline);
         addButton("Accept",false,{
            "width":120,
            "iconBackgroundColor":5796375,
            "icon":new Bitmap(new BmpIconButtonNext())
         }).clicked.addOnce(this.onClickAccept);
         TooltipManager.getInstance().add(this.btn_decline,this._lang.getString("quests_dq_decline_tip"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._quest = null;
         this._lang = null;
         this.ui_questInfo.dispose();
         if(this.ui_modelView != null)
         {
            this.ui_modelView.dispose();
         }
         if(this.txt_desc != null)
         {
            this.txt_desc.dispose();
         }
         if(this.bmp_quote1 != null)
         {
            this.bmp_quote1.bitmapData.dispose();
         }
         if(this.bmp_quote2 != null)
         {
            this.bmp_quote2.bitmapData.dispose();
         }
         this.btn_decline = null;
      }
      
      private function drawSurvivorRequest(param1:Survivor, param2:int) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc3_ = 120;
         _loc4_ = 134;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,334,_loc4_,0,param2);
         this.mc_container.graphics.beginFill(7763574);
         this.mc_container.graphics.drawRect(_loc3_,param2,1,_loc4_);
         this.mc_container.graphics.endFill();
         this.bmp_quote1 = new Bitmap(new BmpQuote());
         this.bmp_quote1.x = _loc3_ + 10;
         this.bmp_quote1.y = param2 + 10;
         this.mc_container.addChild(this.bmp_quote1);
         this.bmp_quote2 = new Bitmap(new BmpQuote());
         this.bmp_quote2.scaleX = -1;
         this.bmp_quote2.x = 324;
         this.bmp_quote2.y = param2 + _loc4_ - this.bmp_quote2.height - 10;
         this.mc_container.addChild(this.bmp_quote2);
         this.ui_modelView = new UISurvivorModelView(_loc3_ - 2,_loc4_ - 2,new BmpSrvRequestBackground());
         this.ui_modelView.x = 1;
         this.ui_modelView.y = param2 + 1;
         this.ui_modelView.mouseEnabled = false;
         this.ui_modelView.showInjured = this.ui_modelView.showWeapon = false;
         this.ui_modelView.survivor = param1;
         this.ui_modelView.actorMesh.scaleX = this.ui_modelView.actorMesh.scaleY = this.ui_modelView.actorMesh.scaleZ = 1.5;
         this.ui_modelView.cameraPosition.y = -150;
         this.mc_container.addChild(this.ui_modelView);
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":13,
            "multiline":true
         });
         this.txt_desc.htmlText = StringUtils.htmlSetDoubleBreakLeading(this.generateSurvivorRequestText(param1));
         this.txt_desc.width = 180;
         this.txt_desc.x = int(_loc3_ + (334 - _loc3_ - this.txt_desc.width) * 0.5);
         this.txt_desc.y = int(param2 + (_loc4_ - this.txt_desc.height) * 0.5);
         this.mc_container.addChild(this.txt_desc);
         return _loc4_;
      }
      
      private function generateSurvivorRequestText(param1:Survivor) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc7_:XMLList = null;
         var _loc8_:XMLList = null;
         var _loc9_:XMLList = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:SurvivorCollection = null;
         var _loc13_:Survivor = null;
         var _loc14_:String = null;
         var _loc5_:XML = Language.getInstance().xml;
         _loc6_ = this._quest.getNonItemResourceGoals()[0];
         switch(_loc6_.data.type)
         {
            case "xpInc":
               _loc7_ = _loc5_.data.srv_request_desc.xp_leadIn;
               break;
            case "statInc":
               _loc10_ = _loc6_.data.stat;
               if(_loc10_ == "foodFound" || _loc10_ == "waterFound" || _loc10_ == "woodFound" || _loc10_ == "metalFound" || _loc10_ == "clothFound" || _loc10_ == "ammunitionFound")
               {
                  _loc11_ = _loc10_.substr(0,_loc10_.indexOf("Found"));
                  _loc7_ = _loc5_.data.srv_request_desc.res_leadIn;
                  _loc8_ = _loc5_.data.srv_request_desc.res_sentence;
               }
               else if(_loc10_.toLowerCase().indexOf("kills") > -1)
               {
                  _loc7_ = _loc5_.data.srv_request_desc.kill_leadIn;
                  _loc8_ = _loc5_.data.srv_request_desc.kill_sentence;
               }
               _loc9_ = _loc5_.data.srv_request_desc[_loc10_];
         }
         continue loop0;
      }
      
      private function onClickAccept(param1:MouseEvent) : void
      {
         Network.getInstance().save(null,SaveDataMethod.QUEST_DAILY_ACCEPT);
         QuestSystem.getInstance().addQuest(this._quest);
         close();
      }
      
      private function onClickDecline(param1:MouseEvent) : void
      {
         Network.getInstance().save(null,SaveDataMethod.QUEST_DAILY_DECLINE);
         Network.getInstance().playerData.dailyQuest = null;
      }
   }
}

import com.deadreckoned.threshold.display.Color;
import com.exileetiquette.utils.NumberFormatter;
import com.quasimondo.geom.ColorMatrix;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.utils.Timer;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.Item;
import thelaststand.app.game.data.quests.DynamicQuest;
import thelaststand.app.game.gui.UIItemInfo;
import thelaststand.app.game.gui.lists.UIInventoryListItem;
import thelaststand.app.network.Network;
import thelaststand.app.utils.DateTimeUtils;
import thelaststand.app.utils.GraphicUtils;
import thelaststand.common.lang.Language;

class QuestInfo extends Sprite
{
   
   private var _quest:DynamicQuest;
   
   private var _padding:int = 10;
   
   private var _width:int = 334;
   
   private var _height:int = 0;
   
   private var _refreshTimer:Timer;
   
   private var _itemRewards:Vector.<UIInventoryListItem>;
   
   private var txt_time:BodyTextField;
   
   private var txt_reqTitle:BodyTextField;
   
   private var txt_rewardTitle:BodyTextField;
   
   private var txt_rewardXP:BodyTextField;
   
   private var txt_rewardMorale:BodyTextField;
   
   private var txt_penaltyTitle:BodyTextField;
   
   private var txt_penaltyMorale:BodyTextField;
   
   private var mc_rewarditemsContainer:Sprite;
   
   private var mc_iconTime:IconTime;
   
   private var bmp_rewardMorale:Bitmap;
   
   private var bmp_penaltyMorale:Bitmap;
   
   private var mc_divider1:Sprite;
   
   private var mc_divider2:Sprite;
   
   private var mc_timeContainer:Sprite;
   
   private var ui_itemInfo:UIItemInfo;
   
   public function QuestInfo(param1:DynamicQuest)
   {
      var rowHeight:int;
      var rowWidth:int;
      var goals:Array;
      var tx:int;
      var desaturate:ColorMatrix;
      var item_tx:int;
      var rewards:Array;
      var penalties:Array;
      var i:int = 0;
      var ty:int = 0;
      var goal:Object = null;
      var row:Sprite = null;
      var txt_label:BodyTextField = null;
      var txt_total:BodyTextField = null;
      var rewardObj:Object = null;
      var item:Item = null;
      var uiItem:UIInventoryListItem = null;
      var xp:int = 0;
      var morale:int = 0;
      var penalty:Object = null;
      var quest:DynamicQuest = param1;
      this._itemRewards = new Vector.<UIInventoryListItem>();
      super();
      this._quest = quest;
      this._refreshTimer = new Timer(500);
      this._refreshTimer.addEventListener(TimerEvent.TIMER,this.onRefreshTimer,false,0,true);
      this.txt_reqTitle = new BodyTextField({
         "text":Language.getInstance().getString("quests_req"),
         "color":12961221,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_reqTitle.x = this._padding - 2;
      this.txt_reqTitle.y = this._padding;
      addChild(this.txt_reqTitle);
      this.ui_itemInfo = new UIItemInfo();
      rowHeight = 28;
      rowWidth = this._width - this._padding * 2;
      goals = quest.getNonItemResourceGoals();
      tx = int(this._padding);
      ty = int(this.txt_reqTitle.y + this.txt_reqTitle.height + this._padding * 0.5);
      i = 0;
      while(i < goals.length)
      {
         goal = goals[i];
         row = new Sprite();
         row.x = tx;
         row.y = ty;
         row.graphics.beginFill(1644825,i % 2 == 0 ? 1 : 0);
         row.graphics.drawRect(0,0,rowWidth,rowHeight);
         row.graphics.endFill();
         txt_label = new BodyTextField({
            "color":16777215,
            "size":15,
            "bold":true
         });
         txt_label.text = goal.name.toUpperCase();
         txt_label.maxWidth = 254;
         txt_label.x = 4;
         txt_label.y = int((rowHeight - txt_label.height) * 0.5);
         row.addChild(txt_label);
         txt_total = new BodyTextField({
            "color":16777215,
            "size":15,
            "bold":true
         });
         txt_total.text = "x " + NumberFormatter.format(goal.total,0);
         txt_total.x = int(rowWidth - txt_total.width - 4);
         txt_total.y = int((rowHeight - txt_total.height) * 0.5);
         row.addChild(txt_total);
         ty += rowHeight;
         addChild(row);
         i++;
      }
      this.mc_divider1 = new BlueprintDivider();
      this.mc_divider1.x = this._padding;
      this.mc_divider1.y = ty + this._padding;
      this.mc_divider1.width = int(this._width - this.mc_divider1.x * 2);
      addChild(this.mc_divider1);
      this.txt_time = new BodyTextField({
         "color":16777215,
         "size":18,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_time.text = " ";
      desaturate = new ColorMatrix();
      desaturate.desaturate();
      this.mc_iconTime = new IconTime();
      this.mc_iconTime.y = int(this.txt_time.y + (this.txt_time.height - this.mc_iconTime.height) * 0.5 + 2);
      this.mc_iconTime.filters = [desaturate.filter];
      this.mc_timeContainer = new Sprite();
      this.mc_timeContainer.addChild(this.mc_iconTime);
      this.mc_timeContainer.addChild(this.txt_time);
      this.mc_timeContainer.y = int(this.mc_divider1.y + this._padding);
      addChild(this.mc_timeContainer);
      this.mc_divider2 = new BlueprintDivider();
      this.mc_divider2.x = this._padding;
      this.mc_divider2.y = int(this.mc_timeContainer.y + this.mc_timeContainer.height + this._padding);
      this.mc_divider2.width = int(this._width - this.mc_divider2.x * 2);
      addChild(this.mc_divider2);
      this.txt_rewardTitle = new BodyTextField({
         "text":Language.getInstance().getString("quests_rewards"),
         "color":12961221,
         "size":11,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_rewardTitle.x = this._padding - 2;
      this.txt_rewardTitle.y = int(this.mc_divider2.y + this._padding);
      addChild(this.txt_rewardTitle);
      tx = this._padding - 2;
      item_tx = 0;
      rewards = quest.getRewards();
      rewards.sort(function(param1:Object, param2:Object):int
      {
         return String(param1.type).localeCompare(param2.type);
      });
      i = 0;
      for(; i < rewards.length; i++)
      {
         rewardObj = rewards[i];
         if(rewardObj is Item)
         {
            if(this.mc_rewarditemsContainer == null)
            {
               this.mc_rewarditemsContainer = new Sprite();
               this.mc_rewarditemsContainer.x = tx;
               this.mc_rewarditemsContainer.y = int(this.txt_rewardTitle.y + this.txt_rewardTitle.height + this._padding * 0.5);
               addChild(this.mc_rewarditemsContainer);
            }
            item = Item(rewardObj);
            uiItem = new UIInventoryListItem(32);
            uiItem.mouseOver.add(this.onRewardItemMouseOver);
            uiItem.itemData = item;
            uiItem.x = item_tx;
            uiItem.y = 0;
            this.ui_itemInfo.addRolloverTarget(uiItem);
            this._itemRewards.push(uiItem);
            this.mc_rewarditemsContainer.addChild(uiItem);
            item_tx += uiItem.width + 6;
            tx += int(uiItem.width + 6);
            this._height = int(this.mc_rewarditemsContainer.y + this.mc_rewarditemsContainer.height + this._padding);
            continue;
         }
         switch(rewardObj.type)
         {
            case "xp":
               xp = int(rewardObj.value);
               this.txt_rewardXP = new BodyTextField({
                  "text":Language.getInstance().getString("quests_xp_reward",NumberFormatter.format(xp,0)),
                  "color":14260480,
                  "size":18,
                  "bold":true,
                  "antiAliasType":AntiAliasType.ADVANCED
               });
               this.txt_rewardXP.x = tx;
               this.txt_rewardXP.y = int(this.txt_rewardTitle.y + this.txt_rewardTitle.height + this._padding * 0.5);
               this.txt_rewardXP.filters = [new GlowFilter(2825493,1,4,4,10,1)];
               addChild(this.txt_rewardXP);
               tx += int(this.txt_rewardXP.width + 10);
               this._height = int(this.txt_rewardXP.y + this.txt_rewardXP.height + this._padding);
               break;
            case "morale":
               morale = int(rewardObj.value);
               this.bmp_rewardMorale = new Bitmap(new BmpIconMorale5());
               this.bmp_rewardMorale.x = tx + 2;
               this.bmp_rewardMorale.y = int(this.txt_rewardTitle.y + this.txt_rewardTitle.height + this._padding * 0.5 + 4);
               this.bmp_rewardMorale.filters = [Effects.ICON_SHADOW];
               addChild(this.bmp_rewardMorale);
               this.txt_rewardMorale = new BodyTextField({
                  "text":Language.getInstance().getString("quests_morale_reward",NumberFormatter.format(morale,0)),
                  "color":Effects.COLOR_GOOD,
                  "size":18,
                  "bold":true,
                  "antiAliasType":AntiAliasType.ADVANCED
               });
               this.txt_rewardMorale.x = int(this.bmp_rewardMorale.x + this.bmp_rewardMorale.width + 2);
               this.txt_rewardMorale.y = int(this.txt_rewardTitle.y + this.txt_rewardTitle.height + this._padding * 0.5);
               this.txt_rewardMorale.filters = [new GlowFilter(new Color(Effects.COLOR_GOOD).tint(0,0.75).RGB,1,4,4,10,1)];
               addChild(this.txt_rewardMorale);
               tx = int(this.txt_rewardMorale.x + this.txt_rewardMorale.width + 10);
               this._height = int(this.txt_rewardMorale.y + this.txt_rewardMorale.height + this._padding);
         }
      }
      penalties = quest.getFailurePenalties();
      if(penalties.length > 0)
      {
         tx += 30;
         this.txt_penaltyTitle = new BodyTextField({
            "text":Language.getInstance().getString("quests_failurePenalties"),
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_penaltyTitle.x = tx;
         this.txt_penaltyTitle.y = int(this.txt_rewardTitle.y);
         addChild(this.txt_penaltyTitle);
         for each(penalty in penalties)
         {
            if(penalty.type == "morale")
            {
               this.bmp_penaltyMorale = new Bitmap(new BmpIconMorale1());
               this.bmp_penaltyMorale.x = tx + 2;
               this.bmp_penaltyMorale.y = int(this.txt_penaltyTitle.y + this.txt_penaltyTitle.height + this._padding * 0.5 + 4);
               this.bmp_penaltyMorale.filters = [Effects.ICON_SHADOW];
               addChild(this.bmp_penaltyMorale);
               this.txt_penaltyMorale = new BodyTextField({
                  "text":Language.getInstance().getString("quests_morale_penalty",NumberFormatter.format(penalty.value,0)),
                  "color":Effects.COLOR_WARNING,
                  "size":18,
                  "bold":true,
                  "antiAliasType":AntiAliasType.ADVANCED
               });
               this.txt_penaltyMorale.x = int(this.bmp_penaltyMorale.x + this.bmp_penaltyMorale.width + 2);
               this.txt_penaltyMorale.y = int(this.txt_penaltyTitle.y + this.txt_penaltyTitle.height + this._padding * 0.5);
               this.txt_penaltyMorale.filters = [new GlowFilter(new Color(Effects.COLOR_WARNING).tint(0,0.75).RGB,1,4,4,10,1)];
               addChild(this.txt_penaltyMorale);
               tx = int(this.txt_penaltyMorale.x + this.txt_penaltyMorale.width + 10);
               this._height = int(this.txt_penaltyMorale.y + this.txt_penaltyMorale.height + this._padding);
            }
         }
      }
      GraphicUtils.drawUIBlock(graphics,this._width,this._height);
      this._refreshTimer.start();
      this.onRefreshTimer(null);
   }
   
   public function dispose() : void
   {
      var _loc1_:UIInventoryListItem = null;
      this._quest = null;
      this._refreshTimer.stop();
      this._refreshTimer.removeEventListener(TimerEvent.TIMER,this.onRefreshTimer);
      this.txt_reqTitle.dispose();
      this.txt_rewardTitle.dispose();
      this.ui_itemInfo.dispose();
      if(this.txt_rewardXP != null)
      {
         this.txt_rewardXP.dispose();
      }
      if(this.txt_rewardMorale != null)
      {
         this.txt_rewardMorale.dispose();
      }
      if(this.bmp_rewardMorale != null)
      {
         this.bmp_rewardMorale.bitmapData.dispose();
         this.bmp_rewardMorale.filters = [];
      }
      if(this.txt_penaltyTitle != null)
      {
         this.txt_penaltyTitle.dispose();
      }
      if(this.bmp_penaltyMorale != null)
      {
         this.bmp_penaltyMorale.bitmapData.dispose();
         this.bmp_penaltyMorale.filters = [];
      }
      for each(_loc1_ in this._itemRewards)
      {
         _loc1_.dispose();
      }
   }
   
   private function onRefreshTimer(param1:TimerEvent) : void
   {
      var _loc2_:String = "";
      this.mc_iconTime.visible = true;
      this.txt_time.textColor = 16777215;
      var _loc3_:Number = this._quest.endTime.time - Network.getInstance().serverTime;
      _loc2_ = DateTimeUtils.secondsToString(_loc3_ / 1000,false,true);
      this.txt_time.text = _loc2_;
      var _loc4_:int = this.mc_iconTime.width + this.txt_time.width + 4;
      this.mc_iconTime.x = int((this._width - _loc4_) * 0.5);
      this.txt_time.x = int((this._width - _loc4_) * 0.5 + this.mc_iconTime.width + 4);
   }
   
   private function onRewardItemMouseOver(param1:MouseEvent) : void
   {
      var _loc2_:UIInventoryListItem = param1.currentTarget as UIInventoryListItem;
      this.ui_itemInfo.setItem(_loc2_.itemData);
   }
}
