package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.system.LoaderContext;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.UIOnlineStatus;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIAllianceViewMemberListItem extends UIPagedListItem
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private const COL_WIDTHS:Vector.<int>;
      
      private var _lang:Language;
      
      private var _network:Network;
      
      private var _tooltips:TooltipManager;
      
      private var _alternating:Boolean;
      
      private var _member:AllianceMember;
      
      private var _remotePlayerData:RemotePlayerData;
      
      private var _separators:Vector.<UIListSeparator>;
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var ui_online:UIOnlineStatus;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var btn_view:PushButton;
      
      private var ui_busy:UIBusySpinner;
      
      private var iconContainer:Sprite;
      
      public var actioned:Signal;
      
      private var _displayedWarPoints:int = 0;
      
      public function UIAllianceViewMemberListItem()
      {
         var _loc3_:UIListSeparator = null;
         this.COL_WIDTHS = new <int>[68,214,88];
         super();
         this._lang = Language.getInstance();
         this._tooltips = TooltipManager.getInstance();
         this._network = Network.getInstance();
         this._network.onShutdownMissionsLockChange.add(this.onShutdownMissionsLock);
         _width = 385;
         _height = 42;
         this.actioned = new Signal(RemotePlayerData,String);
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.ui_portrait = new UIImage(30,30,0,1,true);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,32,32);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = 5;
         this.ui_portrait.y = Math.round((_height - this.ui_portrait.height) * 0.5 + 1);
         this.ui_busy = new UIBusySpinner();
         this.ui_busy.x = int(this.ui_portrait.x + this.ui_portrait.width * 0.5);
         this.ui_busy.y = int(this.ui_portrait.y + this.ui_portrait.height * 0.5);
         this.ui_online = new UIOnlineStatus();
         this.ui_online.x = int(this.ui_portrait.x + this.ui_portrait.width + 12);
         this.ui_online.y = int((_height - this.ui_online.height) * 0.5);
         this.txt_name = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_name.y = 4;
         this.txt_level = new BodyTextField({
            "text":" ",
            "color":15640320,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
         this.iconContainer = new Sprite();
         this.iconContainer.y = int(_height * 0.5);
         addChild(this.iconContainer);
         this.btn_view = new PushButton(this._lang.getString("alliance.oppenentList_view"),null,-1,{"bold":true});
         this.btn_view.clicked.add(this.onClickButton);
         this.btn_view.enabled = false;
         this.btn_view.width = 64;
         this.btn_view.y = int((_height - this.btn_view.height) * 0.5);
         this._separators = new Vector.<UIListSeparator>();
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.COL_WIDTHS.length - 1)
         {
            _loc1_ += this.COL_WIDTHS[_loc2_];
            _loc3_ = new UIListSeparator(_height + 1);
            _loc3_.x = _loc1_;
            addChild(_loc3_);
            this._separators.push(_loc3_);
            _loc2_++;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIListSeparator = null;
         var _loc2_:Resource = null;
         this.actioned.removeAll();
         if(this.ui_portrait != null && this.ui_portrait.uri != null)
         {
            _loc2_ = ResourceManager.getInstance().getResource(this.ui_portrait.uri);
            if(_loc2_ != null && !_loc2_.loaded)
            {
               ResourceManager.getInstance().purge(this.ui_portrait.uri);
            }
         }
         TweenMax.killChildTweensOf(this);
         this._tooltips.removeAllFromParent(this);
         super.dispose();
         if(this._member != null)
         {
            this._member = null;
         }
         for each(_loc1_ in this._separators)
         {
            _loc1_.dispose();
         }
         this._separators = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.ui_online.dispose();
         this.ui_online = null;
         this.ui_portrait.dispose();
         this.ui_portrait = null;
         this.btn_view.dispose();
         this.btn_view = null;
         this.clearIcons();
         this._lang = null;
         this._tooltips = null;
         this._remotePlayerData = null;
         this._network.onShutdownMissionsLockChange.remove(this.onShutdownMissionsLock);
         this._network = null;
      }
      
      private function update() : void
      {
         if(this._member == null)
         {
            if(this.ui_portrait.parent != null)
            {
               this.ui_portrait.parent.removeChild(this.ui_portrait);
            }
            if(this.ui_online.parent != null)
            {
               this.ui_online.parent.removeChild(this.ui_online);
            }
            if(this.txt_name.parent != null)
            {
               this.txt_name.parent.removeChild(this.txt_name);
            }
            if(this.txt_level.parent != null)
            {
               this.txt_level.parent.removeChild(this.txt_level);
            }
            if(this.ui_busy.parent != null)
            {
               this.ui_busy.parent.removeChild(this.ui_busy);
            }
            if(this.btn_view.parent != null)
            {
               this.btn_view.parent.removeChild(this.btn_view);
            }
            this.iconContainer.visible = false;
            return;
         }
         this.ui_portrait.uri = this._remotePlayerData != null ? this._remotePlayerData.getPortraitURI() : null;
         var _loc1_:Boolean = Boolean(this._remotePlayerData) && this._remotePlayerData.online;
         this.ui_online.status = _loc1_ ? UIOnlineStatus.STATUS_ONLINE : UIOnlineStatus.STATUS_OFFLINE;
         this._tooltips.add(this.ui_online,this._lang.getString(_loc1_ ? "online" : "offline"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         var _loc2_:int = this.COL_WIDTHS[0];
         this.txt_name.htmlText = this._member.nickname;
         var _loc3_:* = (this._remotePlayerData != null && this._remotePlayerData.allianceTag != "" ? "[" + this._remotePlayerData.allianceTag + "] - " : "") + this._lang.getString("level",this._member.level + 1).toUpperCase();
         if(this._remotePlayerData != null && this._remotePlayerData.isBanned)
         {
            _loc3_ = "[BANNED]";
         }
         else if(this._member.joinDate.time > AllianceSystem.getInstance().round.activeTime.time)
         {
            _loc3_ = "<font color=\'#A2A2A2\'>[" + this._lang.getString("alliance.enlisting").toUpperCase() + "]</font>";
         }
         this.txt_level.htmlText = _loc3_;
         this.txt_name.x = this.txt_level.x = int(_loc2_ + 8);
         _loc2_ += this.COL_WIDTHS[1];
         this.clearIcons();
         var _loc4_:* = this.member.joinDate.time < AllianceSystem.getInstance().round.activeTime.time;
         this.btn_view.x = _loc2_ + 20;
         addChild(this.ui_portrait);
         addChild(this.ui_online);
         addChild(this.txt_name);
         addChild(this.txt_level);
         addChild(this.btn_view);
         if(this._remotePlayerData == null)
         {
            addChild(this.ui_busy);
            this.ui_portrait.visible = false;
            this.ui_online.visible = false;
            this.btn_view.label = this._lang.getString("alliance.oppenentList_loading");
            this.btn_view.enabled = false;
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this._tooltips.add(this.btn_view,this._lang.getString("alliance.tooltip_loadingData"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            this._tooltips.add(this.ui_online,this._lang.getString("alliance.tooltip_loadingData"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
         else
         {
            if(this.ui_busy.parent)
            {
               this.ui_busy.parent.removeChild(this.ui_busy);
            }
            this.ui_portrait.visible = true;
            this.ui_online.visible = true;
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            if(AllianceSystem.getInstance().hasBannerProtection(this._member.id))
            {
               this.createIcon(new BmpIconBannerProtection(),this._lang.getString("alliance.tooltip_bannerProtection",this._member.nickname,AllianceSystem.getInstance().getAttackedTargetData(this._member.id).user),1);
            }
            else if(AllianceSystem.getInstance().hasScoutingProtection(this._member.id))
            {
               this.createIcon(new BmpIconBannerProtection(),this._lang.getString("alliance.tooltip_scoutingProtection",this._member.nickname,AllianceSystem.getInstance().getScoutingData(this._member.id).user),1);
            }
            if(this._remotePlayerData.isProtected)
            {
               this.createIcon(new BmpIconDamageProtection(),this._lang.getString("attack_protected_title",this._member.nickname),0.8);
            }
            this.iconContainer.x = this.COL_WIDTHS[0] + this.COL_WIDTHS[1] - 5 - this.iconContainer.width;
            this.iconContainer.visible = true;
            this.btn_view.enabled = true;
            this.btn_view.label = this._lang.getString("alliance.oppenentList_view");
            this._tooltips.add(this.btn_view,this._lang.getString("map_list_btn_view_desc",this._remotePlayerData.nickname),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            this._tooltips.add(this.ui_online,this._lang.getString(Boolean(this._remotePlayerData) && this._remotePlayerData.online ? "online" : "offline"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         }
      }
      
      public function getSortValue(param1:String) : *
      {
         switch(param1)
         {
            case "online":
               return this._remotePlayerData != null ? this._remotePlayerData.online : false;
            case "level":
               return this._member.level;
            default:
               return 0;
         }
      }
      
      private function createIcon(param1:BitmapData, param2:String, param3:Number = 1) : void
      {
         var _loc4_:Sprite = new Sprite();
         var _loc5_:Bitmap = new Bitmap(param1,"auto",true);
         _loc5_.scaleX = _loc5_.scaleY = param3;
         _loc4_.addChild(_loc5_);
         this._tooltips.add(_loc4_,param2,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         _loc4_.x = this.iconContainer.width > 0 ? this.iconContainer.width + 5 : 0;
         _loc4_.y = -int(_loc4_.height * 0.5);
         this.iconContainer.addChild(_loc4_);
      }
      
      private function clearIcons() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         var _loc3_:Bitmap = null;
         this._tooltips.removeAllFromParent(this.iconContainer);
         while(this.iconContainer.numChildren > 0)
         {
            _loc1_ = this.iconContainer.removeChildAt(0);
            if(_loc1_ is DisplayObjectContainer)
            {
               while(DisplayObjectContainer(_loc1_).numChildren > 0)
               {
                  _loc2_ = DisplayObjectContainer(_loc1_).removeChildAt(0);
                  if(_loc2_ is Bitmap)
                  {
                     _loc3_ = Bitmap(_loc2_);
                     if(_loc3_.bitmapData)
                     {
                        _loc3_.bitmapData.dispose();
                     }
                     _loc3_.bitmapData = null;
                  }
               }
            }
         }
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
         TweenMax.to(this.mc_background,0,{"tint":(this._alternating ? COLOR_ALT : COLOR_NORMAL)});
      }
      
      private function onClickButton(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_view:
               this.actioned.dispatch(this._remotePlayerData,"view");
         }
      }
      
      private function onShutdownMissionsLock(param1:Boolean) : void
      {
         this.update();
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
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL);
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      public function get member() : AllianceMember
      {
         return this._member;
      }
      
      public function set member(param1:AllianceMember) : void
      {
         this._member = param1;
         this.update();
      }
      
      public function get remotePlayerData() : RemotePlayerData
      {
         return this._remotePlayerData;
      }
      
      public function set remotePlayerData(param1:RemotePlayerData) : void
      {
         this._remotePlayerData = param1;
         if(this._member != null)
         {
            this.update();
         }
      }
   }
}

