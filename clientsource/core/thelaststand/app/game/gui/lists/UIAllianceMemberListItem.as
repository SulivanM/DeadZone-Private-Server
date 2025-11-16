package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
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
   import thelaststand.app.game.data.alliance.AllianceData;
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceRank;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.UIOnlineStatus;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIAllianceMemberListItem extends UIPagedListItem
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private const COL_WIDTHS:Vector.<int>;
      
      private var _lang:Language;
      
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
      
      private var txt_rank:BodyTextField;
      
      private var txt_lastLogin:BodyTextField;
      
      private var btn_edit:EditMemberButton;
      
      private var ui_busy:UIBusySpinner;
      
      public var onEditMember:Signal;
      
      public function UIAllianceMemberListItem()
      {
         var _loc3_:UIListSeparator = null;
         this.COL_WIDTHS = new <int>[80,365,124,134];
         this.onEditMember = new Signal(UIAllianceMemberListItem);
         super();
         this._lang = Language.getInstance();
         this._tooltips = TooltipManager.getInstance();
         _width = 722;
         _height = 42;
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
         this.ui_online.x = int(this.ui_portrait.x + this.ui_portrait.width + 14);
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
         this.txt_rank = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_rank.y = int((_height - this.txt_rank.height) * 0.5);
         this.txt_lastLogin = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_lastLogin.y = int((_height - this.txt_lastLogin.height) * 0.5);
         this.btn_edit = new EditMemberButton();
         this.btn_edit.onClick.add(this.onEditMemberClicked);
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
         AllianceSystem.getInstance().roundStarted.remove(this.onRoundStarted);
         if(this._member != null)
         {
            this._member.rankChanged.remove(this.onRankChanged);
            this._member.onlineStatusChanged.remove(this.onOnlineStatusChanged);
            this._member = null;
         }
         this._lang = null;
         this._tooltips = null;
         this._remotePlayerData = null;
         for each(_loc1_ in this._separators)
         {
            _loc1_.dispose();
         }
         this._separators = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_lastLogin.dispose();
         this.txt_lastLogin = null;
         this.ui_online.dispose();
         this.ui_online = null;
         this.ui_portrait.dispose();
         this.ui_portrait = null;
         this.txt_rank.dispose();
         this.txt_rank = null;
         this.btn_edit.dispose();
         this.onEditMember.removeAll();
      }
      
      public function refreshRank() : void
      {
         if(this._member == null)
         {
            if(this.txt_rank.parent != null)
            {
               this.txt_rank.parent.removeChild(this.txt_rank);
            }
            return;
         }
         var _loc1_:int = this.COL_WIDTHS[0] + this.COL_WIDTHS[1];
         this.txt_rank.text = AllianceSystem.getInstance().alliance.getRankName(this._member.rank);
         this.txt_rank.x = int(_loc1_ + (this.COL_WIDTHS[2] - this.txt_rank.width) * 0.5);
         if(this._remotePlayerData != null)
         {
            addChild(this.btn_edit);
         }
         else if(this.btn_edit.parent)
         {
            this.btn_edit.parent.removeChild(this.btn_edit);
         }
      }
      
      private function update() : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:String = null;
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
            if(this.txt_lastLogin.parent != null)
            {
               this.txt_lastLogin.parent.removeChild(this.txt_lastLogin);
            }
            if(this.txt_rank.parent != null)
            {
               this.txt_rank.parent.removeChild(this.txt_rank);
            }
            if(this.btn_edit.parent != null)
            {
               this.btn_edit.parent.removeChild(this.btn_edit);
            }
            if(this.ui_busy.parent != null)
            {
               this.ui_busy.parent.removeChild(this.ui_busy);
            }
            return;
         }
         this.ui_portrait.uri = this._remotePlayerData != null ? this._remotePlayerData.getPortraitURI() : null;
         this.onOnlineStatusChanged(this._member);
         var _loc1_:int = 0;
         var _loc2_:int = this.COL_WIDTHS[_loc1_++];
         this.txt_name.htmlText = (this._remotePlayerData != null && this._remotePlayerData.isBanned ? "[BANNED] " : "") + this._member.nickname + (this._member.joinDate.time > AllianceSystem.getInstance().round.activeTime.time ? " <font color=\'#A2A2A2\'>[" + this._lang.getString("alliance.enlisting").toUpperCase() + "]</font>" : "");
         this.txt_level.text = this._lang.getString("level",this._member.level + 1).toUpperCase();
         this.txt_name.x = this.txt_level.x = int(_loc2_ + 8);
         _loc2_ += this.COL_WIDTHS[_loc1_++];
         this.btn_edit.x = _loc2_ - this.btn_edit.width;
         this.btn_edit.y = int(_height * 0.5);
         this.txt_rank.text = AllianceSystem.getInstance().alliance.getRankName(this._member.rank);
         this.txt_rank.x = int(_loc2_ + (this.COL_WIDTHS[2] - this.txt_rank.width) * 0.5);
         _loc2_ += this.COL_WIDTHS[_loc1_++];
         if(this._remotePlayerData != null)
         {
            _loc3_ = (Network.getInstance().serverTime - this._remotePlayerData.lastLogin.time) / 1000;
            _loc4_ = this._remotePlayerData.lastLogin ? DateTimeUtils.secondsToString(_loc3_,true,false,true) : "N/A";
            this.txt_lastLogin.text = _loc4_;
         }
         else
         {
            this.txt_lastLogin.text = "";
         }
         this.txt_lastLogin.x = int(_loc2_ + (this.COL_WIDTHS[_loc1_] - this.txt_lastLogin.width) * 0.5);
         addChild(this.ui_portrait);
         addChild(this.ui_online);
         addChild(this.txt_name);
         addChild(this.txt_level);
         addChild(this.txt_lastLogin);
         addChild(this.txt_rank);
         if(this._remotePlayerData == null)
         {
            addChild(this.ui_busy);
            this.ui_portrait.visible = false;
            if(this.btn_edit.parent != null)
            {
               this.btn_edit.parent.removeChild(this.btn_edit);
            }
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         else
         {
            if(this.ui_busy.parent)
            {
               this.ui_busy.parent.removeChild(this.ui_busy);
            }
            this.ui_portrait.visible = true;
            addChild(this.btn_edit);
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function getSortValue(param1:String) : *
      {
         switch(param1)
         {
            case "online":
               return this._member.isOnline ? 1 : 0;
            case "rank":
               return this._member.rank;
            case "tokens":
               return this._member.tokens;
            case "level":
               return this._member.level;
            case "lastLogin":
               return this._remotePlayerData != null ? this._remotePlayerData.lastLogin.time : 0;
            default:
               return 0;
         }
      }
      
      private function canEditMember() : Boolean
      {
         var _loc1_:AllianceData = AllianceSystem.getInstance().alliance;
         if(_loc1_ == null || AllianceSystem.getInstance().clientMember == null)
         {
            return false;
         }
         var _loc2_:uint = AllianceSystem.getInstance().clientMember.rank;
         return _loc2_ >= AllianceRank.RANK_9 && this._member.rank < _loc2_ || this._member.rank < AllianceRank.RANK_10 && this._member.id == Network.getInstance().playerData.id;
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
      
      private function onEditMemberClicked() : void
      {
         this.onEditMember.dispatch(this);
      }
      
      private function onRankChanged(param1:AllianceMember) : void
      {
         if(param1 != this._member)
         {
            return;
         }
         this.refreshRank();
      }
      
      private function onOnlineStatusChanged(param1:AllianceMember) : void
      {
         this.ui_online.status = this._member.isOnline ? UIOnlineStatus.STATUS_ONLINE : UIOnlineStatus.STATUS_OFFLINE;
         this._tooltips.add(this.ui_online,this._lang.getString(this._member.isOnline ? "online" : "offline"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
      }
      
      private function onRoundStarted() : void
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
         if(this._member != null)
         {
            this._member.rankChanged.remove(this.onRankChanged);
            this._member.onlineStatusChanged.remove(this.onOnlineStatusChanged);
            AllianceSystem.getInstance().roundStarted.remove(this.onRoundStarted);
         }
         this._member = param1;
         if(this._member != null)
         {
            this._member.rankChanged.add(this.onRankChanged);
            this._member.onlineStatusChanged.add(this.onOnlineStatusChanged);
            if(this._member.joinDate.time > AllianceSystem.getInstance().round.activeTime.time)
            {
               AllianceSystem.getInstance().roundStarted.addOnce(this.onRoundStarted);
            }
         }
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

import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;
import thelaststand.app.audio.Audio;

class EditMemberButton extends Sprite
{
   
   private var bmp:Bitmap;
   
   public var onClick:Signal = new Signal();
   
   public function EditMemberButton()
   {
      super();
      mouseChildren = false;
      buttonMode = true;
      this.bmp = new Bitmap(new BmpIconSettings(),"auto",true);
      this.bmp.x = -int(this.bmp.width * 0.5);
      this.bmp.y = -int(this.bmp.height * 0.5);
      addChild(this.bmp);
      this.bmp.alpha = 0.5;
      addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
      addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      addEventListener(MouseEvent.CLICK,this.onMouseClick,false,0,true);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.onClick.removeAll();
      this.bmp.bitmapData.dispose();
      TweenMax.killChildTweensOf(this);
      removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      removeEventListener(MouseEvent.CLICK,this.onMouseClick);
   }
   
   private function onRollOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp,0.15,{
         "alpha":0.75,
         "glowFilter":{
            "color":16777215,
            "alpha":0.75,
            "blurX":10,
            "blurY":10,
            "strength":1,
            "quality":2
         }
      });
   }
   
   private function onRollOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp,0.25,{
         "alpha":0.5,
         "glowFilter":{
            "alpha":0,
            "remove":true,
            "overwrite":true
         }
      });
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      Audio.sound.play("sound/interface/int-click.mp3");
   }
   
   private function onMouseClick(param1:MouseEvent) : void
   {
      param1.stopImmediatePropagation();
      this.onClick.dispatch();
   }
}
