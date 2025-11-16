package thelaststand.app.game.gui.chat.commspanel
{
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.alliance.AllianceLifetimeStats;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.alliance.UIAllianceSummary;
   import thelaststand.app.game.gui.alliance.UIAllianceWarStatsSummary;
   import thelaststand.app.game.gui.chat.events.ChatGUIEvent;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.gui.iteminfo.UIClothingPreviewLocation;
   import thelaststand.app.network.Network;
   
   public class UICommsPanel extends Sprite
   {
      
      private var _padding:int = 10;
      
      private var _width:int = 502;
      
      private var _height:int = 200;
      
      private var offlineScreen:UICommsOfflineScreen;
      
      private var chatTabBox:UICommsPanelTabBox;
      
      private var _stage:Stage;
      
      private var _itemInfo:UIItemInfo = new UIItemInfo();
      
      private var _item:Item;
      
      private var _allianceSummary:UIAllianceSummary = new UIAllianceSummary();
      
      private var _warStatsSummary:UIAllianceWarStatsSummary = new UIAllianceWarStatsSummary();
      
      private var _chatEnabled:Boolean;
      
      private var _settings:Settings = Settings.getInstance();
      
      private var _network:Network = Network.getInstance();
      
      public function UICommsPanel()
      {
         super();
         this.offlineScreen = new UICommsOfflineScreen();
         this.offlineScreen.onConnect.add(this.onOfflineScreenConnect);
         this.offlineScreen.onDisconnect.add(this.onOfflineScreenDisconnect);
         addChild(this.offlineScreen);
         this.chatTabBox = new UICommsPanelTabBox();
         this.chatTabBox.onDockedChange.add(this.onTabBoxDockedChange);
         this.chatTabBox.onClosed.add(this.onTabBoxClosed);
         this.chatTabBox.addEventListener(ChatLinkEvent.LINK_CLICK,this.onChatLinkClick,false,0,true);
         this.setSize(this._width,this._height);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      private function setChatEnabled(param1:Boolean) : void
      {
         this._chatEnabled = param1;
         this.offlineScreen.enabled = param1;
         if(!param1)
         {
            this.chatTabBox.disconnectAllTabs();
            this.onTabBoxClosed();
         }
      }
      
      private function onSettingsChanged() : void
      {
         if(this._chatEnabled != this._settings.chatEnabled)
         {
            this.setChatEnabled(this._settings.chatEnabled);
         }
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         scaleX = scaleY = 1;
         this._width = param1;
         this._height = param2;
         graphics.clear();
         graphics.beginFill(4934475);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(2960685);
         graphics.drawRect(1,1,this._width - 2,this._height - 2);
         graphics.endFill();
         graphics.beginFill(0);
         graphics.drawRect(this._padding,this._padding,this._width - this._padding * 2,this._height - this._padding * 2);
         graphics.endFill();
         this.offlineScreen.compactMode = this._width < 500;
         if(this.chatTabBox.docked)
         {
            this.chatTabBox.x = this.chatTabBox.y = this._padding + 5;
            this.chatTabBox.width = this._width - this.chatTabBox.x * 2;
            this.chatTabBox.height = this._height - this.chatTabBox.y * 2;
         }
      }
      
      private function onTabBoxDockedChange(param1:Boolean) : void
      {
         if(this.chatTabBox.parent)
         {
            this.chatTabBox.parent.removeChild(this.chatTabBox);
         }
         if(param1)
         {
            addChild(this.chatTabBox);
            this.setSize(this._width,this._height);
            if(this.offlineScreen.parent)
            {
               this.offlineScreen.parent.removeChild(this.offlineScreen);
            }
         }
         else
         {
            this.offlineScreen.showDisconnect = true;
            addChild(this.offlineScreen);
            dispatchEvent(new ChatGUIEvent(ChatGUIEvent.UNDOCKED,this.chatTabBox));
         }
      }
      
      private function onOfflineScreenConnect() : void
      {
         if(this.offlineScreen.parent)
         {
            this.offlineScreen.parent.removeChild(this.offlineScreen);
         }
         addChild(this.chatTabBox);
         this.chatTabBox.connectInititalTabs();
      }
      
      private function onOfflineScreenDisconnect() : void
      {
         this.chatTabBox.disconnectAllTabs();
         this.chatTabBox.docked = true;
         this.offlineScreen.showDisconnect = false;
         if(this.chatTabBox.parent)
         {
            this.chatTabBox.parent.removeChild(this.chatTabBox);
         }
         addChild(this.offlineScreen);
      }
      
      private function onTabBoxClosed() : void
      {
         if(this.chatTabBox.parent)
         {
            this.chatTabBox.parent.removeChild(this.chatTabBox);
         }
         this.offlineScreen.showDisconnect = false;
         addChild(this.offlineScreen);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._stage = stage;
         this._network.settingsChanged.add(this.onSettingsChanged);
         this.setChatEnabled(this._settings.chatEnabled);
      }
      
      private function onChatLinkClick(param1:ChatLinkEvent) : void
      {
         switch(param1.linkType)
         {
            case ChatLinkEvent.LT_ITEM:
               this.displayItemDataPopup(param1.data);
               break;
            case ChatLinkEvent.LT_ALLIANCE_SHOW:
               this.displayAllianceSummary(param1.data);
               break;
            case ChatLinkEvent.LT_WARSTATS:
               this.displayWarStatsPopup(param1.data);
         }
      }
      
      private function displayAllianceSummary(param1:String) : void
      {
         this._allianceSummary.setAlliance(param1);
         this.positionDisplayItem(this._allianceSummary);
         this._stage.addChild(this._allianceSummary);
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.removeDisplayItem,true,int.MAX_VALUE,true);
      }
      
      private function displayWarStatsPopup(param1:String) : void
      {
         var _loc2_:Object = JSON.parse(param1);
         var _loc3_:AllianceLifetimeStats = new AllianceLifetimeStats();
         _loc3_.deserialize(_loc2_);
         this._warStatsSummary.setData(_loc3_);
         this.positionDisplayItem(this._warStatsSummary);
         this._stage.addChild(this._warStatsSummary);
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.removeDisplayItem,true,int.MAX_VALUE,true);
      }
      
      private function displayItemDataPopup(param1:*) : void
      {
         if(this._item)
         {
            this._item.dispose();
            this._item = null;
         }
         var _loc2_:Object = JSON.parse(param1);
         this._item = ItemFactory.createItemFromObject(_loc2_.data);
         if(this._item == null)
         {
            return;
         }
         this._itemInfo.clothingPreviewLocation = UIClothingPreviewLocation.RIGHT_BOTTOM;
         this._itemInfo.setItem(this._item,null,{"showAction":false});
         this.positionDisplayItem(this._itemInfo);
         this._stage.addChild(this._itemInfo);
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.removeDisplayItem,true,int.MAX_VALUE,true);
      }
      
      private function removeDisplayItem(param1:MouseEvent) : void
      {
         if(this._itemInfo.parent)
         {
            this._itemInfo.parent.removeChild(this._itemInfo);
         }
         if(this._allianceSummary.parent)
         {
            this._allianceSummary.parent.removeChild(this._allianceSummary);
         }
         if(this._warStatsSummary.parent)
         {
            this._warStatsSummary.parent.removeChild(this._warStatsSummary);
         }
         this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.removeDisplayItem);
      }
      
      private function positionDisplayItem(param1:Sprite) : void
      {
         var _loc2_:Point = this.chatTabBox.parent.localToGlobal(new Point(this.chatTabBox.x,this.chatTabBox.y));
         if(this.chatTabBox.docked)
         {
            param1.x = _loc2_.x;
            param1.y = _loc2_.y - 30 - param1.height;
            if(param1.y < 10)
            {
               param1.y = 10;
            }
         }
         else
         {
            param1.y = _loc2_.y;
            param1.x = _loc2_.x;
            param1.y = _loc2_.y - 5 - param1.height;
            if(param1.y < 0)
            {
               param1.y = _loc2_.y;
               param1.x = _loc2_.x + 405;
            }
            if(param1.y + param1.height > this._stage.stageHeight)
            {
               param1.y = this._stage.stageHeight - param1.height;
            }
            if(param1.x + param1.width > this._stage.stageWidth)
            {
               param1.x = _loc2_.x - (param1.width + 5);
            }
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this._height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this._width,param1);
      }
   }
}

