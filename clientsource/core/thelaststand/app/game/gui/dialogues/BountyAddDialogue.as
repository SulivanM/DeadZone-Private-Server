package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormatAlign;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.gui.bounty.BountyStyleBox;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   
   public class BountyAddDialogue extends BaseDialogue
   {
      
      private var _playerName:String;
      
      private var _playerId:String;
      
      private var _lang:Language;
      
      private var _contentWidth:Number = 320;
      
      private var _glowbox:Shape;
      
      private var _amount:int;
      
      private var _minAdd:int;
      
      private var _maxAdd:int;
      
      private var _increment:int;
      
      private var _amountDir:int = 0;
      
      private var _timer:Timer;
      
      private var mc_container:Sprite;
      
      private var mc_content:Sprite;
      
      private var bd_titleIcon:BitmapData;
      
      private var bg:BountyStyleBox;
      
      private var bd_stars:BitmapData;
      
      private var bmp_starsLeft:Bitmap;
      
      private var bmp_starsRight:Bitmap;
      
      private var txt_heading:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_addBounty:BodyTextField;
      
      private var txt_feedback:BodyTextField;
      
      private var txt_disclaimer:BodyTextField;
      
      private var txt_description:BodyTextField;
      
      private var bd_divider:BitmapData;
      
      private var d1:Bitmap;
      
      private var d2:Bitmap;
      
      private var d3:Bitmap;
      
      private var priceContainer:Sprite;
      
      private var txt_amount:BodyTextField;
      
      private var btn_decrease:PushButton;
      
      private var btn_increase:PushButton;
      
      private var bmp_fuel:Bitmap;
      
      private var _maxInputLen:Number;
      
      private var _maxInputWidth:Number;
      
      private var btn_submit:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var btn_help:HelpButton;
      
      private var arrowUp:BitmapData;
      
      private var arrowDown:BitmapData;
      
      private var spinner:UIBusySpinner;
      
      public var onSuccess:Signal;
      
      public function BountyAddDialogue(param1:String, param2:String)
      {
         var m:Matrix;
         var temp:Number;
         var ct:ColorTransform;
         var perc:Number;
         var g:Graphics = null;
         var ty:Number = NaN;
         var playerName:String = param1;
         var playerId:String = param2;
         this.onSuccess = new Signal();
         this._lang = Language.getInstance();
         this._playerName = playerName;
         this._playerId = playerId;
         this._timer = new Timer(1000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
         this.mc_container = new Sprite();
         super("BountyAddDialogue",this.mc_container,true);
         _autoSize = false;
         _width = 354;
         _height = 396;
         this._minAdd = Number(Config.constant.BOUNTY_MIN_ADD);
         this._maxAdd = Number(Config.constant.BOUNTY_MAX_ADD);
         this._increment = Number(Config.constant.BOUNTY_INCREMENT);
         this._amount = this._minAdd;
         this.bd_titleIcon = new BmpBountySkull();
         addTitle(this._lang.getString("bounty.windowTitle"),BaseDialogue.TITLE_COLOR_GREY,-1,this.bd_titleIcon);
         this.bg = new BountyStyleBox(327,317);
         this.bg.y = _padding * 0.5;
         this.mc_container.addChild(this.bg);
         this.mc_content = new Sprite();
         this.mc_container.addChild(this.mc_content);
         this.mc_content.x = 3;
         this.mc_content.y = 3;
         g = this.mc_content.graphics;
         g.beginFill(16777215,0.3);
         ty = 0;
         this.bd_stars = new BmpBountyStars();
         this.bmp_starsLeft = new Bitmap(this.bd_stars);
         this.bmp_starsLeft.x = 14;
         this.bmp_starsLeft.y = 16;
         this.mc_content.addChild(this.bmp_starsLeft);
         this.bmp_starsRight = new Bitmap(this.bd_stars);
         this.bmp_starsRight.x = this._contentWidth - this.bmp_starsRight.width - this.bmp_starsLeft.x;
         this.bmp_starsRight.y = this.bmp_starsLeft.y;
         this.mc_content.addChild(this.bmp_starsRight);
         this.txt_heading = new BodyTextField({
            "size":40,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_heading.text = this._lang.getString("bounty.wanted");
         this.txt_heading.x = this.bmp_starsLeft.x + this.bmp_starsLeft.width;
         this.txt_heading.width = this.bmp_starsRight.x - this.txt_heading.x;
         this.mc_content.addChild(this.txt_heading);
         this.bd_divider = new BmpBountyDivider();
         this.d1 = new Bitmap(this.bd_divider);
         this.d1.x = 0;
         this.d1.y = 53;
         this.mc_content.addChild(this.d1);
         this.d2 = new Bitmap(this.bd_divider);
         this.d2.x = -2;
         this.d2.y = this.d1.y + 48;
         this.mc_content.addChild(this.d2);
         g.drawRect(1,this.d1.y,this._contentWidth - 2,this.d2.y - this.d1.y + 3);
         this.txt_name = new BodyTextField({
            "size":24,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_name.text = playerName;
         this.txt_name.width = this._contentWidth;
         this.txt_name.y = this.d1.y + (this.d2.y - this.d1.y - this.txt_name.height) * 0.5;
         this.mc_content.addChild(this.txt_name);
         this.txt_addBounty = new BodyTextField({
            "size":18,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_addBounty.text = this._lang.getString("bounty.loading");
         this.txt_addBounty.width = this._contentWidth;
         this.txt_addBounty.y = this.d2.y + 5;
         this.mc_content.addChild(this.txt_addBounty);
         ty = this.txt_addBounty.y + this.txt_addBounty.height + 3;
         g.drawRect(1,ty,this._contentWidth - 2,60);
         this.priceContainer = new Sprite();
         this.priceContainer.y = ty;
         this.bmp_fuel = new Bitmap(new BmpIconFuel());
         this.bmp_fuel.y = int((60 - this.bmp_fuel.height) * 0.5);
         this.priceContainer.addChild(this.bmp_fuel);
         this.bmp_fuel.filters = [new GlowFilter(0,0.3,10,10)];
         this.txt_amount = new BodyTextField({
            "border":false,
            "color":4276025,
            "size":56,
            "bold":true,
            "autoSize":"center",
            "align":"center",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_amount.addEventListener(FocusEvent.FOCUS_IN,this.onAmountFocusIn,false,0,true);
         this.txt_amount.addEventListener(FocusEvent.FOCUS_OUT,this.onAmountFocusOut,false,0,true);
         this.txt_amount.addEventListener(Event.CHANGE,this.onAmountChange,false,0,true);
         this.txt_amount.type = TextFieldType.INPUT;
         this.txt_amount.selectable = true;
         this.txt_amount.mouseEnabled = true;
         this.txt_amount.text = NumberFormatter.format(this._maxAdd,0);
         this.priceContainer.addChild(this.txt_amount);
         this.txt_amount.y = int((60 - this.txt_amount.height) * 0.5) - 2;
         this._maxInputWidth = this.txt_amount.width + 10;
         this._maxInputLen = String(Config.constant.BOUNTY_MAX_ADD).length;
         this.txt_amount.autoSize = "none";
         this.txt_amount.width = this._maxInputWidth;
         this.arrowUp = new BmpIconBountyArrow();
         this.btn_increase = new PushButton("",this.arrowUp);
         this.btn_increase.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonMouseDown,false,0,true);
         this.btn_increase.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         this.btn_increase.width = 19;
         this.btn_increase.height = 17;
         this.btn_increase.backgroundColor = 8748389;
         this.btn_increase.strokeColor = 6840911;
         this.btn_increase.outlineColor = 12959661;
         this.priceContainer.addChild(this.btn_increase);
         this.arrowDown = new BitmapData(this.arrowUp.width,this.arrowUp.height,true,0);
         m = new Matrix();
         m.scale(1,-1);
         m.translate(0,this.arrowDown.height);
         this.arrowDown.draw(this.arrowUp,m);
         this.btn_decrease = new PushButton("",this.arrowDown);
         this.btn_decrease.addEventListener(MouseEvent.MOUSE_DOWN,this.onButtonMouseDown,false,0,true);
         this.btn_decrease.addEventListener(MouseEvent.MOUSE_UP,this.onButtonMouseUp,false,0,true);
         this.btn_decrease.width = 19;
         this.btn_decrease.height = 17;
         this.btn_decrease.backgroundColor = 8748389;
         this.btn_decrease.strokeColor = 6840911;
         this.btn_decrease.outlineColor = 12959661;
         this.priceContainer.addChild(this.btn_decrease);
         temp = int((60 - (this.btn_increase.height + this.btn_decrease.height + 6)) * 0.5);
         this.btn_increase.y = temp;
         this.btn_decrease.y = temp + this.btn_increase.height + 6;
         this.txt_amount.x = (this._contentWidth - this._maxInputWidth) * 0.5 - 20;
         this.bmp_fuel.x = this.txt_amount.x + this._maxInputWidth;
         this.btn_increase.x = this.btn_decrease.x = this.bmp_fuel.x + this.bmp_fuel.width + 12;
         this.repositionFuelIcon();
         this.spinner = new UIBusySpinner();
         this.spinner.scaleX = this.spinner.scaleY = 2;
         this.spinner.x = this._contentWidth * 0.5;
         this.spinner.y = ty + 30;
         this.mc_content.addChild(this.spinner);
         ct = new ColorTransform();
         ct.color = 4276025;
         this.spinner.transform.colorTransform = ct;
         ty += 66;
         g.drawRect(1,ty,this._contentWidth - 2,30);
         this.txt_feedback = new BodyTextField({
            "size":18,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_feedback.text = "";
         this.txt_feedback.width = this._contentWidth;
         this.txt_feedback.y = ty + (30 - this.txt_feedback.height) * 0.5 - 2;
         this.mc_content.addChild(this.txt_feedback);
         ty += 32;
         this.txt_description = new BodyTextField({
            "size":12,
            "color":4276025,
            "autoSize":TextFieldAutoSize.CENTER,
            "multiline":true,
            "wordWrap":true,
            "align":TextFormatAlign.CENTER
         });
         this.txt_description.text = this._lang.getString("bounty.desc",playerName);
         this.txt_description.width = this._contentWidth - 30;
         this.txt_description.x = 15;
         this.txt_description.y = ty;
         this.mc_content.addChild(this.txt_description);
         ty = 310 - 31;
         this.d3 = new Bitmap(this.bd_divider);
         this.d3.x = -2;
         this.d3.y = ty;
         this.mc_content.addChild(this.d3);
         ty += 6;
         perc = Number(Config.constant.BOUNTY_CUT) * 100;
         this.txt_disclaimer = new BodyTextField({
            "size":12,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_disclaimer.text = this._lang.getString("bounty.disclaimer",perc.toString());
         this.txt_disclaimer.width = this._contentWidth;
         this.txt_disclaimer.y = ty;
         this.mc_content.addChild(this.txt_disclaimer);
         ty += 45;
         this.btn_submit = new PushButton(this._lang.getString("bounty.btn_submit"),null,-1,null,4226049);
         this.btn_submit.clicked.add(this.onSubmit);
         this.btn_submit.width = 100;
         this.btn_submit.x = this._contentWidth - this.btn_submit.width;
         this.btn_submit.y = ty;
         this.mc_content.addChild(this.btn_submit);
         this.btn_submit.enabled = false;
         this.btn_cancel = new PushButton(this._lang.getString("bounty.btn_cancel"),null,-1,null);
         this.btn_cancel.clicked.addOnce(function(param1:MouseEvent):void
         {
            close();
         });
         this.btn_cancel.width = 100;
         this.btn_cancel.x = this.btn_submit.x - this.btn_cancel.width - _padding;
         this.btn_cancel.y = ty;
         this.mc_content.addChild(this.btn_cancel);
         this.btn_help = new HelpButton("bounty.help_add");
         this.btn_help.y = this.btn_cancel.y + int((this.btn_cancel.height - this.btn_help.height) * 0.5);
         this.mc_content.addChild(this.btn_help);
         Network.getInstance().client.bigDB.load("PlayerSummary",playerId,this.onLoadSuccess,this.displayBountySelector);
      }
      
      override public function dispose() : void
      {
         this.onSuccess.removeAll();
         super.dispose();
         this.txt_amount.removeEventListener(FocusEvent.FOCUS_IN,this.onAmountFocusIn);
         this.txt_amount.removeEventListener(FocusEvent.FOCUS_OUT,this.onAmountFocusOut);
         this.txt_amount.removeEventListener(Event.CHANGE,this.onAmountChange);
         this.btn_submit.dispose();
         this.btn_submit = null;
         this.btn_cancel.dispose();
         this.btn_cancel = null;
         this.btn_decrease.dispose();
         this.btn_decrease = null;
         this.btn_increase.dispose();
         this.btn_increase = null;
         this.txt_amount.dispose();
         this.txt_amount = null;
         this.arrowDown.dispose();
         this.arrowUp.dispose();
         this.btn_help.dispose();
         this.btn_help = null;
         this.txt_addBounty.dispose();
         this.txt_heading.dispose();
         this.txt_name.dispose();
         this.txt_feedback.dispose();
         this.txt_disclaimer.dispose();
         this.bd_titleIcon.dispose();
         this.bg.dispose();
         this.bd_stars.dispose();
         this.bmp_starsLeft = null;
         this.bmp_starsRight = null;
         this.bd_divider.dispose();
         this.d1 = this.d2 = this.d3 = null;
         this.spinner.dispose();
         if(this._glowbox)
         {
            TweenMax.killTweensOf(this._glowbox);
         }
      }
      
      private function repositionFuelIcon() : void
      {
         this.bmp_fuel.x = this.txt_amount.x + this._maxInputWidth * 0.5 + this.txt_amount.textWidth * 0.5 + 8;
      }
      
      private function displayBountySelector(param1:Object = null) : void
      {
         if(this.spinner.parent)
         {
            this.spinner.parent.removeChild(this.spinner);
         }
         this.txt_addBounty.text = Language.getInstance().getString("bounty.addBounty");
         this.mc_content.addChild(this.priceContainer);
         this._amount = this._minAdd;
         this._amountDir = 0;
         this.updateAmount();
         this.btn_submit.enabled = true;
      }
      
      private function displayBountyFull() : void
      {
         if(this.spinner.parent)
         {
            this.spinner.parent.removeChild(this.spinner);
         }
         this.txt_addBounty.text = this._lang.getString("bounty.currentBounty");
         this.txt_feedback.text = this._lang.getString("bounty.maxReached");
         this.removePriceControls(Number(Config.constant.BOUNTY_MAX_TOTAL));
         this.mc_content.addChild(this.priceContainer);
      }
      
      private function removePriceControls(param1:int) : void
      {
         if(this.btn_decrease.parent)
         {
            this.btn_decrease.parent.removeChild(this.btn_decrease);
         }
         if(this.btn_increase.parent)
         {
            this.btn_increase.parent.removeChild(this.btn_increase);
         }
         this.txt_amount.type = TextFieldType.DYNAMIC;
         this.txt_amount.selectable = false;
         this.txt_amount.mouseEnabled = this.txt_amount.mouseWheelEnabled = false;
         this.txt_amount.autoSize = TextFieldAutoSize.CENTER;
         this.txt_amount.maxChars = -1;
         this.txt_amount.text = NumberFormatter.format(param1,0);
         this.txt_amount.x = (this._contentWidth - (this.txt_amount.width + this.bmp_fuel.width + 8)) * 0.5;
         this.bmp_fuel.x = this.txt_amount.x + this.txt_amount.width + 8;
      }
      
      private function buyBounty() : void
      {
         var msg:BusyDialogue = null;
         msg = new BusyDialogue(this._lang.getString("bounty.purchasing"),"bounty-purchasing");
         msg.open();
         Network.getInstance().save({
            "userId":this._playerId,
            "amount":this._amount
         },SaveDataMethod.ADD_BOUNTY,function(param1:Object):void
         {
            var _loc2_:MessageBox = null;
            if(!param1.success)
            {
               _loc2_ = new MessageBox(_lang.getString("bounty.failBody"));
               _loc2_.addTitle(_lang.getString("bounty.failTitle"));
               _loc2_.addButton(_lang.getString("bounty.failOk"));
               _loc2_.open();
               btn_submit.enabled = true;
               msg.close();
               return;
            }
            displaySuccessScreen(param1["amount"],param1["total"]);
            msg.close();
            onSuccess.dispatch();
         });
      }
      
      private function displaySuccessScreen(param1:int, param2:int) : void
      {
         this.removePriceControls(param2);
         this.txt_addBounty.text = this._lang.getString("bounty.currentBounty");
         this.txt_feedback.text = this._lang.getString("bounty.contribution",param1.toString());
         if(this.btn_submit.parent)
         {
            this.btn_submit.parent.removeChild(this.btn_submit);
         }
         this.btn_cancel.label = this._lang.getString("bounty.btn_close");
         this.btn_cancel.x = int((this._contentWidth - this.btn_cancel.width) * 0.5);
         this._glowbox = new Shape();
         this._glowbox.graphics.beginFill(16777215);
         this._glowbox.graphics.drawRect(0,0,327,317);
         this._glowbox.x = this._glowbox.y = -3;
         this.mc_content.addChild(this._glowbox);
         TweenMax.to(this._glowbox,0,{"glowFilter":{
            "blurX":40,
            "blurY":40,
            "strength":1,
            "alpha":1,
            "color":16777215
         }});
         TweenMax.to(this._glowbox,1.3,{
            "alpha":0,
            "glowFilter":{
               "blurX":5,
               "blurY":5,
               "strength":1,
               "alpha":0,
               "color":16777215
            }
         });
         Tracking.trackEvent("Bounty","bounty_added",this._playerId,0);
         Tracking.trackEvent("Bounty","bounty_added_value",Math.floor(param2).toString());
         Audio.sound.play("sound/interface/bounty-general.mp3");
      }
      
      private function onLoadSuccess(param1:Object) : void
      {
         if(param1 == null)
         {
            this.displayBountySelector();
            return;
         }
         var _loc2_:int = 0;
         if(param1.hasOwnProperty("bounty"))
         {
            _loc2_ = int(param1.bounty);
         }
         var _loc3_:Number = Number(Config.constant.BOUNTY_MAX_TOTAL);
         _loc3_ -= _loc2_;
         if(this._maxAdd > _loc3_)
         {
            this._maxAdd = _loc3_;
         }
         if(this._maxAdd <= 0)
         {
            this.displayBountyFull();
            return;
         }
         if(this._minAdd > this._maxAdd)
         {
            this._minAdd = this._maxAdd;
         }
         this.displayBountySelector();
      }
      
      private function onSubmit(param1:Event = null) : void
      {
         var network:Network;
         var dlgConfirm:MessageBox = null;
         var e:Event = param1;
         this.btn_submit.enabled = false;
         network = Network.getInstance();
         if(this._amount > network.playerData.compound.resources.getAmount(GameResources.CASH))
         {
            PaymentSystem.getInstance().openBuyCoinsScreen(true);
            this.btn_submit.enabled = true;
            return;
         }
         dlgConfirm = new MessageBox(this._lang.getString("bounty.confirm_msg","<b>" + this._playerName + "</b>"),"confirm-purchase");
         dlgConfirm.addTitle(this._lang.getString("bounty.confirm_title",this._playerName),BaseDialogue.TITLE_COLOR_BUY);
         dlgConfirm.addButton(this._lang.getString("bounty.confirm_cancel")).clicked.addOnce(function(param1:MouseEvent):void
         {
            btn_submit.enabled = true;
         });
         dlgConfirm.addButton(this._lang.getString("bounty.confirm_ok"),true,{
            "width":180,
            "buttonClass":PurchasePushButton,
            "cost":this._amount
         }).clicked.addOnce(function(param1:MouseEvent):void
         {
            dlgConfirm.close();
            buyBounty();
         });
         dlgConfirm.open();
      }
      
      private function onButtonMouseDown(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_decrease:
               this._amountDir = -this._increment;
               break;
            case this.btn_increase:
               this._amountDir = this._increment;
         }
         this._timer.delay = 250;
         this._timer.reset();
         this._timer.start();
         this.updateAmount(true);
      }
      
      private function onButtonMouseUp(param1:MouseEvent) : void
      {
         this._amountDir = 0;
         this._timer.stop();
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this._timer.delay *= 0.9;
         this.updateAmount();
      }
      
      private function updateAmount(param1:Boolean = false) : void
      {
         if(param1 && this._amount % this._increment != 0)
         {
            if(this._amountDir < 0)
            {
               this._amount = Math.floor(this._amount / this._increment) * this._increment;
            }
            else
            {
               this._amount = Math.ceil(this._amount / this._increment) * this._increment;
            }
         }
         else
         {
            this._amount += this._amountDir;
         }
         this._amount = Math.max(this._minAdd,Math.min(this._maxAdd,this._amount));
         this.txt_amount.text = NumberFormatter.format(this._amount,0);
         this.btn_decrease.enabled = this._amount > this._minAdd;
         this.btn_increase.enabled = this._amount < this._maxAdd;
         this.repositionFuelIcon();
      }
      
      private function onAmountFocusIn(param1:FocusEvent) : void
      {
         this.txt_amount.text = this._amount.toString();
         this.txt_amount.restrict = "0-9";
         this.txt_amount.maxChars = this._maxInputLen;
         this.txt_amount.setSelection(0,this.txt_amount.text.length);
      }
      
      private function onAmountFocusOut(param1:FocusEvent) : void
      {
         this.txt_amount.maxChars = -1;
         this.txt_amount.restrict = null;
         this._amount = int(this.txt_amount.text);
         this._amount = Math.max(this._minAdd,Math.min(this._maxAdd,this._amount));
         this._amountDir = 0;
         this.updateAmount();
      }
      
      private function onAmountChange(param1:Event) : void
      {
         this.repositionFuelIcon();
      }
   }
}

