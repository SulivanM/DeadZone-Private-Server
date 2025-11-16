package thelaststand.app.game.gui.store
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.Cooldown;
   import thelaststand.app.game.data.effects.CooldownType;
   import thelaststand.app.game.gui.UIUnavailableBanner;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.buttons.AbstractButton;
   import thelaststand.common.lang.Language;
   
   public class UIStoreProtectionPage extends UIComponent
   {
      
      private const PANEL_SPACING:int = 0;
      
      private const PADDING:int = 6;
      
      private var _availableTimer:TimerData;
      
      private var _protectionOptions:Vector.<Object>;
      
      private var _panels:Vector.<UIStoreProtectionPanel>;
      
      private var _width:int;
      
      private var _height:int;
      
      private var mc_panelContainer:Sprite;
      
      private var ui_titleBar:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var txt_footer:BodyTextField;
      
      private var ui_unavailable:UIUnavailableBanner;
      
      public function UIStoreProtectionPage(param1:int, param2:int)
      {
         var numOptions:int;
         var i:int;
         var panel:UIStoreProtectionPanel = null;
         var width:int = param1;
         var height:int = param2;
         super();
         this._width = width;
         this._height = height;
         this._protectionOptions = Network.getInstance().data.costTable.getItems("protection");
         this._protectionOptions.sort(function(param1:Object, param2:Object):int
         {
            return int(param1.length) - int(param2.length);
         });
         this._panels = new Vector.<UIStoreProtectionPanel>();
         numOptions = int(this._protectionOptions.length);
         this.mc_panelContainer = new Sprite();
         addChild(this.mc_panelContainer);
         i = 0;
         while(i < numOptions)
         {
            panel = new UIStoreProtectionPanel();
            panel.purchasedClicked.add(this.onOptionPurchased);
            panel.storeItem = this._protectionOptions[i];
            panel.imageURI = "images/ui/protection-" + (i + 1) + ".jpg";
            this._panels.push(panel);
            this.mc_panelContainer.addChild(panel);
            i++;
         }
         this.ui_titleBar = new UITitleBar(null,3103775);
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "color":13425038,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.text = Language.getInstance().getString("store_protection_title");
         addChild(this.txt_title);
         this.txt_footer = new BodyTextField({
            "color":7434609,
            "size":13,
            "multiline":true
         });
         this.txt_footer.text = Language.getInstance().getString("store_protection_desc");
         addChild(this.txt_footer);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIStoreProtectionPanel = null;
         super.dispose();
         if(this.ui_unavailable != null)
         {
            this.ui_unavailable.dispose();
         }
         if(this._availableTimer != null)
         {
            this._availableTimer.completed.remove(this.onAvailableTimerCompleted);
            this._availableTimer = null;
         }
         for each(_loc1_ in this._panels)
         {
            _loc1_.dispose();
         }
         this._protectionOptions = null;
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:UIStoreProtectionPanel = null;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_titleBar.x = this.ui_titleBar.y = this.PADDING;
         this.ui_titleBar.width = int(this._width - this.ui_titleBar.x * 2);
         this.ui_titleBar.height = 30;
         this.txt_title.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         _loc1_ = 50;
         var _loc2_:int = this._width - this.PADDING * 2;
         _loc3_ = int(this._height - _loc1_ - this.PADDING);
         graphics.beginFill(1118481);
         graphics.drawRect(this.PADDING,_loc3_,_loc2_,_loc1_);
         graphics.endFill();
         this.txt_footer.x = int(this.PADDING + 6);
         this.txt_footer.width = int(this._width - this.txt_footer.x * 2);
         this.txt_footer.y = int(_loc3_ + (_loc1_ - this.txt_footer.height) * 0.5);
         _loc4_ = 4;
         this.mc_panelContainer.x = this.PADDING;
         this.mc_panelContainer.y = this.PADDING + this.ui_titleBar.height + _loc4_;
         var _loc5_:int = (this._width - this.mc_panelContainer.x) / this._panels.length;
         var _loc6_:int = int(_loc3_ - this.mc_panelContainer.y - _loc4_);
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         while(_loc8_ < this._panels.length)
         {
            _loc9_ = this._panels[_loc8_];
            _loc9_.width = _loc5_;
            _loc9_.height = _loc6_;
            _loc9_.backgroundColor = _loc8_ % 2 == 0 ? 1118481 : 2171169;
            _loc9_.x = _loc7_;
            _loc9_.redraw();
            _loc7_ += _loc9_.width + this.PANEL_SPACING;
            _loc8_++;
         }
         this.checkAvailability();
      }
      
      private function checkAvailability() : void
      {
         if(this._availableTimer != null)
         {
            this._availableTimer.completed.remove(this.onAvailableTimerCompleted);
            this._availableTimer = null;
         }
         var _loc1_:PlayerData = Network.getInstance().playerData;
         var _loc2_:Cooldown = _loc1_.cooldowns.getByType(CooldownType.DisablePvP);
         if(_loc2_ != null && _loc2_.timer != null)
         {
            if(this._availableTimer == null || _loc2_.timer.timeEnd.time > this._availableTimer.timeEnd.time)
            {
               this._availableTimer = _loc2_.timer;
            }
         }
         if(this._availableTimer != null && this._availableTimer.timeEnd.time > Network.getInstance().serverTime)
         {
            this._availableTimer.completed.addOnce(this.onAvailableTimerCompleted);
            if(this.ui_unavailable == null)
            {
               this.ui_unavailable = new UIUnavailableBanner();
            }
            this.ui_unavailable.timer = this._availableTimer;
            this.ui_unavailable.title = Language.getInstance().getString("store_protection_disabled_title");
            this.ui_unavailable.message = Language.getInstance().getString("store_protection_disabled_msg");
            this.ui_unavailable.width = this._width;
            this.ui_unavailable.height = 110;
            this.ui_unavailable.x = int((this._width - this.ui_unavailable.width) * 0.5) - 1;
            this.ui_unavailable.y = int(this.mc_panelContainer.y + (this.mc_panelContainer.height - this.ui_unavailable.height) * 0.5);
            addChild(this.ui_unavailable);
            this.mc_panelContainer.mouseChildren = false;
            this.mc_panelContainer.filters = [Effects.GREYSCALE.filter];
            this.mc_panelContainer.alpha = 0.5;
         }
         else if(this.ui_unavailable != null)
         {
            this.ui_unavailable.dispose();
            this.ui_unavailable = null;
            this.mc_panelContainer.mouseChildren = true;
            this.mc_panelContainer.filters = [];
            this.mc_panelContainer.alpha = 1;
         }
      }
      
      private function onOptionPurchased(param1:Object) : void
      {
         var cost:uint = 0;
         var allianceSystem:AllianceSystem = null;
         var dlgConfirm:MessageBox = null;
         var btn:AbstractButton = null;
         var optionData:Object = param1;
         var network:Network = Network.getInstance();
         cost = uint(optionData.PriceCoins);
         if(cost > network.playerData.compound.resources.getAmount(GameResources.CASH))
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
         }
         else
         {
            allianceSystem = AllianceSystem.getInstance();
            if(allianceSystem.inAlliance && allianceSystem.isRoundActive && allianceSystem.canContributeToRound)
            {
               dlgConfirm = new MessageBox(Language.getInstance().getString("alliance.whiteflagConfirm_msg"),"dlgConfirm",true);
               dlgConfirm.addTitle(Language.getInstance().getString("alliance.whiteflagConfirm_title"));
               btn = dlgConfirm.addButton(Language.getInstance().getString("alliance.whiteflagConfirm_yes"),true,{"width":100});
               btn.clicked.addOnce(function(param1:MouseEvent = null):void
               {
                  DoProtectionPurchase(cost,optionData,true);
               });
               dlgConfirm.addButton(Language.getInstance().getString("alliance.whiteflagConfirm_no"),true,{"width":100});
               dlgConfirm.open();
            }
            else
            {
               this.DoProtectionPurchase(cost,optionData,false);
            }
         }
      }
      
      private function DoProtectionPurchase(param1:uint, param2:Object, param3:Boolean) : void
      {
         var cost:uint = param1;
         var optionData:Object = param2;
         var removeAllianceScores:Boolean = param3;
         var len:int = int(optionData.length);
         var strTime:String = optionData.length <= 24 * 60 * 60 ? int(len / 60 / 60).toString() + " hrs" : DateTimeUtils.secondsToString(len);
         var lang:Language = Language.getInstance();
         var msgConfirm:MessageBox = new MessageBox(lang.getString("store_protection_confirm_msg",strTime,NumberFormatter.format(cost,0)));
         msgConfirm.addTitle(lang.getString("store_protection_confirm_title"),BaseDialogue.TITLE_COLOR_BUY);
         msgConfirm.addImage("images/ui/protection-" + (this._protectionOptions.indexOf(optionData) + 1) + ".jpg");
         msgConfirm.addButton(lang.getString("store_protection_confirm_cancel"));
         msgConfirm.addButton(lang.getString("store_protection_confirm_ok"),true,{"backgroundColor":4226049}).clicked.addOnce(function(param1:MouseEvent):void
         {
            var e:MouseEvent = param1;
            PaymentSystem.getInstance().buyProtection(optionData.key,function(param1:Boolean):void
            {
               if(param1)
               {
                  checkAvailability();
                  if(removeAllianceScores && AllianceSystem.getInstance().isConnected)
                  {
                     AllianceSystem.getInstance().sendRPC("clearRndPts",{"reason":"whiteflag"});
                  }
               }
            });
         });
         msgConfirm.open();
      }
      
      private function onAvailableTimerCompleted(param1:TimerData) : void
      {
         this.checkAvailability();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
   }
}

