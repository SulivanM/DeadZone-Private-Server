package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.alliance.UIAllianceHUDIcon;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.network.Network;
   
   public class UIHUDAllianceButton extends UIHUDButton
   {
      
      private var _ptUncollected:Point;
      
      private var _ptUnRead:Point;
      
      private var ui_uncollected:UINotificationCount;
      
      private var ui_unread:UINotificationCount;
      
      private var allianceIcon:UIAllianceHUDIcon = new UIAllianceHUDIcon();
      
      private var _playerData:PlayerData;
      
      private var _alliancesystem:AllianceSystem;
      
      public function UIHUDAllianceButton(param1:String)
      {
         super(param1,this.allianceIcon);
         this._playerData = Network.getInstance().playerData;
         this._playerData.uncollectedWinningsChanged.add(this.onUncollectedChange);
         this._ptUnRead = new Point(15,5);
         this._ptUncollected = new Point(10,21);
         this.ui_unread = new UINotificationCount();
         this.ui_unread.x = this._ptUnRead.x;
         this.ui_unread.y = this._ptUnRead.y;
         this.ui_unread.label = "0";
         this.ui_unread.visible = false;
         addChild(this.ui_unread);
         this.ui_uncollected = new UINotificationCount(622336);
         this.ui_uncollected.x = this._ptUncollected.x;
         this.ui_uncollected.y = this._ptUncollected.y;
         this.ui_uncollected.label = "1";
         this.ui_uncollected.visible = this._playerData.uncollectedWinnings;
         addChild(this.ui_uncollected);
         this._alliancesystem = AllianceSystem.getInstance();
         this._alliancesystem.connected.add(this.handleConnected);
         this._alliancesystem.disconnected.add(this.handleDisconnected);
         if(this._alliancesystem.isConnected)
         {
            this.handleConnected();
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.allianceIcon.dispose();
         this.ui_uncollected.dispose();
         this.ui_unread.dispose();
         this._playerData.uncollectedWinningsChanged.remove(this.onUncollectedChange);
         this._alliancesystem.connected.remove(this.handleConnected);
         this._alliancesystem.disconnected.remove(this.handleDisconnected);
         if(this._alliancesystem.alliance)
         {
            this._alliancesystem.alliance.messages.unreadMessageCountChange.remove(this.handleUnreadMessageChange);
         }
      }
      
      private function handleConnected() : void
      {
         this._alliancesystem.alliance.messages.unreadMessageCountChange.add(this.handleUnreadMessageChange);
         this.handleUnreadMessageChange(this._alliancesystem.alliance.messages.unreadMessageCount);
      }
      
      private function handleDisconnected() : void
      {
         if(this._alliancesystem.alliance)
         {
            this._alliancesystem.alliance.messages.unreadMessageCountChange.remove(this.handleUnreadMessageChange);
         }
         this.handleUnreadMessageChange(0);
      }
      
      private function handleUnreadMessageChange(param1:int) : void
      {
         this.ui_unread.label = param1.toString();
         this.ui_unread.visible = param1 > 0;
      }
      
      private function onUncollectedChange() : void
      {
         this.ui_uncollected.visible = this._playerData.uncollectedWinnings;
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown || mc_icon == null)
         {
            return;
         }
         super.onMouseOver(param1);
         TweenMax.to(this.ui_unread,0.15,{
            "x":this._ptUnRead.x - 5,
            "y":this._ptUnRead.y - 7
         });
         TweenMax.to(this.ui_uncollected,0.15,{
            "x":this._ptUncollected.x - 5,
            "y":this._ptUncollected.y - 3
         });
      }
      
      override protected function onMouseOut(param1:MouseEvent) : void
      {
         super.onMouseOut(param1);
         TweenMax.to(this.ui_unread,0.15,{
            "x":this._ptUnRead.x,
            "y":this._ptUnRead.y
         });
         TweenMax.to(this.ui_uncollected,0.15,{
            "x":this._ptUncollected.x,
            "y":this._ptUncollected.y
         });
      }
      
      override public function get width() : Number
      {
         return mc_hitArea.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return mc_hitArea.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

