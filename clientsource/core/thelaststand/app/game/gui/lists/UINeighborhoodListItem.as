package thelaststand.app.game.gui.lists
{
   import com.exileetiquette.utils.NumberFormatter;
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
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.UIOnlineStatus;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UINeighborhoodListItem extends UIPagedListItem
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private const COL_WIDTHS:Vector.<int>;
      
      private var _neighbor:RemotePlayerData;
      
      private var _alternating:Boolean;
      
      private var _lang:Language;
      
      private var _separators:Vector.<UIListSeparator>;
      
      private var _tooltip:TooltipManager;
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var ui_online:UIOnlineStatus;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var txt_relationship:BodyTextField;
      
      private var txt_battles:BodyTextField;
      
      private var btn_help:PushButton;
      
      private var btn_attack:PushButton;
      
      private var btn_view:PushButton;
      
      private var iconContainer:Sprite;
      
      public var actioned:Signal;
      
      public function UINeighborhoodListItem()
      {
         var _loc2_:int = 0;
         var _loc3_:UIListSeparator = null;
         this.COL_WIDTHS = Vector.<int>([102,220,90,88]);
         super();
         this._lang = Language.getInstance();
         _width = 766;
         _height = 56;
         this.actioned = new Signal();
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.ui_portrait = new UIImage(50,50,0,1,true);
         this.ui_portrait.context = new LoaderContext(true,ApplicationDomain.currentDomain.parentDomain,Security.sandboxType == Security.REMOTE ? SecurityDomain.currentDomain : null);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,52,52);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = 10;
         this.ui_portrait.y = Math.round((_height - this.ui_portrait.height) * 0.5 + 1);
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
         this.txt_name.y = 10;
         this.txt_level = new BodyTextField({
            "text":" ",
            "color":15640320,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
         this.iconContainer = new Sprite();
         this.iconContainer.y = int(_height * 0.5);
         this.txt_relationship = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_relationship.y = int((_height - this.txt_relationship.height) * 0.5);
         this.txt_battles = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_battles.y = int((_height - this.txt_battles.height) * 0.5);
         this.btn_help = new PushButton(this._lang.getString("map_list_btn_help"),null,-1,{"bold":true});
         this.btn_help.clicked.add(this.onClickButton);
         this.btn_help.backgroundColor = 4226049;
         this.btn_help.width = 90;
         this.btn_help.y = int((_height - this.btn_help.height) * 0.5);
         this.btn_attack = new PushButton(this._lang.getString("map_list_btn_attack"),null,-1,{"bold":true});
         this.btn_attack.clicked.add(this.onClickButton);
         this.btn_attack.backgroundColor = 7545099;
         this.btn_attack.width = this.btn_help.width;
         this.btn_attack.y = this.btn_help.y;
         this.btn_view = new PushButton(this._lang.getString("map_list_btn_view"),null,-1,{"bold":true});
         this.btn_view.clicked.add(this.onClickButton);
         this.btn_view.width = this.btn_help.width;
         this.btn_view.y = this.btn_help.y;
         this._separators = new Vector.<UIListSeparator>();
         var _loc1_:int = 0;
         while(_loc1_ < 4)
         {
            _loc3_ = new UIListSeparator(_height + 1);
            addChild(_loc3_);
            this._separators.push(_loc3_);
            _loc1_++;
         }
         _loc2_ = this.COL_WIDTHS[0];
         this._separators[0].x = _loc2_;
         this._separators[3].x = _loc2_ = (this._separators[2].x = (this._separators[1].x = _loc2_ + this.COL_WIDTHS[1]) + this.COL_WIDTHS[2]) + this.COL_WIDTHS[3];
         this._tooltip = TooltipManager.getInstance();
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
         this.clearIcons();
         TweenMax.killChildTweensOf(this);
         this._tooltip.removeAllFromParent(this);
         super.dispose();
         this._lang = null;
         this._tooltip = null;
         this.neighbor = null;
         this.actioned.removeAll();
         for each(_loc1_ in this._separators)
         {
            _loc1_.dispose();
         }
         this._separators = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_battles.dispose();
         this.txt_battles = null;
         this.txt_relationship.dispose();
         this.txt_relationship = null;
         this.btn_attack.dispose();
         this.btn_attack = null;
         this.btn_help.dispose();
         this.btn_help = null;
         this.btn_view.dispose();
         this.btn_view = null;
         this.ui_online.dispose();
         this.ui_online = null;
         this.ui_portrait.dispose();
         this.ui_portrait = null;
      }
      
      private function update() : void
      {
         var _loc6_:String = null;
         if(this._neighbor == null)
         {
            return;
         }
         var _loc1_:int = this.COL_WIDTHS[0];
         this.ui_portrait.uri = this._neighbor.getPortraitURI();
         this.ui_online.status = this._neighbor.online ? UIOnlineStatus.STATUS_ONLINE : UIOnlineStatus.STATUS_OFFLINE;
         this.txt_name.text = (this._neighbor.isBanned ? "[BANNED] " : "") + this._neighbor.nickname + (this._neighbor.allianceTag ? " [" + this._neighbor.allianceTag + "]" : "");
         this.txt_level.text = this._lang.getString("level",this._neighbor.level + 1).toUpperCase();
         this.txt_name.x = this.txt_level.x = int(_loc1_ + 8);
         this.clearIcons();
         if(AllianceSystem.getInstance().hasBannerProtection(this.neighbor.id))
         {
            this.createIcon(new BmpIconBannerProtection(),this._lang.getString("alliance.tooltip_bannerProtection",this.neighbor.nickname,AllianceSystem.getInstance().getAttackedTargetData(this.neighbor.id).user),1);
         }
         else if(AllianceSystem.getInstance().hasScoutingProtection(this.neighbor.id))
         {
            this.createIcon(new BmpIconBannerProtection(),this._lang.getString("alliance.tooltip_scoutingProtection",this.neighbor.nickname,AllianceSystem.getInstance().getScoutingData(this.neighbor.id).user),1);
         }
         if(this.neighbor.bounty > 0 && this.neighbor.bountyDate + Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000) > Network.getInstance().serverTime)
         {
            _loc6_ = this._lang.getString("bounty.list_tip_bountyIcon");
            _loc6_ = _loc6_.replace("%user",this.neighbor.nickname);
            _loc6_ = _loc6_.replace("%bounty",NumberFormatter.format(this.neighbor.bounty,0));
            this.createIcon(new BmpIconDangerHigh(),_loc6_);
         }
         if(this.neighbor.isProtected)
         {
            this.createIcon(new BmpIconDamageProtection(),this._lang.getString("attack_protected_title",this.neighbor.nickname),0.8);
         }
         addChild(this.iconContainer);
         this.iconContainer.x = int(317 - this.iconContainer.width);
         this.txt_name.maxWidth = int(this.iconContainer.x - this.txt_name.x - 6);
         this.txt_name.y = int(this.txt_level.y - this.txt_name.height + 4);
         _loc1_ += this.COL_WIDTHS[1];
         switch(this._neighbor.relationship)
         {
            case RemotePlayerData.RELATIONSHIP_FRIEND:
               this.txt_relationship.text = this._lang.getString("map_list_friend").toUpperCase();
               this.txt_relationship.textColor = Effects.COLOR_GOOD;
               break;
            case RemotePlayerData.RELATIONSHIP_ENEMY:
               this.txt_relationship.text = this._lang.getString("map_list_enemy").toUpperCase();
               this.txt_relationship.textColor = 12928548;
               break;
            case RemotePlayerData.RELATIONSHIP_NEUTRAL:
            default:
               this.txt_relationship.text = this._lang.getString("map_list_neutral").toUpperCase();
               this.txt_relationship.textColor = 9276813;
         }
         this.txt_relationship.x = int(_loc1_ + (this.COL_WIDTHS[2] - this.txt_relationship.width) * 0.5);
         _loc1_ += this.COL_WIDTHS[2];
         this.txt_battles.text = this._lang.getString(this._neighbor.battles == 1 ? "map_list_battle" : "map_list_battles",this._neighbor.battles).toUpperCase();
         this.txt_battles.textColor = this._neighbor.battles > 0 ? 12928548 : 9276813;
         this.txt_battles.x = int(_loc1_ + (this.COL_WIDTHS[3] - this.txt_battles.width) * 0.5);
         _loc1_ += this.COL_WIDTHS[3];
         var _loc2_:int = _width - _loc1_;
         var _loc3_:int = 22;
         var _loc4_:int = this.btn_help.width + _loc3_ + this.btn_attack.width;
         var _loc5_:int = int(_loc1_ + (_loc2_ - _loc4_) * 0.5);
         if(this._neighbor.isFriend)
         {
            this.btn_help.x = _loc5_;
            addChild(this.btn_help);
            if(this.btn_view.parent != null)
            {
               this.btn_view.parent.removeChild(this.btn_view);
            }
         }
         else
         {
            this.btn_view.x = _loc5_;
            addChild(this.btn_view);
            if(this.btn_help.parent != null)
            {
               this.btn_help.parent.removeChild(this.btn_help);
            }
         }
         this.btn_help.enabled = this.btn_view.enabled = !this._neighbor.isBanned;
         this.btn_attack.x = int(_loc5_ + this.btn_attack.width + _loc3_);
         this.btn_attack.enabled = this._neighbor.canAttack();
         this._tooltip.add(this.ui_online,this._lang.getString(this._neighbor.online ? "online" : "offline"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_help,this._lang.getString("map_list_btn_help_desc",this._neighbor.nickname),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_attack,RemotePlayerData.getAttackToolTip(this._neighbor),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._tooltip.add(this.btn_view,this._lang.getString("map_list_btn_view_desc",this._neighbor.nickname),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         addChild(this.ui_portrait);
         addChild(this.ui_online);
         addChild(this.txt_name);
         addChild(this.txt_level);
         addChild(this.txt_relationship);
         addChild(this.txt_battles);
         addChild(this.btn_attack);
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
            case this.btn_attack:
               this.actioned.dispatch(this._neighbor,"attack");
               break;
            case this.btn_help:
            case this.btn_view:
               this.actioned.dispatch(this._neighbor,"help");
         }
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
      
      public function get neighbor() : RemotePlayerData
      {
         return this._neighbor;
      }
      
      public function set neighbor(param1:RemotePlayerData) : void
      {
         if(this._neighbor != null)
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            this._neighbor = null;
         }
         this._neighbor = param1;
         this.update();
         if(this._neighbor != null)
         {
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
   }
}

