package thelaststand.app.game.gui.dialogues
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import playerio.DatabaseObject;
   import playerio.PlayerIOError;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.bounty.BountyCapDisplay;
   import thelaststand.app.game.gui.bounty.BountyList;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.game.logic.bounty.BountyListLogic;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   
   public class BountyListDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _disposed:Boolean;
      
      private var bd_titleIcon:BitmapData;
      
      private var mc_container:Sprite;
      
      private var list:thelaststand.app.game.gui.bounty.BountyList;
      
      private var btn_bounties:PushButton;
      
      private var btn_hunters:PushButton;
      
      private var btn_mostAllTime:PushButton;
      
      private var btn_top:PushButton;
      
      private var btn_help:HelpButton;
      
      private var filterBtns:Vector.<PushButton>;
      
      private var filterContainer:Sprite;
      
      private var lastFilter:String = "BountiesByBounty";
      
      private var earningsCounter:BountyCounter;
      
      private var collectedCounter:BountyCounter;
      
      private var capCounter:BountyCapDisplay;
      
      private var myDBObject:DatabaseObject;
      
      private var _tooltip:TooltipManager;
      
      public function BountyListDialogue()
      {
         var a:Array;
         var obj:Object = null;
         var network:Network = null;
         var btn:PushButton = null;
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this.mc_container = new Sprite();
         super("bountylist",this.mc_container,true);
         _autoSize = false;
         _width = 794;
         _height = 430;
         this.bd_titleIcon = new BmpBountySkull();
         addTitle(this._lang.getString("bounty.list_title"),BaseDialogue.TITLE_COLOR_GREY,-1,this.bd_titleIcon);
         this.btn_bounties = new PushButton(this._lang.getString("bounty.list_btn_bounties"),new BmpIconDangerHigh(),1644825);
         this.btn_bounties.y = int(_padding * 0.5);
         this.btn_bounties.width = 154;
         this.btn_bounties.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_bounties);
         this.btn_mostAllTime = new PushButton(this._lang.getString("bounty.list_btn_allTime"),new BmpIconDangerHigh(),1644825);
         this.btn_mostAllTime.y = this.btn_bounties.y;
         this.btn_mostAllTime.width = 154;
         this.btn_mostAllTime.x = this.btn_bounties.x + this.btn_bounties.width + 13;
         this.btn_mostAllTime.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_mostAllTime);
         this.btn_hunters = new PushButton(this._lang.getString("bounty.list_btn_hunters"),new BmpIconBountyHunter(),7099169);
         this.btn_hunters.y = this.btn_bounties.y;
         this.btn_hunters.width = 154;
         this.btn_hunters.x = this.btn_mostAllTime.x + this.btn_mostAllTime.width + 13;
         this.btn_hunters.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_hunters);
         a = [{
            "data":BountyListLogic.BY_BOUNTY,
            "icon":new BmpIconDangerHigh(),
            "tip":"bounty.list_tip_filter_bounty"
         },{
            "data":BountyListLogic.BY_EXPIRE,
            "icon":new BmpIconSearchTimer(),
            "tip":"bounty.list_tip_filter_time"
         },{
            "data":BountyListLogic.BY_LEVEL,
            "icon":new BmpIconLevel(),
            "tip":"bounty.list_tip_filter_lvl"
         }];
         this.filterBtns = new Vector.<PushButton>();
         this.filterContainer = new Sprite();
         this.filterContainer.y = this.btn_bounties.y;
         for each(obj in a)
         {
            btn = new PushButton("",obj.icon);
            btn.autoSize = false;
            btn.width = 32;
            btn.height = 24;
            btn.data = obj.data;
            if(this.filterBtns.length > 0)
            {
               btn.x = this.filterContainer.width + 9;
            }
            btn.clicked.add(this.onButtonClicked);
            this.filterBtns.push(btn);
            this.filterContainer.addChild(btn);
            this._tooltip.add(btn,this._lang.getString(obj.tip),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         this.mc_container.addChild(this.filterContainer);
         this.list = new thelaststand.app.game.gui.bounty.BountyList();
         this.list.y = this.filterContainer.y + this.filterContainer.height + int(_padding * 0.5);
         this.mc_container.addChild(this.list);
         this.list.actioned.add(this.onPlayerActioned);
         this.filterContainer.x = this.list.x + this.list.width - this.filterContainer.width;
         this.btn_help = new HelpButton("bounty.list_help");
         this.btn_help.x = 8;
         this.btn_help.y = this.list.y + this.list.listHeight + 10;
         this.mc_container.addChild(this.btn_help);
         this.earningsCounter = new BountyCounter(true);
         this.earningsCounter.label = this._lang.getString("bounty.your_bounty");
         this.earningsCounter.x = 452;
         this.earningsCounter.y = this.list.y + this.list.listHeight;
         this.mc_container.addChild(this.earningsCounter);
         this.collectedCounter = new BountyCounter(false);
         this.collectedCounter.label = this._lang.getString("bounty.your_collected");
         this.collectedCounter.x = 614;
         this.collectedCounter.y = this.earningsCounter.y;
         this.mc_container.addChild(this.collectedCounter);
         this.capCounter = new BountyCapDisplay();
         this.capCounter.x = this.btn_help.width + int((360 - this.btn_help.width - this.capCounter.width) * 0.5);
         this.capCounter.y = this.earningsCounter.y;
         this.mc_container.addChild(this.capCounter);
         this.setDisplay(BountyListLogic.BY_BOUNTY);
         network = Network.getInstance();
         network.client.bigDB.load("PlayerSummary",network.playerData.id,function(param1:DatabaseObject):void
         {
            if(_disposed)
            {
               return;
            }
            myDBObject = param1;
            updateCounters();
         },function(param1:PlayerIOError):void
         {
         });
         this._tooltip.add(this.btn_bounties,this._lang.getString("bounty.list_tip_view_bounties"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_hunters,this._lang.getString("bounty.list_tip_view_hunters"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_mostAllTime,this._lang.getString("bounty.list_tip_view_allTime"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
      }
      
      override public function dispose() : void
      {
         var _loc1_:PushButton = null;
         if(this._disposed)
         {
            return;
         }
         super.dispose();
         this._lang = null;
         this._disposed = true;
         this._tooltip.removeAllFromParent(this.mc_container);
         this._tooltip = null;
         this.bd_titleIcon.dispose();
         this.btn_bounties.dispose();
         this.btn_bounties = null;
         this.btn_hunters.dispose();
         this.btn_hunters = null;
         this.btn_mostAllTime.dispose();
         this.btn_mostAllTime = null;
         this.btn_help.dispose();
         this.btn_help = null;
         this.earningsCounter.dispose();
         this.collectedCounter.dispose();
         this.capCounter.dispose();
         for each(_loc1_ in this.filterBtns)
         {
            _loc1_.dispose();
         }
         this.filterBtns = null;
      }
      
      override public function open() : void
      {
         super.open();
         Tracking.trackPageview("bountyList");
      }
      
      private function setDisplay(param1:String) : void
      {
         this.btn_bounties.selected = param1 != BountyListLogic.BEST_BOUNTY_HUNTERS && param1 != BountyListLogic.ALL_TIME_BOUNTIES;
         this.btn_hunters.selected = param1 == BountyListLogic.BEST_BOUNTY_HUNTERS;
         this.btn_mostAllTime.selected = param1 == BountyListLogic.ALL_TIME_BOUNTIES;
         this.changeBountyFilter(param1);
         this.filterContainer.visible = this.btn_bounties.selected;
         this.collectedCounter.visible = true;
         switch(param1)
         {
            case BountyListLogic.BEST_BOUNTY_HUNTERS:
               this.earningsCounter.label = this._lang.getString("bounty.your_earnings");
               this.collectedCounter.label = this._lang.getString("bounty.your_collected");
               break;
            case BountyListLogic.ALL_TIME_BOUNTIES:
               this.earningsCounter.label = this._lang.getString("bounty.your_lifetimeBounties");
               this.collectedCounter.label = this._lang.getString("bounty.your_lifetimeBountiesCount");
               break;
            default:
               this.collectedCounter.visible = false;
               this.earningsCounter.label = this._lang.getString("bounty.your_bounty");
         }
         this.updateCounters();
      }
      
      private function changeBountyFilter(param1:String) : void
      {
         var _loc2_:PushButton = null;
         for each(_loc2_ in this.filterBtns)
         {
            _loc2_.selected = _loc2_.data == param1;
         }
         this.list.changeCategory(param1);
      }
      
      private function updateCounters() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         if(!this.myDBObject)
         {
            return;
         }
         if(this.btn_hunters.selected)
         {
            this.collectedCounter.value = this.myDBObject.bountyCollectCount ? int(this.myDBObject.bountyCollectCount) : 0;
            this.earningsCounter.value = this.myDBObject.bountyEarnings ? int(this.myDBObject.bountyEarnings) : 0;
         }
         else if(this.btn_mostAllTime.selected)
         {
            this.collectedCounter.value = this.myDBObject.bountyAllTimeCount ? int(this.myDBObject.bountyAllTimeCount) : 0;
            this.earningsCounter.value = this.myDBObject.bountyAllTime ? int(this.myDBObject.bountyAllTime) : 0;
         }
         else
         {
            _loc1_ = this.myDBObject.bounty ? int(this.myDBObject.bounty) : 0;
            if(_loc1_ > 0)
            {
               _loc2_ = this.myDBObject.bountyDate ? Math.floor(Number(this.myDBObject.bountyDate)) : 0;
               _loc2_ += Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000);
               if(_loc2_ < Network.getInstance().serverTime)
               {
                  _loc1_ = 0;
               }
            }
            this.earningsCounter.value = _loc1_;
         }
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_bounties:
               this.setDisplay(this.lastFilter);
               break;
            case this.btn_hunters:
               this.setDisplay(BountyListLogic.BEST_BOUNTY_HUNTERS);
               break;
            case this.btn_mostAllTime:
               this.setDisplay(BountyListLogic.ALL_TIME_BOUNTIES);
               break;
            default:
               this.lastFilter = PushButton(param1.target).data;
               this.changeBountyFilter(this.lastFilter);
         }
      }
      
      private function onPlayerActioned(param1:RemotePlayerData, param2:String) : void
      {
         var _loc3_:PlayerData = Network.getInstance().playerData;
         var _loc4_:Number = _loc3_.compound.effects.getValue(EffectType.getTypeValue("DisablePvP"));
         switch(param2)
         {
            case "attack":
               if(_loc4_ > 0)
               {
                  return;
               }
               this.checkForBountyCap(param1);
               return;
               break;
            default:
               close();
               return;
         }
      }
      
      private function checkForBountyCap(param1:RemotePlayerData) : void
      {
         var bountyFriendMsg:BountyFriendAllianceMessageBox = null;
         var bountyCapMsg:BountyCapReachedMessageBox = null;
         var remotePlayer:RemotePlayerData = param1;
         var player:PlayerData = Network.getInstance().playerData;
         if(remotePlayer.bounty > 0 && remotePlayer.bountyDate + Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000) > Network.getInstance().serverTime)
         {
            if(remotePlayer.isFriend || remotePlayer.isSameAlliance)
            {
               bountyFriendMsg = new BountyFriendAllianceMessageBox();
               bountyFriendMsg.onAccept.add(function():void
               {
                  checkForGlobalProtection(remotePlayer);
                  bountyFriendMsg.close();
               });
               bountyFriendMsg.open();
            }
            else if(player.bountyCap == 0)
            {
               bountyCapMsg = new BountyCapReachedMessageBox();
               bountyCapMsg.onAccept.add(function():void
               {
                  checkForGlobalProtection(remotePlayer);
                  bountyCapMsg.close();
               });
               bountyCapMsg.open();
            }
            else
            {
               this.checkForGlobalProtection(remotePlayer);
            }
         }
         else
         {
            this.checkForGlobalProtection(remotePlayer);
         }
      }
      
      private function checkForGlobalProtection(param1:RemotePlayerData) : void
      {
         var remotePlayer:RemotePlayerData = param1;
         var globalProtection:Number = Network.getInstance().playerData.compound.globalEffects.getValue(EffectType.getTypeValue("DisablePvP"));
         if(globalProtection > 0)
         {
            DialogueController.getInstance().openLoseProtectionWarning(function():void
            {
               attackOtherPlayer(remotePlayer);
            });
         }
         else
         {
            this.attackOtherPlayer(remotePlayer);
         }
      }
      
      private function attackOtherPlayer(param1:RemotePlayerData) : void
      {
         Tracking.trackEvent("BountyList","Attack",param1.isFriend ? "friend" : "unknown");
         this.mc_container.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION_PLANNING,param1));
         close();
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextFormatAlign;
import thelaststand.app.display.BodyTextField;

