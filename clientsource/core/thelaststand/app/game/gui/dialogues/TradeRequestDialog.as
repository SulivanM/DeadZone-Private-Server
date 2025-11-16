package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.TextFormatAlign;
   import flash.utils.clearInterval;
   import flash.utils.setInterval;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.logic.TradeSystem;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class TradeRequestDialog extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _network:Network;
      
      private var _trade:TradeSystem;
      
      private var mc_container:Sprite = new Sprite();
      
      private var txt_requestingTrade:BodyTextField;
      
      private var txt_tradeNickName:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var ui_image:UIImage;
      
      private var timerContainer:Sprite;
      
      private var mc_iconTime:Sprite;
      
      private var intervalId:uint;
      
      private var tradeNickName:String;
      
      private var expireTime:Number;
      
      public function TradeRequestDialog(param1:String, param2:Number)
      {
         super("tradeRequestDialog",this.mc_container);
         this.tradeNickName = param1;
         this.expireTime = param2;
         this._lang = Language.getInstance();
         this._network = Network.getInstance();
         this._trade = TradeSystem.getInstance();
         this._trade.onTradeRequestResponse.add(this.onTradeRequestResponse);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = 6;
         addTitle(this._lang.getString("trade.requestingTradeTitle"),BaseDialogue.TITLE_COLOR_GREY);
         var _loc3_:Bitmap = new Bitmap(new BmpIconButtonClose());
         addButton(this._lang.getString("trade.cancel_button"),true,{
            "width":150,
            "iconBackgroundColor":8731425,
            "icon":_loc3_
         }).clicked.add(this.cancelTradeRequest);
         var _loc4_:int = int(_padding * 0.5);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,172,146,-1,_loc4_);
         this.ui_image = new UIImage(170,144);
         this.ui_image.uri = "images/ui/trade-largeIcon.jpg";
         this.ui_image.y = _loc4_ + 1;
         this.mc_container.addChild(this.ui_image);
         this.txt_requestingTrade = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true,
            "align":TextFormatAlign.CENTER,
            "width":this.ui_image.width,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_requestingTrade.htmlText = this._lang.getString("trade.requestingTradePrefix");
         this.txt_requestingTrade.x = int(this.ui_image.x);
         this.txt_requestingTrade.y = int(this.ui_image.y + this.ui_image.height) + 4;
         this.mc_container.addChild(this.txt_requestingTrade);
         this.txt_tradeNickName = new BodyTextField({
            "color":Effects.COLOR_GOOD,
            "size":16,
            "bold":true,
            "multiline":true,
            "align":TextFormatAlign.CENTER,
            "width":this.ui_image.width,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_tradeNickName.text = param1;
         this.txt_tradeNickName.x = int(this.ui_image.x);
         this.txt_tradeNickName.y = int(this.txt_requestingTrade.y + this.txt_requestingTrade.height) - 1;
         this.mc_container.addChild(this.txt_tradeNickName);
         this.timerContainer = new Sprite();
         this.timerContainer.x = int(this.ui_image.x);
         this.timerContainer.y = int(this.txt_tradeNickName.y + this.txt_tradeNickName.height) + 4;
         this.mc_container.addChild(this.timerContainer);
         this.mc_iconTime = new IconTime();
         this.timerContainer.addChild(this.mc_iconTime);
         this.txt_time = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":false,
            "align":TextFormatAlign.LEFT,
            "autoSize":"left",
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_time.text = "time here";
         this.txt_time.x = int(this.mc_iconTime.width + 4);
         this.txt_time.y = -1;
         this.timerContainer.addChild(this.txt_time);
         this.updateTimeDisplay();
         this.intervalId = setInterval(this.updateTimeDisplay,500);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_requestingTrade.dispose();
         this.txt_time.dispose();
         this.txt_tradeNickName.dispose();
         this.ui_image.dispose();
         this._lang = null;
         this._network = null;
         this._trade.onTradeRequestResponse.remove(this.onTradeRequestResponse);
         this._trade = null;
         clearInterval(this.intervalId);
         TweenMax.killDelayedCallsTo(close);
      }
      
      private function updateTimeDisplay() : void
      {
         var _loc1_:Number = this.expireTime - this._network.serverTime;
         if(_loc1_ < 0)
         {
            this.showExpiredMessage(this._lang.getString("trade.requestExpired"));
         }
         else
         {
            this.txt_time.text = DateTimeUtils.secondsToString(_loc1_ / 1000,false,true);
            this.timerContainer.x = this.ui_image.x + (this.ui_image.width - this.timerContainer.width) * 0.5;
         }
      }
      
      private function showExpiredMessage(param1:String) : void
      {
         clearInterval(this.intervalId);
         this.txt_time.textColor = Effects.COLOR_WARNING;
         this.txt_time.text = param1;
         this.timerContainer.x = this.ui_image.x + (this.ui_image.width - this.timerContainer.width) * 0.5;
         this.mc_iconTime.visible = false;
         this.timerContainer.x -= this.mc_iconTime.width * 0.5;
         TradeSystem.getInstance().closeCurrentTrade(TradeSystem.CANCEL_TRADE_OFFER_EXPIRED);
         TweenMax.delayedCall(5,close);
      }
      
      private function cancelTradeRequest(param1:Event = null) : void
      {
         TradeSystem.getInstance().closeCurrentTrade(TradeSystem.CANCEL_REQUEST_CANCELED);
      }
      
      private function onTradeRequestResponse(param1:String, param2:Boolean, param3:int) : void
      {
         if(param1 != this.tradeNickName)
         {
            return;
         }
         if(param2 == true)
         {
            close();
            return;
         }
         var _loc4_:String = "trade.requestDeclined";
         switch(param3)
         {
            case TradeSystem.CANCEL_TRADING_WITH_SOMEONE_ELSE:
            case TradeSystem.CANCEL_TRADING_WITH_THIS_PERSON:
            case TradeSystem.CANCEL_THEYRE_BUSY:
               _loc4_ = "trade.requestBusy";
               break;
            case TradeSystem.CANCEL_OTHER_PERSON_OFFLINE:
               _loc4_ = "trade.requestNotOnline";
               break;
            case TradeSystem.CANCEL_OUTSIDE_RANGE:
               _loc4_ = "trade.requestOutsideRange";
         }
         this.showExpiredMessage(this._lang.getString(_loc4_));
      }
   }
}

