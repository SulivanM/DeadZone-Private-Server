package thelaststand.app.game.gui.chat.components
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.chat.events.ChatOptionsMenuEvent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatSystem;
   import thelaststand.common.lang.Language;
   
   public class UIChatOptionsPopupMenu extends Sprite
   {
      
      private var mc_background:Shape;
      
      private var btn_contacts:UIChatPopupMenuButton;
      
      private var btn_blocked:UIChatPopupMenuButton;
      
      private var btn_help:UIChatPopupMenuButton;
      
      private var btn_listrooms:UIChatPopupMenuButton;
      
      private var btn_insertStats:UIChatPopupMenuButton;
      
      private var _channel:String;
      
      private var btns:Array;
      
      private var _lang:Language;
      
      private var _textInput:UIChatTextEntry;
      
      private var _chatSystem:ChatSystem;
      
      private var _stage:Stage;
      
      public function UIChatOptionsPopupMenu(param1:UIChatTextEntry)
      {
         super();
         this._textInput = param1;
         this._chatSystem = Network.getInstance().chatSystem;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(0,1);
         this.mc_background.graphics.drawRect(0,0,UIChatPopupMenuButton.WIDTH,100);
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,5,5,0.3,1,true),new GlowFilter(6905685,1,1.75,1.75,10,1),new DropShadowFilter(1,45,0,1,8,8,0.6,2)];
         addChild(this.mc_background);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this._lang = Language.getInstance();
         this.btns = [];
         this.btn_contacts = this.generateButton(this._lang.getString("chat.options_contacts"));
         this.btn_blocked = this.generateButton(this._lang.getString("chat.options_blocked"));
         this.btn_listrooms = this.generateButton(this._lang.getString("chat.options_listrooms"));
         this.btn_insertStats = this.generateButton(this._lang.getString("chat.options_insertstats"));
         this.btn_help = this.generateButton(this._lang.getString("chat.options_help"));
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
         for each(_loc1_ in this.btns)
         {
            _loc1_.dispose();
         }
         this._lang = null;
         this._chatSystem = null;
      }
      
      public function populate(param1:String) : void
      {
         var _loc5_:UIChatPopupMenuButton = null;
         this._channel = param1;
         var _loc2_:PlayerData = Network.getInstance().playerData;
         var _loc3_:AllianceSystem = AllianceSystem.getInstance();
         var _loc4_:int = 2;
         for each(_loc5_ in this.btns)
         {
            if(_loc5_.visible != false)
            {
               addChild(_loc5_);
               _loc5_.y = _loc4_;
               _loc4_ = _loc5_.y + _loc5_.height;
            }
         }
         this.mc_background.height = _loc4_ + 2;
      }
      
      private function generateButton(param1:String, param2:Boolean = false, param3:uint = 13421772) : UIChatPopupMenuButton
      {
         var _loc4_:UIChatPopupMenuButton = new UIChatPopupMenuButton(param3);
         _loc4_.label = param1;
         _loc4_.onClick.add(this.onButtonClick);
         addChild(_loc4_);
         this.btns.push(_loc4_);
         return _loc4_;
      }
      
      private function onButtonClick(param1:UIChatPopupMenuButton) : void
      {
         switch(param1)
         {
            case this.btn_help:
               dispatchEvent(new ChatOptionsMenuEvent(ChatOptionsMenuEvent.MENU_ITEM_CLICK,ChatOptionsMenuEvent.CMD_HELP,[this._channel]));
               break;
            case this.btn_contacts:
               dispatchEvent(new ChatOptionsMenuEvent(ChatOptionsMenuEvent.MENU_ITEM_CLICK,ChatOptionsMenuEvent.CMD_CONTACTS,[this._channel]));
               break;
            case this.btn_blocked:
               dispatchEvent(new ChatOptionsMenuEvent(ChatOptionsMenuEvent.MENU_ITEM_CLICK,ChatOptionsMenuEvent.CMD_BLOCKED,[this._channel]));
               break;
            case this.btn_listrooms:
               dispatchEvent(new ChatOptionsMenuEvent(ChatOptionsMenuEvent.MENU_ITEM_CLICK,ChatOptionsMenuEvent.CMD_LISTROOMS,[this._channel]));
               break;
            case this.btn_insertStats:
               dispatchEvent(new ChatOptionsMenuEvent(ChatOptionsMenuEvent.MENU_ITEM_CLICK,ChatOptionsMenuEvent.CMD_INSERT_WAR_STATS,[this._channel]));
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

