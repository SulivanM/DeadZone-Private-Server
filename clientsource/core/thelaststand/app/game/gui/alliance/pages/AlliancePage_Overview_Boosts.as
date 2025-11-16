package thelaststand.app.game.gui.alliance.pages
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.Currency;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceRankPrivilege;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.alliance.UIAllianceBoostItem;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AlliancePage_Overview_Boosts extends UIComponent
   {
      
      private const TITLE_COLOR:uint = 7022104;
      
      private const BOOST_COLOR:uint = 15686202;
      
      private var _width:int = 477;
      
      private var _height:int = 132;
      
      private var _displayArea:Rectangle;
      
      private var _allianceSystem:AllianceSystem;
      
      private var _resetTimer:Timer;
      
      private var _boostItems:Vector.<UIAllianceBoostItem>;
      
      private var _bonusBoostItem:UIAllianceBoostItem;
      
      private var _newRoundWaiting:Boolean = false;
      
      private var ui_background:UIImage;
      
      private var ui_titleBar:UITitleBar;
      
      private var ui_stars:UIBoostStars;
      
      private var txt_title:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var mc_blocker:Sprite;
      
      private var ui_effectInfo:UIItemInfo;
      
      private var btn_help:HelpButton;
      
      public function AlliancePage_Overview_Boosts()
      {
         super();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this._allianceSystem = AllianceSystem.getInstance();
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.add(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.add(this.onAllianceRoundEnded);
         this._boostItems = new Vector.<UIAllianceBoostItem>();
         this.ui_titleBar = new UITitleBar(null,this.TITLE_COLOR);
         this.ui_titleBar.width = int(this._width - 6);
         this.ui_titleBar.height = 26;
         this.ui_titleBar.x = this.ui_titleBar.y = 3;
         this._displayArea = new Rectangle(0,int(this.ui_titleBar.y + this.ui_titleBar.height),this._width,int(this._height - this.ui_titleBar.height - this.ui_titleBar.y));
         this.ui_background = new UIImage(183,96,0,0,false,"images/ui/alliance-boost-bg.jpg");
         this.ui_background.x = int(this._displayArea.right - this.ui_background.width - 3);
         this.ui_background.y = int(this._displayArea.y + (this._displayArea.height - this.ui_background.height) * 0.5);
         this.txt_title = new BodyTextField({
            "text":" ",
            "color":15686202,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.text = Language.getInstance().getString("alliance.overview_boosts_title").toUpperCase();
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         this.txt_title.x = int(this.txt_title.y + 2);
         this.txt_time = new BodyTextField({
            "text":" ",
            "color":12822433,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_time.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_time.height) * 0.5);
         this.btn_help = new HelpButton("alliance.boost_help");
         this.btn_help.height = 18;
         this.btn_help.scaleX = this.btn_help.scaleY;
         this.btn_help.x = int(this.txt_title.x + this.txt_title.width + 6);
         this.btn_help.y = int(this.txt_title.y + (this.txt_title.height - this.btn_help.height) * 0.5);
         addChild(this.ui_background);
         addChild(this.ui_titleBar);
         addChild(this.txt_title);
         addChild(this.btn_help);
         addChild(this.txt_time);
         this.ui_stars = new UIBoostStars(Config.constant.ALLIANCE_EFFECT_BASE_COUNT);
         addChild(this.ui_stars);
         this._resetTimer = new Timer(60000);
         this._resetTimer.addEventListener(TimerEvent.TIMER,this.onResetTimerTick,false,0,true);
         this.ui_effectInfo = new UIItemInfo();
         this.createBoostItems();
         this.updateEffectCosts();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIAllianceBoostItem = null;
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this);
         if(this._allianceSystem.alliance != null)
         {
            this._allianceSystem.alliance.effectAdded.remove(this.onEffectAdded);
         }
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem.roundStarted.remove(this.onAllianceRoundStarted);
         this._allianceSystem.roundEnded.remove(this.onAllianceRoundEnded);
         this._allianceSystem = null;
         this._resetTimer.stop();
         this.ui_titleBar.dispose();
         this.ui_background.dispose();
         this.ui_stars.dispose();
         this.txt_time.dispose();
         this.txt_title.dispose();
         this.ui_effectInfo.dispose();
         this.btn_help.dispose();
         for each(_loc1_ in this._boostItems)
         {
            _loc1_.dispose();
         }
         this._boostItems = null;
         this._bonusBoostItem.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc4_:UIAllianceBoostItem = null;
         _loc1_ = 10;
         var _loc2_:int = _loc1_;
         var _loc3_:int = 0;
         while(_loc3_ < this._boostItems.length)
         {
            _loc4_ = this._boostItems[_loc3_];
            _loc4_.redraw();
            _loc4_.x = _loc2_;
            _loc4_.y = int(this._displayArea.y + (this._displayArea.height - _loc4_.height) * 0.5);
            _loc2_ += int(_loc4_.width + _loc1_);
            _loc3_++;
         }
         this._bonusBoostItem.redraw();
         this._bonusBoostItem.x = int(_loc2_ + (this._displayArea.right - _loc2_ - this._bonusBoostItem.width) * 0.5);
         this._bonusBoostItem.y = int(this._displayArea.y + (this._displayArea.height - this._bonusBoostItem.height) * 0.5 - 6);
         this.ui_stars.x = int(this._bonusBoostItem.x + (this._bonusBoostItem.width - this.ui_stars.width) * 0.5);
         this.ui_stars.y = int(this._bonusBoostItem.y + this._bonusBoostItem.height + 4);
      }
      
      private function createBoostItems() : void
      {
         var _loc1_:UIAllianceBoostItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._bonusBoostItem != null)
         {
            this.ui_effectInfo.removeRolloverTarget(this._bonusBoostItem);
            this._bonusBoostItem.dispose();
         }
         for each(_loc1_ in this._boostItems)
         {
            this.ui_effectInfo.removeRolloverTarget(_loc1_);
            _loc1_.dispose();
         }
         _loc2_ = int(Config.constant.ALLIANCE_EFFECT_BASE_COUNT);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc1_ = new UIAllianceBoostItem(3028544,this._allianceSystem.round.getEffect(_loc3_));
            _loc1_.active = this._allianceSystem.alliance.getEffect(_loc3_) != null;
            _loc1_.mouseOver.add(this.onBoostItemMouseOver);
            _loc1_.clicked.add(this.onBoostItemClicked);
            this.ui_effectInfo.addRolloverTarget(_loc1_);
            addChild(_loc1_);
            this._boostItems[_loc3_] = _loc1_;
            if(_loc1_.active)
            {
               this.ui_stars.enableStar(_loc3_);
            }
            else
            {
               this.ui_stars.disableStar(_loc3_);
            }
            if(!this._allianceSystem.canContributeToRound)
            {
               _loc1_.filters = [Effects.GREYSCALE.filter];
            }
            _loc3_++;
         }
         this._bonusBoostItem = new UIAllianceBoostItem(4144959,this._allianceSystem.round.getBonusEffect());
         this._bonusBoostItem.mouseOver.add(this.onBoostItemMouseOver);
         this._bonusBoostItem.active = this._allianceSystem.alliance.getEffect(_loc2_) != null;
         if(!this._allianceSystem.canContributeToRound)
         {
            this._bonusBoostItem.filters = [Effects.GREYSCALE.filter];
            this.ui_stars.filters = [Effects.GREYSCALE.filter];
         }
         else
         {
            this.ui_stars.filters = [];
         }
         this.ui_effectInfo.addRolloverTarget(this._bonusBoostItem);
         addChild(this._bonusBoostItem);
         invalidate();
      }
      
      private function onBoostItemMouseOver(param1:MouseEvent) : void
      {
         if(stage == null)
         {
            return;
         }
         var _loc2_:UIAllianceBoostItem = UIAllianceBoostItem(param1.currentTarget);
         TooltipManager.getInstance().remove(_loc2_);
         this.ui_effectInfo.setItem(_loc2_.effectItem);
         invalidate();
      }
      
      private function buyBoost(param1:int) : void
      {
         var dlgBusy:BusyDialogue = null;
         var item:UIAllianceBoostItem = null;
         var index:int = param1;
         if(!this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.SpendTokens))
         {
            return;
         }
         if(!this._allianceSystem.canContributeToRound)
         {
            return;
         }
         dlgBusy = new BusyDialogue(Language.getInstance().getString("alliance.boost_buy_loading"));
         dlgBusy.open();
         item = this._boostItems[index];
         this._allianceSystem.buyEffect(index,function(param1:RPCResponse):void
         {
            var _loc2_:Language = null;
            var _loc3_:MessageBox = null;
            dlgBusy.close();
            if(!param1.success)
            {
               _loc2_ = Language.getInstance();
               _loc3_ = new MessageBox(_loc2_.getString("alliance.boost_buy_error_msg"));
               _loc3_.addTitle(_loc2_.getString("alliance.boost_buy_error_title"),BaseDialogue.TITLE_COLOR_RUST);
               _loc3_.addButton(_loc2_.getString("alliance.boost_buy_error_ok"));
               _loc3_.open();
               return;
            }
            item.mouseEnabled = false;
         });
      }
      
      private function updateResetTime() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(AllianceSystem.getInstance().warActive == false)
         {
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_comingSoon");
         }
         else if(!this._allianceSystem.canContributeToRound)
         {
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_availnextround");
         }
         else if(this._newRoundWaiting)
         {
            _loc1_ = int((this._allianceSystem.round.activeTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_boosts_available",DateTimeUtils.secondsToString(_loc1_,true,false,true).replace("<","&lt;"));
         }
         else
         {
            _loc2_ = int((this._allianceSystem.round.endTime.time - Network.getInstance().serverTime) / 1000);
            if(_loc2_ <= 0)
            {
               _loc2_ = 0;
            }
            this.txt_time.htmlText = Language.getInstance().getString("alliance.overview_boosts_reset",DateTimeUtils.secondsToString(_loc2_,true,false,true).replace("<","&lt;"));
         }
         this.txt_time.x = int(this.ui_titleBar.x + this.ui_titleBar.width - this.txt_time.width - 2);
      }
      
      private function updateEffectCosts() : void
      {
         var _loc2_:UIAllianceBoostItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._boostItems.length)
         {
            _loc2_ = this._boostItems[_loc1_];
            _loc2_.cost = this._allianceSystem.getEffectCost(_loc1_);
            _loc2_.y = int(this._displayArea.y + (this._displayArea.height - _loc2_.height) * 0.5);
            _loc1_++;
         }
      }
      
      private function lock() : void
      {
         if(this.mc_blocker == null)
         {
            this.mc_blocker = new Sprite();
            this.mc_blocker.buttonMode = true;
            this.mc_blocker.useHandCursor = false;
         }
         this.mc_blocker.x = this._displayArea.x + 1;
         this.mc_blocker.y = this._displayArea.y + 1;
         this.mc_blocker.graphics.clear();
         this.mc_blocker.graphics.beginFill(0,0.8);
         this.mc_blocker.graphics.drawRect(0,0,this._displayArea.width - 2,this._displayArea.height - 2);
         this.mc_blocker.graphics.endFill();
         addChild(this.mc_blocker);
      }
      
      private function unlock() : void
      {
         if(this.mc_blocker == null)
         {
            return;
         }
         mouseChildren = true;
         if(this.mc_blocker.parent != null)
         {
            this.mc_blocker.parent.removeChild(this.mc_blocker);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._resetTimer.start();
         this._allianceSystem.alliance.effectAdded.add(this.onEffectAdded);
         this._newRoundWaiting = Network.getInstance().serverTime < this._allianceSystem.round.activeTime.time;
         this.updateResetTime();
         if(this._newRoundWaiting)
         {
            this.lock();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._resetTimer.stop();
      }
      
      private function onResetTimerTick(param1:TimerEvent) : void
      {
         this.updateResetTime();
         this.updateEffectCosts();
      }
      
      private function onEffectAdded(param1:int, param2:Effect) : void
      {
         var _loc4_:UIAllianceBoostItem = null;
         if(param1 < 0)
         {
            return;
         }
         var _loc3_:* = param1 >= this._boostItems.length;
         _loc4_ = _loc3_ ? this._bonusBoostItem : this._boostItems[param1];
         _loc4_.active = true;
         _loc4_.mouseEnabled = true;
         this.ui_stars.enableStar(param1);
         TweenMax.from(_loc4_,1,{"colorTransform":{"exposure":2}});
      }
      
      private function onBoostItemClicked(param1:MouseEvent) : void
      {
         var item:UIAllianceBoostItem;
         var lang:Language;
         var boostName:String;
         var msgConfirm:MessageBox;
         var index:int = 0;
         var msgNoTokens:MessageBox = null;
         var e:MouseEvent = param1;
         if(this._allianceSystem.clientMember == null || !this._allianceSystem.clientMember.hasPrivilege(AllianceRankPrivilege.SpendTokens))
         {
            return;
         }
         item = UIAllianceBoostItem(e.currentTarget);
         index = int(this._boostItems.indexOf(item));
         if(item.active)
         {
            return;
         }
         lang = Language.getInstance();
         if(!this._allianceSystem.canContributeToRound)
         {
            TooltipManager.getInstance().add(item,lang.getString("alliance.noboosts"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            TooltipManager.getInstance().show(item);
            Audio.sound.play("sound/interface/int-error.mp3");
            return;
         }
         if(item.cost > this._allianceSystem.alliance.tokens)
         {
            msgNoTokens = new MessageBox(lang.getString("alliance.notokens_msg"),null,true);
            msgNoTokens.addTitle(lang.getString("alliance.notokens_title"),BaseDialogue.TITLE_COLOR_RUST);
            msgNoTokens.addButton(lang.getString("alliance.notokens_ok"));
            msgNoTokens.open();
            return;
         }
         boostName = item.effectItem.getName();
         msgConfirm = new MessageBox(lang.getString("alliance.boost_buy_msg",boostName,NumberFormatter.format(item.cost,0)),null,true);
         msgConfirm.addTitle(lang.getString("alliance.boost_buy_title",boostName),this.TITLE_COLOR);
         msgConfirm.addImage(item.effect.imageURI);
         msgConfirm.addButton(lang.getString("alliance.boost_buy_cancel"));
         msgConfirm.addButton(lang.getString("alliance.boost_buy_ok"),true,{
            "buttonClass":PurchasePushButton,
            "currency":Currency.ALLIANCE_TOKENS,
            "cost":item.cost,
            "iconAlign":PurchasePushButton.ICON_ALIGN_LABEL_RIGHT,
            "width":100
         }).clicked.addOnce(function(param1:MouseEvent):void
         {
            if(_allianceSystem == null)
            {
               return;
            }
            buyBoost(index);
         });
         msgConfirm.open();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this._resetTimer.stop();
         if(Boolean(this._allianceSystem) && this._allianceSystem.alliance != null)
         {
            this._allianceSystem.alliance.effectAdded.remove(this.onEffectAdded);
         }
         this.lock();
      }
      
      private function onAllianceRoundStarted() : void
      {
         this._newRoundWaiting = false;
         this.createBoostItems();
         this.updateEffectCosts();
         this.updateResetTime();
         this.unlock();
      }
      
      private function onAllianceRoundEnded() : void
      {
         this._newRoundWaiting = true;
         this.updateResetTime();
         this.lock();
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.BitmapData;
import thelaststand.app.gui.UIComponent;

class UIBoostStars extends UIComponent
{
   
   private var _bmdOff:BitmapData;
   
   private var _bmdOn:BitmapData;
   
   private var _stars:Vector.<Bitmap>;
   
   private var _numStars:int;
   
   public function UIBoostStars(param1:int)
   {
      var _loc4_:Bitmap = null;
      this._bmdOff = new BmpIconEmptyStar();
      this._bmdOn = new BmpIconNewItem();
      super();
      this._numStars = param1;
      this._stars = new Vector.<Bitmap>(this._numStars,true);
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      while(_loc3_ < this._numStars)
      {
         _loc4_ = new Bitmap(this._bmdOff);
         _loc4_.x = _loc2_;
         _loc2_ += int(_loc4_.width);
         this._stars[_loc3_] = _loc4_;
         addChild(_loc4_);
         _loc3_++;
      }
   }
   
   override public function dispose() : void
   {
      super.dispose();
      this._bmdOff.dispose();
      this._bmdOn.dispose();
      this._stars = null;
   }
   
   public function enableStar(param1:int) : void
   {
      if(param1 < 0 || param1 >= this._numStars)
      {
         return;
      }
      if(this._stars[param1].bitmapData == this._bmdOn)
      {
         return;
      }
      this._stars[param1].bitmapData = this._bmdOn;
      if(stage != null)
      {
         TweenMax.from(this._stars[param1],1,{"colorTransform":{"exposure":2}});
      }
   }
   
   public function disableStar(param1:int) : void
   {
      if(this._stars[param1].bitmapData == this._bmdOff)
      {
         return;
      }
      this._stars[param1].bitmapData = this._bmdOff;
   }
}