class BountyCounter extends Sprite
{
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   private var bmp_fuel:Bitmap;
   
   private var _value:int;
   
   public function BountyCounter(param1:Boolean = true)
   {
      super();
      var _loc2_:Number = 152;
      var _loc3_:Number = 28;
      var _loc4_:Number = 15;
      this.txt_label = new BodyTextField({
         "text":"",
         "color":7763574,
         "size":11,
         "bold":true,
         "align":TextFormatAlign.CENTER,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_label.autoSize = "none";
      this.txt_label.width = _loc2_;
      addChild(this.txt_label);
      this.txt_value = new BodyTextField({
         "text":"",
         "color":13882323,
         "size":19,
         "bold":true,
         "align":TextFormatAlign.RIGHT,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_value.autoSize = "none";
      this.txt_value.x = 10;
      this.txt_value.y = _loc4_ + int((_loc3_ - this.txt_value.height) * 0.5) - 1;
      this.txt_value.width = _loc2_ - this.txt_value.x * 2;
      addChild(this.txt_value);
      if(param1)
      {
         this.bmp_fuel = new Bitmap(new BmpIconFuel());
         this.bmp_fuel.width = 11;
         this.bmp_fuel.scaleY = this.bmp_fuel.scaleX;
         this.bmp_fuel.x = _loc2_ - this.bmp_fuel.width - 10;
         this.bmp_fuel.y = _loc4_ + int((_loc3_ - this.bmp_fuel.height) * 0.5) + 1;
         this.txt_value.width = this.bmp_fuel.x - 6 - this.txt_value.x;
         addChild(this.bmp_fuel);
      }
      graphics.beginFill(7763574,1);
      graphics.drawRect(0,_loc4_,_loc2_,_loc3_);
      graphics.beginFill(2434341,1);
      graphics.drawRect(1,_loc4_ + 1,_loc2_ - 2,_loc3_ - 2);
   }
   
   public function dispose() : void
   {
      if(this.bmp_fuel)
      {
         this.bmp_fuel.bitmapData.dispose();
      }
      this.txt_label.dispose();
      this.txt_label = null;
      this.txt_value.dispose();
      this.txt_value = null;
   }
   
   public function get label() : String
   {
      return this.txt_label.text;
   }
   
   public function set label(param1:String) : void
   {
      this.txt_label.text = param1;
   }
   
   public function get value() : int
   {
      return this._value;
   }
   
   public function set value(param1:int) : void
   {
      this._value = param1;
      this.txt_value.text = NumberFormatter.format(this._value,0);
   }
}
