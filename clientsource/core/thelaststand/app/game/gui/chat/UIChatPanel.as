package thelaststand.app.game.gui.chat
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.alliance.AllianceLifetimeStats;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.alliance.UIAllianceSummary;
   import thelaststand.app.game.gui.alliance.UIAllianceWarStatsSummary;
   import thelaststand.app.game.gui.chat.components.UIChatMessageList;
   import thelaststand.app.game.gui.chat.components.UIChatTextEntry;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.gui.chat.events.ChatOptionsMenuEvent;
   import thelaststand.app.game.gui.chat.events.ChatUserMenuEvent;
   import thelaststand.app.network.Network;
   
   public class UIChatPanel extends Sprite
   {
      
      private var _width:uint = 300;
      
      private var _height:uint = 250;
      
      private var messageList:UIChatMessageList;
      
      private var input:UIChatTextEntry;
      
      private var _itemInfo:UIItemInfo = new UIItemInfo();
      
      private var _item:Item;
      
      private var _allianceSummary:UIAllianceSummary = new UIAllianceSummary();
      
      private var _warStatsSummary:UIAllianceWarStatsSummary = new UIAllianceWarStatsSummary();
      
      private var _stage:Stage;
      
      public function UIChatPanel(param1:String, param2:Array = null)
      {
         super();
         this.messageList = new UIChatMessageList(param1,param2);
         addChild(this.messageList);
         this.input = new UIChatTextEntry(Network.getInstance().chatSystem);
         this.input.x = 25;
         addChild(this.input);
         this.input.changeCurrentChannel(param1);
         this._itemInfo.displayClothingPreview = true;
         this.setSize(this._width,this._height);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         addEventListener(ChatLinkEvent.LINK_CLICK,this.onChatLinkClick,false,0,true);
         addEventListener(ChatUserMenuEvent.MENU_ITEM_CLICK,this.onUserMenuClick,false,0,true);
         addEventListener(ChatOptionsMenuEvent.MENU_ITEM_CLICK,this.onOptionsMenuClick,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         this.messageList.dispose();
         this.input.dispose();
         this._allianceSummary.dispose();
         this._itemInfo.dispose();
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         removeEventListener(ChatLinkEvent.LINK_CLICK,this.onChatLinkClick);
         removeEventListener(ChatUserMenuEvent.MENU_ITEM_CLICK,this.onUserMenuClick);
         removeEventListener(ChatOptionsMenuEvent.MENU_ITEM_CLICK,this.onOptionsMenuClick);
      }
      
      public function addItemFromEvent(param1:ChatLinkEvent) : void
      {
         this.input.addItemFromEvent(param1);
      }
      
      public function clearMessages() : void
      {
         if(!this.messageList)
         {
            return;
         }
         this.messageList.clear();
      }
      
      private function setSize(param1:uint, param2:uint) : void
      {
         this._width = param1;
         this._height = param2;
         this.input.y = this._height - this.input.height - 2;
         this.input.width = this._width - this.input.x - 2;
         this.messageList.width = this._width;
         this.messageList.height = this._height;
         graphics.clear();
         graphics.beginFill(0,0);
         graphics.drawRect(0,0,this._width,this._height);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._stage = stage;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         if(this.input.visible)
         {
            if(param1.target is TextField)
            {
               if(TextField(param1.target).selectedText == "" || this.input.contains(DisplayObject(param1.target)))
               {
                  stage.focus = this.input;
               }
            }
            else
            {
               stage.focus = this.input;
            }
         }
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
               break;
            default:
               this.input.parseChatLinkEvent(param1);
         }
      }
      
      private function onUserMenuClick(param1:ChatUserMenuEvent) : void
      {
         this.input.parseUserMenuClickEvent(param1);
      }
      
      private function onOptionsMenuClick(param1:ChatOptionsMenuEvent) : void
      {
         this.input.parseOptionsMenuClickEvent(param1);
      }
      
      private function displayAllianceSummary(param1:String) : void
      {
         this._allianceSummary.setAlliance(param1);
         var _loc2_:Point = localToGlobal(new Point(0,0));
         this._allianceSummary.x = _loc2_.x;
         this._allianceSummary.y = _loc2_.y - this._itemInfo.height;
         if(this._allianceSummary.y < 0)
         {
            this._allianceSummary.y = 0;
         }
         this._stage.addChild(this._allianceSummary);
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
         this._itemInfo.setItem(this._item,null,{"showAction":false});
         var _loc3_:Point = localToGlobal(new Point(0,0));
         this._itemInfo.x = _loc3_.x;
         this._itemInfo.y = _loc3_.y - this._itemInfo.height;
         if(this._itemInfo.y < 0)
         {
            this._itemInfo.y = 0;
         }
         this._stage.addChild(this._itemInfo);
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.removeDisplayItem,true,int.MAX_VALUE,true);
      }
      
      private function displayWarStatsPopup(param1:String) : void
      {
         var _loc2_:Object = JSON.parse(param1);
         var _loc3_:AllianceLifetimeStats = new AllianceLifetimeStats();
         _loc3_.deserialize(_loc2_);
         this._warStatsSummary.setData(_loc3_);
         var _loc4_:Point = localToGlobal(new Point(0,0));
         this._itemInfo.x = _loc4_.x;
         this._itemInfo.y = _loc4_.y - this._warStatsSummary.height;
         if(this._warStatsSummary.y < 0)
         {
            this._warStatsSummary.y = 0;
         }
         this._stage.addChild(this._warStatsSummary);
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
      
      public function get allowInput() : Boolean
      {
         return this.input.enabled;
      }
      
      public function set allowInput(param1:Boolean) : void
      {
         this.input.enabled = param1;
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
      
      public function get messageConnecting() : String
      {
         return this.messageList.messageConnecting;
      }
      
      public function set messageConnecting(param1:String) : void
      {
         this.messageList.messageConnecting = param1;
      }
      
      public function get messageConnected() : String
      {
         return this.messageList.messageConnected;
      }
      
      public function set messageConnected(param1:String) : void
      {
         this.messageList.messageConnected = param1;
      }
      
      public function get messageDisconnected() : String
      {
         return this.messageList.messageDisconnected;
      }
      
      public function set messageDisconnected(param1:String) : void
      {
         this.messageList.messageDisconnected = param1;
      }
   }
}

