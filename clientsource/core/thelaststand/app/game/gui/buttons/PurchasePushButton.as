package thelaststand.app.game.gui.buttons
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.geom.Point;
   import thelaststand.app.data.Currency;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.lang.Language;
   
   public class PurchasePushButton extends PushButton
   {
      
      public static const ICON_ALIGN_RIGHT:String = "right";
      
      public static const ICON_ALIGN_LABEL_RIGHT:String = "labelRight";
      
      public static const DEFAULT_COLOR:uint = 4226049;
      
      public static const TOKEN_COLOR:uint = 12726296;
      
      private var _cost:Number = 0;
      
      private var _currency:String = "Coins";
      
      private var _iconAlign:String = "right";
      
      private var bmp_icon:Bitmap;
      
      public function PurchasePushButton(param1:String = "", param2:Number = 0, param3:Boolean = true)
      {
         super(param1,null,-1,{"bold":true},4226049);
         mc_background.mc_innerGlow.alpha = 0.5;
         this._cost = param2;
         this.bmp_icon = new Bitmap();
         this.bmp_icon.filters = [Effects.ICON_SHADOW];
         this.updateCurrencyIcon();
         this.showIcon = param3;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
            this.bmp_icon.bitmapData = null;
         }
         this.bmp_icon.filters = [];
         this.bmp_icon = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function setFromStoreItem(param1:StoreItem) : void
      {
         this._currency = param1.currency;
         this._cost = param1.cost;
         this.updateCurrencyIcon();
         if(stage != null)
         {
            this.updateLabel();
            this.updateTooltip();
         }
      }
      
      public function setFromData(param1:Object) : void
      {
         if(int(param1.PriceCoins) > 0)
         {
            this._currency = Currency.FUEL;
            this._cost = int(param1.PriceCoins);
         }
         else if(param1.PriceTokens != null)
         {
            this._currency = Currency.ALLIANCE_TOKENS;
            this._cost = int(param1.PriceTokens);
         }
         else
         {
            switch(Network.getInstance().service)
            {
               case PlayerIOConnector.SERVICE_FACEBOOK:
               case PlayerIOConnector.SERVICE_ARMOR_GAMES:
               case PlayerIOConnector.SERVICE_PLAYER_IO:
               case PlayerIOConnector.SERVICE_YAHOO:
                  this._currency = Currency.US_DOLLARS;
                  this._cost = Number((int(param1.PriceUSD) / 100).toFixed(2));
                  break;
               case PlayerIOConnector.SERVICE_KONGREGATE:
                  this._currency = Currency.KONGREGATE_KREDS;
                  this._cost = int(param1.PriceKKR);
            }
         }
         this.updateCurrencyIcon();
         if(stage != null)
         {
            this.updateLabel();
            this.updateTooltip();
         }
      }
      
      public function updateTooltip() : void
      {
         if(this._currency == Currency.FUEL && this._cost > 0 && this.showIcon)
         {
            TooltipManager.getInstance().add(this,Language.getInstance().getString("tooltip.spend_fuel",NumberFormatter.format(this._cost,0)),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else if(this._currency == Currency.ALLIANCE_TOKENS && this._cost > 0 && this.showIcon)
         {
            TooltipManager.getInstance().add(this,Language.getInstance().getString("tooltip.spend_alliance_tokens",NumberFormatter.format(this._cost,0)),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else
         {
            TooltipManager.getInstance().remove(this);
         }
      }
      
      private function updateLabel() : void
      {
         var _loc1_:* = "";
         switch(this._currency)
         {
            case Currency.US_DOLLARS:
               _loc1_ = "$" + NumberFormatter.format(this._cost,2,",",false) + " USD";
               break;
            default:
               _loc1_ = NumberFormatter.format(Math.round(this._cost),0);
         }
         var _loc2_:String = _label != null ? _label.toUpperCase() : "";
         if(_loc2_.length > 0 && this.cost > 0)
         {
            _loc2_ += " - " + _loc1_;
         }
         else if(this.cost > 0)
         {
            _loc2_ = _loc1_;
         }
         if(_loc2_.length > 0)
         {
            addChild(txt_label);
            txt_label.text = _loc2_;
         }
         else if(txt_label.parent != null)
         {
            txt_label.parent.removeChild(txt_label);
         }
         if(autoSize)
         {
            setSize(width,height);
         }
         else
         {
            this.positionElements();
         }
      }
      
      override protected function positionElements() : void
      {
         super.positionElements();
         if(this.bmp_icon != null && this.bmp_icon.parent != null && this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.y = int((height - this.bmp_icon.height) * 0.5);
            txt_label.maxWidth = int(width - this.bmp_icon.width - 4);
            switch(this._iconAlign)
            {
               case ICON_ALIGN_LABEL_RIGHT:
                  txt_label.x = int((width - txt_label.width) * 0.5 - 4);
                  this.bmp_icon.x = int(txt_label.x + txt_label.width + 4);
                  break;
               case ICON_ALIGN_RIGHT:
               default:
                  this.bmp_icon.x = int(width - this.bmp_icon.width - 5);
                  txt_label.x = int((this.bmp_icon.x - txt_label.width) * 0.5);
            }
         }
         else
         {
            txt_label.x = int((width - txt_label.width) * 0.5);
            txt_label.maxWidth = int(width - 8);
         }
      }
      
      private function updateCurrencyIcon() : void
      {
         if(this.bmp_icon.bitmapData != null)
         {
            this.bmp_icon.bitmapData.dispose();
            this.bmp_icon.bitmapData = null;
         }
         this.bmp_icon.scaleX = this.bmp_icon.scaleY = 1;
         switch(this._currency)
         {
            case Currency.FUEL:
               this.bmp_icon.bitmapData = new BmpIconFuel();
               break;
            case Currency.FACEBOOK_CREDITS:
               this.bmp_icon.bitmapData = new BmpIconFBCredit();
               break;
            case Currency.KONGREGATE_KREDS:
               this.bmp_icon.bitmapData = new BmpIconKongKreds();
               break;
            case Currency.ALLIANCE_TOKENS:
               this.bmp_icon.bitmapData = new BmpIconAllianceTokensSmall();
               break;
            case Currency.US_DOLLARS:
               this.bmp_icon.bitmapData = null;
         }
         if(this._currency == Currency.ALLIANCE_TOKENS)
         {
            backgroundColor = TOKEN_COLOR;
         }
         else
         {
            backgroundColor = DEFAULT_COLOR;
         }
         this.bmp_icon.smoothing = true;
         this.bmp_icon.pixelSnapping = "auto";
         this.bmp_icon.height = Math.min(this.bmp_icon.height,22);
         this.bmp_icon.scaleX = this.bmp_icon.scaleY;
         this.positionElements();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateLabel();
         this.updateTooltip();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      override public function set enabled(param1:Boolean) : void
      {
         super.enabled = param1;
         if(this.bmp_icon != null)
         {
            this.bmp_icon.alpha = super.enabled ? 1 : 0.5;
         }
      }
      
      public function get cost() : Number
      {
         return this._cost;
      }
      
      public function set cost(param1:Number) : void
      {
         this._cost = param1;
         if(stage != null)
         {
            this.updateLabel();
            this.updateTooltip();
         }
      }
      
      public function get currency() : String
      {
         return this._currency;
      }
      
      public function set currency(param1:String) : void
      {
         this._currency = param1;
         this.updateCurrencyIcon();
         if(stage != null)
         {
            this.updateLabel();
            this.updateTooltip();
         }
      }
      
      public function get iconAlign() : String
      {
         return this._iconAlign;
      }
      
      public function set iconAlign(param1:String) : void
      {
         this._iconAlign = param1;
         this.positionElements();
      }
      
      public function get showIcon() : Boolean
      {
         return this.bmp_icon.parent != null;
      }
      
      public function set showIcon(param1:Boolean) : void
      {
         if(this.bmp_icon.parent == null && param1)
         {
            addChild(this.bmp_icon);
         }
         else if(this.bmp_icon.parent != null && !param1)
         {
            removeChild(this.bmp_icon);
         }
         this.positionElements();
      }
      
      override public function set label(param1:String) : void
      {
         _label = param1;
         if(stage)
         {
            this.updateLabel();
         }
      }
   }
}

