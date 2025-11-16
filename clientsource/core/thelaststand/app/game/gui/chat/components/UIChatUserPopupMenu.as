package thelaststand.app.game.gui.chat.components
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.system.System;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.chat.events.ChatUserMenuEvent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.app.network.chat.ChatUserData;
   import thelaststand.common.lang.Language;
   
   public class UIChatUserPopupMenu extends Sprite
   {
      
      private var mc_background:Shape;
      
      private var btn_level:UIChatPopupMenuButton;
      
      private var btn_paste:UIChatPopupMenuButton;
      
      private var btn_privateMsg:UIChatPopupMenuButton;
      
      private var btn_trade:UIChatPopupMenuButton;
      
      private var btn_contact:UIChatPopupMenuButton;
      
      private var btn_mute:UIChatPopupMenuButton;
      
      private var btn_block:UIChatPopupMenuButton;
      
      private var btn_invite:UIChatPopupMenuButton;
      
      private var btn_report:UIChatPopupMenuButton;
      
      private var btn_history:UIChatPopupMenuButton;
      
      private var btn_silence:UIChatPopupMenuButton;
      
      private var btn_kick:UIChatPopupMenuButton;
      
      private var btn_kicksilent:UIChatPopupMenuButton;
      
      private var btn_tradeBan:UIChatPopupMenuButton;
      
      private var btn_payvault:UIChatPopupMenuButton;
      
      private var btn_recap:UIChatPopupMenuButton;
      
      private var btn_userid:UIChatPopupMenuButton;
      
      private var btn_pullPush:UIChatPopupMenuButton;
      
      private var btn_strike:UIChatPopupMenuButton;
      
      private var btns_normal:Array = [];
      
      private var btns_admin:Array = [];
      
      private var _nickName:String;
      
      private var _uniqueMsgId:String;
      
      private var _muted:Boolean;
      
      private var _blocked:Boolean;
      
      private var _contact:Boolean;
      
      private var _channel:String;
      
      private var _lang:Language;
      
      private var offline_btn:UIChatPopupMenuButton;
      
      private var _chatSystem:ChatSystem;
      
      private var _stage:Stage;
      
      private var _userData:ChatUserData;
      
      private var _source:Object;
      
      public function UIChatUserPopupMenu()
      {
         super();
         this._chatSystem = Network.getInstance().chatSystem;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(0,1);
         this.mc_background.graphics.drawRect(0,0,UIChatPopupMenuButton.WIDTH,100);
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,5,5,0.3,1,true),new GlowFilter(6905685,1,1.75,1.75,10,1),new DropShadowFilter(1,45,0,1,8,8,0.6,2)];
         addChild(this.mc_background);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this._lang = Language.getInstance();
         this.btn_level = this.generateButton("userlevel",false,16754688);
         this.btn_level.enabled = false;
         this.btn_level.alpha = 1;
         this.btn_paste = this.generateButton(this._lang.getString("chat.popup_insert"));
         this.btn_privateMsg = this.generateButton(this._lang.getString("chat.popup_message"));
         this.btn_contact = this.generateButton(this._lang.getString("chat.popup_add"));
         this.btn_mute = this.generateButton(this._lang.getString("chat.popup_mute"));
         this.btn_block = this.generateButton(this._lang.getString("chat.popup_block"));
         this.btn_trade = this.generateButton(this._lang.getString("chat.popup_trade"));
         this.btn_invite = this.generateButton(this._lang.getString("chat.popup_invite"));
         this.btn_report = this.generateButton(this._lang.getString("chat.popup_report"));
         this.offline_btn = new UIChatPopupMenuButton();
         this.offline_btn.enabled = false;
         this.offline_btn.label = this._lang.getString("chat.popup_offline");
         if(Network.getInstance().playerData.isAdmin)
         {
            this.btn_history = this.generateButton("HISTORY",true);
            this.btn_silence = this.generateButton("SILENCE",true);
            this.btn_kick = this.generateButton("KICK",true);
            this.btn_kicksilent = this.generateButton("NINJA KICK",true);
            this.btn_strike = this.generateButton("STRIKE",true);
            this.btn_tradeBan = this.generateButton("TRADE BAN",true);
            this.btn_payvault = this.generateButton("PAYVAULT",true);
            this.btn_recap = this.generateButton("RECAP",true);
            this.btn_userid = this.generateButton("UserID:",true);
            this.btn_pullPush = this.generateButton("PULL IN",true);
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:UIChatPopupMenuButton = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this._stage)
         {
            this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
         }
         if(parent)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this.btns_normal)
         {
            _loc1_.dispose();
         }
         for each(_loc1_ in this.btns_admin)
         {
            _loc1_.dispose();
         }
         this._lang = null;
         this._chatSystem = null;
      }
      
      public function populate(param1:String, param2:String, param3:String, param4:Object = null) : void
      {
         var _loc8_:UIChatPopupMenuButton = null;
         this._nickName = param1;
         this._uniqueMsgId = param2;
         this._channel = param3;
         this._source = param4;
         var _loc5_:PlayerData = Network.getInstance().playerData;
         var _loc6_:AllianceSystem = AllianceSystem.getInstance();
         this._userData = this._chatSystem.extractUserData(param1);
         this._muted = this._chatSystem.checkMuted(this._nickName);
         this._blocked = this._chatSystem.checkBlocked(this._nickName);
         this._contact = this._chatSystem.checkContact(this._nickName);
         this.btn_invite.visible = false;
         if(_loc6_.alliancesEnabled && _loc6_.inAlliance && _loc6_.clientMember != null && _loc6_.clientMember.hasPrivilege(AllianceRankPrivilege.InviteMembers) && this._userData && this._userData.allianceId == "")
         {
            this.btn_invite.visible = true;
            if(this._userData.level < int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL))
            {
               this.btn_invite.visible = false;
            }
         }
         var _loc7_:Array = this.btns_normal.concat(this.btns_admin);
         if(this.offline_btn.parent)
         {
            this.offline_btn.parent.removeChild(this.offline_btn);
         }
         this.btn_privateMsg.visible = !(this._muted || this._blocked) || _loc5_.isAdmin;
         this.btn_mute.visible = !this._blocked;
         this.btn_report.visible = this._userData != null && (!this._userData.isAdmin && this._uniqueMsgId != "");
         var _loc9_:Boolean = this._userData == null || this._userData.online == false;
         if(_loc5_.isAdmin == false && this._userData != null)
         {
            if(this._userData.isAdmin)
            {
               _loc9_ = true;
            }
         }
         if(_loc9_)
         {
            for each(_loc8_ in _loc7_)
            {
               if(_loc8_.parent)
               {
                  _loc8_.parent.removeChild(_loc8_);
               }
            }
            _loc7_.length = 0;
            _loc7_.push(this.offline_btn);
            if(this._userData != null && !this._userData.isAdmin)
            {
               _loc7_.push(this.btn_level);
            }
            _loc7_.push(this.btn_contact);
            _loc7_.push(this.btn_mute);
            _loc7_.push(this.btn_block);
            _loc7_.push(this.btn_report);
            if(this._userData != null && this._chatSystem.userData.isAdmin)
            {
               _loc7_.push(this.btn_payvault);
               _loc7_.push(this.btn_recap);
               _loc7_.push(this.btn_userid);
            }
         }
         if(this._userData != null)
         {
            this.btn_level.label = this._lang.getString("chat.popup_level",String(this._userData.level));
            if(this.btn_userid != null)
            {
               this.btn_userid.label = "UID: " + (this._userData.userId.length > 7 ? this._userData.userId.substr(0,7) + "..." : this._userData.userId);
            }
         }
         this.btn_mute.label = this._lang.getString(this._muted ? "chat.popup_unmute" : "chat.popup_mute");
         this.btn_block.label = this._lang.getString(this._blocked ? "chat.popup_unblock" : "chat.popup_block");
         this.btn_contact.label = this._lang.getString(this._contact ? "chat.popup_remove" : "chat.popup_add");
         this.btn_trade.enabled = this._chatSystem.isTradeAllowed;
         if(this.btn_pullPush)
         {
            this.btn_pullPush.data = this._chatSystem.adminCheckIfInAdminRoom(param1);
            this.btn_pullPush.label = this.btn_pullPush.data ? "PUSH OUT" : "PULL IN";
         }
         var _loc10_:int = 2;
         for each(_loc8_ in _loc7_)
         {
            if(_loc8_.visible != false)
            {
               addChild(_loc8_);
               _loc8_.y = _loc10_;
               _loc10_ = _loc8_.y + _loc8_.height;
            }
         }
         this.mc_background.height = _loc10_ + 2;
      }
      
      private function generateButton(param1:String, param2:Boolean = false, param3:uint = 13421772) : UIChatPopupMenuButton
      {
         var _loc4_:UIChatPopupMenuButton = new UIChatPopupMenuButton(param3);
         _loc4_.label = param1;
         _loc4_.onClick.add(this.onButtonClick);
         addChild(_loc4_);
         if(param2)
         {
            this.btns_admin.push(_loc4_);
         }
         else
         {
            this.btns_normal.push(_loc4_);
         }
         return _loc4_;
      }
      
      private function onButtonClick(param1:UIChatPopupMenuButton) : void
      {
         switch(param1)
         {
            case this.btn_paste:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_PASTE,[this._nickName]));
               break;
            case this.btn_privateMsg:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_MESSAGE,[this._nickName]));
               break;
            case this.btn_mute:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,this._muted ? ChatUserMenuEvent.CMD_UNMUTE : ChatUserMenuEvent.CMD_MUTE,[this._nickName,this._channel]));
               break;
            case this.btn_block:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,this._blocked ? ChatUserMenuEvent.CMD_UNBLOCK : ChatUserMenuEvent.CMD_BLOCK,[this._nickName,this._channel]));
               break;
            case this.btn_contact:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,this._contact ? ChatUserMenuEvent.CMD_REMOVE_CONTACT : ChatUserMenuEvent.CMD_ADD_CONTACT,[this._nickName,this._channel]));
               break;
            case this.btn_trade:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_TRADE,[this._nickName,this._channel]));
               break;
            case this.btn_invite:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_INVITE,[this._nickName,this._channel]));
               break;
            case this.btn_report:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_REPORT,[this._nickName,this._channel,this._uniqueMsgId,this._source]));
               break;
            case this.btn_history:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_HISTORY,[this._nickName,this._channel]));
               break;
            case this.btn_silence:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_SILENCE,[this._nickName]));
               break;
            case this.btn_kick:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_KICK,[this._nickName]));
               break;
            case this.btn_kicksilent:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_KICKSILENT,[this._nickName]));
               break;
            case this.btn_tradeBan:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_TRADEBAN,[this._nickName]));
               break;
            case this.btn_strike:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_STRIKE,[this._nickName]));
               break;
            case this.btn_payvault:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_PAYVAULT,[this._nickName,this._channel]));
               break;
            case this.btn_recap:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_RECAP,[this._nickName,this._channel]));
               break;
            case this.btn_pullPush:
               dispatchEvent(new ChatUserMenuEvent(ChatUserMenuEvent.MENU_ITEM_CLICK,ChatUserMenuEvent.CMD_PUSHPULL,[this._channel,this._nickName,!this.btn_pullPush.data]));
               break;
            case this.btn_userid:
               System.setClipboard(this._userData.userId);
         }
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      private function onStageMouseDown(param1:MouseEvent) : void
      {
         if(mouseX < 0 || mouseX > this.mc_background.width || mouseY < 0 || mouseY > this.mc_background.height)
         {
            if(parent)
            {
               parent.removeChild(this);
            }
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._stage = stage;
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,true,int.MAX_VALUE,true);
      }
   }
}

