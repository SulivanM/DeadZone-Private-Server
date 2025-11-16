package thelaststand.app.game.gui.bounty
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.system.LoaderContext;
   import flash.text.AntiAliasType;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.lists.UIListSeparator;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class BountyListItem extends Sprite
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private static const COLOR_GREY:int = 13882323;
      
      private var _width:Number = 766;
      
      private var _height:Number = 56;
      
      private var _remotePlayerData:RemotePlayerData;
      
      private var _alternating:Boolean;
      
      private var _lang:Language;
      
      private var _separators:Vector.<UIListSeparator>;
      
      private var _tooltip:TooltipManager;
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var txt_expire:BodyTextField;
      
      private var txt_bounty:BodyTextField;
      
      private var txt_collected:BodyTextField;
      
      private var bmp_fuel:Bitmap;
      
      private var _selected:Boolean;
      
      private var btn_attack:PushButton;
      
      private var _layout:String = "";
      
      private var _layoutInfo:Array;
      
      private var bountiesDividers:Array = [74,220,150,166];
      
      private var huntersDividers:Array = [74,220,316];
      
      private var alltimeDividers:Array = [74,220,316];
      
      private var _timer:Timer;
      
      private var _bountyLifespan:Number = Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000);
      
      private var iconContainer:Sprite;
      
      private var _network:Network;
      
      public var actioned:Signal;
      
      public function BountyListItem()
      {
         super();
         this.actioned = new Signal();
         this._lang = Language.getInstance();
         this._network = Network.getInstance();
         this._network.onShutdownMissionsLockChange.add(this.onShutdownMissionLockChange);
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.ui_portrait = new UIImage(50,50,0,1,true);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,52,52);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = 10;
         this.ui_portrait.y = Math.round((this._height - this.ui_portrait.height) * 0.5 + 1);
         addChild(this.ui_portrait);
         this.txt_name = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_name.y = 10;
         addChild(this.txt_name);
         this.txt_level = new BodyTextField({
            "text":" ",
            "color":15640320,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
         addChild(this.txt_level);
         this.iconContainer = new Sprite();
         this.iconContainer.y = int(this._height * 0.5);
         addChild(this.iconContainer);
         this.txt_expire = new BodyTextField({
            "text":"EXPIRE?",
            "color":16777215,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED,
            "align":TextFormatAlign.CENTER,
            "autoSize":"none"
         });
         this.txt_expire.y = int((this._height - this.txt_expire.height) * 0.5) - 2;
         addChild(this.txt_expire);
         this.txt_bounty = new BodyTextField({
            "text":"1500",
            "color":COLOR_GREY,
            "size":24,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED,
            "align":TextFormatAlign.RIGHT,
            "autoSize":"none"
         });
         this.txt_bounty.y = int((this._height - this.txt_bounty.height) * 0.5) - 4;
         addChild(this.txt_bounty);
         this.txt_collected = new BodyTextField({
            "text":"10",
            "color":COLOR_GREY,
            "size":24,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED,
            "align":TextFormatAlign.RIGHT,
            "autoSize":"none"
         });
         this.txt_collected.y = int((this._height - this.txt_collected.height) * 0.5) - 4;
         addChild(this.txt_collected);
         this.btn_attack = new PushButton(this._lang.getString("bounty.list_btn_attack"),null,-1,{"bold":true});
         this.btn_attack.clicked.add(this.onClickButton);
         this.btn_attack.backgroundColor = 7545099;
         this.btn_attack.width = 90;
         this.btn_attack.y = int((this._height - this.btn_attack.height) * 0.5);
         addChild(this.btn_attack);
         this.bmp_fuel = new Bitmap(new BmpIconFuel());
         this.bmp_fuel.width = 16;
         this.bmp_fuel.scaleY = this.bmp_fuel.scaleX;
         this.bmp_fuel.y = int((this._height - this.bmp_fuel.height) * 0.5);
         addChild(this.bmp_fuel);
         this._separators = new Vector.<UIListSeparator>();
         this._timer = new Timer(30000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
         this.setLayout(thelaststand.app.game.gui.bounty.BountyList.LAYOUT_BOUNTIES);
         this._tooltip = TooltipManager.getInstance();
      }
      
      public function dispose() : void
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
         this._tooltip.removeAllFromParent(this);
         this.clearIcons();
         this._lang = null;
         this._tooltip = null;
         this._network.onShutdownMissionsLockChange.remove(this.onShutdownMissionLockChange);
         this._network = null;
         for each(_loc1_ in this._separators)
         {
            _loc1_.dispose();
         }
         this._separators = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_expire.dispose();
         this.txt_expire = null;
         this.txt_bounty.dispose();
         this.txt_bounty = null;
         this.txt_collected.dispose();
         this.txt_collected = null;
         this.ui_portrait.dispose();
         this.ui_portrait = null;
         this.btn_attack.dispose();
         this.btn_attack = null;
         this.bmp_fuel.bitmapData.dispose();
         this.bmp_fuel = null;
         this.actioned.removeAll();
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this._timer = null;
      }
      
      public function setLayout(param1:String) : void
      {
         var _loc2_:UIListSeparator = null;
         if(this._layout == param1)
         {
            return;
         }
         this._layout = param1;
         this.iconContainer.visible = false;
         switch(param1)
         {
            case thelaststand.app.game.gui.bounty.BountyList.LAYOUT_HUNTERS:
               this._layoutInfo = this.huntersDividers;
               break;
            case thelaststand.app.game.gui.bounty.BountyList.LAYOUT_ALLTIME:
               this._layoutInfo = this.alltimeDividers;
               break;
            default:
               this._layoutInfo = this.bountiesDividers;
         }
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < this._layoutInfo.length)
         {
            _loc3_ += this._layoutInfo[_loc4_];
            if(_loc4_ < this._separators.length)
            {
               _loc2_ = this._separators[_loc4_];
            }
            else
            {
               _loc2_ = new UIListSeparator(this._height + 1);
               this._separators.push(_loc2_);
            }
            addChild(_loc2_);
            _loc2_.x = _loc3_;
            _loc4_++;
         }
         while(_loc4_ < this._separators.length)
         {
            if(this._separators[_loc4_].parent)
            {
               this._separators[_loc4_].parent.removeChild(this._separators[_loc4_]);
            }
            _loc4_++;
         }
      }
      
      private function update() : void
      {
         if(this._remotePlayerData == null)
         {
            this.ui_portrait.visible = false;
            this.txt_name.visible = false;
            this.txt_level.visible = false;
            this.txt_expire.visible = false;
            this.txt_bounty.visible = false;
            this.txt_collected.visible = false;
            this.btn_attack.visible = false;
            this.bmp_fuel.visible = false;
            this.iconContainer.visible = false;
            this._timer.stop();
            return;
         }
         var _loc1_:UIListSeparator = this._separators[0];
         this.ui_portrait.uri = this._remotePlayerData.getPortraitURI();
         this.ui_portrait.visible = true;
         this.txt_name.text = this._remotePlayerData.nickname + (this._remotePlayerData.allianceTag ? " [" + this._remotePlayerData.allianceTag + "]" : "");
         this.txt_level.text = this._lang.getString("level",this._remotePlayerData.level + 1).toUpperCase();
         this.txt_name.x = this.txt_level.x = int(_loc1_.x + 8);
         this.txt_name.visible = true;
         this.txt_level.visible = true;
         this.clearIcons();
         if(AllianceSystem.getInstance().hasBannerProtection(this._remotePlayerData.id))
         {
            this.createIcon(new BmpIconBannerProtection(),this._lang.getString("alliance.tooltip_bannerProtection",this._remotePlayerData.nickname,AllianceSystem.getInstance().getAttackedTargetData(this._remotePlayerData.id).user),1);
         }
         else if(AllianceSystem.getInstance().hasScoutingProtection(this._remotePlayerData.id))
         {
            this.createIcon(new BmpIconBannerProtection(),this._lang.getString("alliance.tooltip_scoutingProtection",this._remotePlayerData.nickname,AllianceSystem.getInstance().getScoutingData(this._remotePlayerData.id).user),1);
         }
         if(this._remotePlayerData.isProtected)
         {
            this.createIcon(new BmpIconDamageProtection(),this._lang.getString("attack_protected_title",this._remotePlayerData.nickname),0.8);
         }
         _loc1_ = this._separators[this._layoutInfo.length - 1];
         this.bmp_fuel.x = _loc1_.x - 38 - this.bmp_fuel.width;
         this.bmp_fuel.visible = true;
         this.txt_bounty.x = this._separators[this._layoutInfo.length - 2].x + 10;
         this.txt_bounty.width = this.bmp_fuel.x - 6 - this.txt_bounty.x;
         this.txt_bounty.visible = true;
         _loc1_ = this._separators[this._layoutInfo.length - 1];
         switch(this._layout)
         {
            case thelaststand.app.game.gui.bounty.BountyList.LAYOUT_HUNTERS:
               this.btn_attack.visible = false;
               this.txt_expire.visible = false;
               this.txt_collected.width = this._width - _loc1_.x - 68;
               this.txt_collected.x = _loc1_.x + 34;
               this.txt_collected.visible = true;
               this.txt_collected.text = NumberFormatter.format(this._remotePlayerData.bountyCollectCount,0);
               this.txt_bounty.text = NumberFormatter.format(this._remotePlayerData.bountyEarnings,0);
               this.txt_bounty.textColor = this.txt_expire.textColor = COLOR_GREY;
               break;
            case thelaststand.app.game.gui.bounty.BountyList.LAYOUT_ALLTIME:
               this.btn_attack.visible = false;
               this.txt_expire.visible = false;
               this.txt_collected.width = this._width - _loc1_.x - 68;
               this.txt_collected.x = _loc1_.x + 34;
               this.txt_collected.visible = true;
               this.txt_collected.text = NumberFormatter.format(this._remotePlayerData.bountyAllTimeCount,0);
               this.txt_bounty.text = NumberFormatter.format(this._remotePlayerData.bountyAllTime,0);
               this.txt_bounty.textColor = this.txt_expire.textColor = COLOR_GREY;
               break;
            default:
               this.txt_collected.visible = false;
               this.btn_attack.x = _loc1_.x + int((this._width - _loc1_.x - this.btn_attack.width) * 0.5);
               this.btn_attack.visible = true;
               this.txt_expire.x = this._separators[1].x;
               this.txt_expire.width = this._separators[2].x - this._separators[1].x;
               this.txt_expire.visible = true;
               this.txt_bounty.text = NumberFormatter.format(this._remotePlayerData.bounty,0);
               this.iconContainer.x = this._separators[1].x - 5 - this.iconContainer.width;
               this.iconContainer.visible = true;
               this._timer.start();
               this.onTimer(null);
         }
         this.setAttackButtonEnabledState();
         if(this._remotePlayerData.bountyDate + this._bountyLifespan < Network.getInstance().serverTime)
         {
            this.btn_attack.enabled = false;
         }
         if(this._remotePlayerData.isSameAlliance)
         {
            this.btn_attack.enabled = false;
         }
         this._tooltip.add(this.btn_attack,this.getAttackTooltip,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
      }
      
      private function getAttackTooltip() : String
      {
         return RemotePlayerData.getAttackToolTip(this._remotePlayerData,true);
      }
      
      private function setAttackButtonEnabledState() : void
      {
         this.btn_attack.enabled = this._network.playerData.bountyCap > 0 && this._remotePlayerData.canAttack();
      }
      
      private function onShutdownMissionLockChange(param1:Boolean) : void
      {
         this.setAttackButtonEnabledState();
      }
      
      private function createIcon(param1:BitmapData, param2:String, param3:Number = 1) : void
      {
         var _loc4_:Sprite = new Sprite();
         var _loc5_:Bitmap = new Bitmap(param1,"auto",true);
         _loc5_.scaleX = _loc5_.scaleY = param3;
         _loc4_.addChild(_loc5_);
         this._tooltip.add(_loc4_,param2,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         _loc4_.x = this.iconContainer.width > 0 ? this.iconContainer.width + 5 : 0;
         _loc4_.y = -int(_loc4_.height * 0.5);
         this.iconContainer.addChild(_loc4_);
      }
      
      private function clearIcons() : void
      {
         var _loc1_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         var _loc3_:Bitmap = null;
         this._tooltip.removeAllFromParent(this.iconContainer);
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
         if(this.selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":(this._alternating ? COLOR_ALT : COLOR_NORMAL)});
      }
      
      private function onClickButton(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_attack:
               this.actioned.dispatch(this._remotePlayerData,"attack");
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:Number = this._remotePlayerData.bountyDate + this._bountyLifespan - Network.getInstance().serverTime;
         if(_loc2_ <= 0)
         {
            _loc3_ = this._lang.getString("bounty.list_expired");
            this.txt_expire.textColor = this.txt_bounty.textColor = 12910592;
         }
         else
         {
            if(_loc2_ < 3600000)
            {
               _loc3_ = this._lang.getString("bounty.list_1hour");
            }
            else
            {
               _loc3_ = DateTimeUtils.secondsToString(_loc2_ / 1000,true,false,true);
            }
            this.txt_bounty.textColor = this.txt_expire.textColor = COLOR_GREY;
         }
         this.txt_expire.text = _loc3_;
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!this.selected)
         {
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL);
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      public function get remotePlayerData() : RemotePlayerData
      {
         return this._remotePlayerData;
      }
      
      public function set remotePlayerData(param1:RemotePlayerData) : void
      {
         if(this._remotePlayerData != null)
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this._remotePlayerData.onUpdate.remove(this.update);
         }
         this._remotePlayerData = param1;
         this.update();
         if(this._remotePlayerData != null)
         {
            this._remotePlayerData.onUpdate.add(this.update);
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
      }
   }
}

