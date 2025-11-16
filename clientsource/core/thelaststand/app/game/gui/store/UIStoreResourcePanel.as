package thelaststand.app.game.gui.store
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.gui.UIUnavailableBanner;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIStoreResourcePanel extends UIComponent
   {
      
      private var _resource:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _panels:Vector.<UIStoreResourcePanelOption>;
      
      private var _optionCosts:Vector.<Object>;
      
      private var _padding:int = 10;
      
      private var _panelPadding:int = 5;
      
      private var _headerPanelHeight:int = 98;
      
      private var mc_panelContainer:Sprite;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var txt_stockTitle:BodyTextField;
      
      private var txt_stock:BodyTextField;
      
      private var ui_resourceImage:UIImage;
      
      private var ui_fullBanner:UIUnavailableBanner;
      
      public function UIStoreResourcePanel(param1:String)
      {
         var i:int;
         var itemType:String = null;
         var panel:UIStoreResourcePanelOption = null;
         var resource:String = param1;
         super();
         this._resource = resource;
         switch(this._resource)
         {
            case GameResources.WOOD:
            case GameResources.METAL:
            case GameResources.CLOTH:
               itemType = "building";
               break;
            case GameResources.FOOD:
            case GameResources.WATER:
               itemType = "foodwater";
               break;
            case GameResources.AMMUNITION:
               itemType = "ammo";
         }
         this._optionCosts = Network.getInstance().data.costTable.getItems("resource_" + itemType);
         this._optionCosts.sort(function(param1:Object, param2:Object):int
         {
            return param2.percent * 100 - param1.percent * 100;
         });
         this._panels = new Vector.<UIStoreResourcePanelOption>(this._optionCosts.length,true);
         this.mc_panelContainer = new Sprite();
         addChild(this.mc_panelContainer);
         i = 0;
         while(i < this._optionCosts.length)
         {
            panel = new UIStoreResourcePanelOption();
            panel.purchaseClicked.add(this.onPurchaseClicked);
            panel.labelAlpha = 0.4 + (1 - 0.4) * (i / 3);
            panel.data = this._optionCosts[i];
            this.mc_panelContainer.addChild(panel);
            this._panels[i] = panel;
            i++;
         }
         this.ui_resourceImage = new UIImage(128,74,0,1,true,Config.xml.store_resources[this._resource.toLowerCase()].hero[0].@uri.toString());
         this.ui_resourceImage.maintainAspectRatio = false;
         addChild(this.ui_resourceImage);
         this.txt_title = new BodyTextField({
            "color":14013909,
            "size":24,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_title.text = Language.getInstance().getString("items." + this._resource).toUpperCase();
         addChild(this.txt_title);
         this.txt_desc = new BodyTextField({
            "color":9671571,
            "size":13,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "multiline":true
         });
         this.txt_desc.text = Language.getInstance().getString("store_res_" + this._resource);
         addChild(this.txt_desc);
         this.txt_stockTitle = new BodyTextField({
            "color":14013909,
            "size":13,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_stockTitle.text = Language.getInstance().getString("store_res_stock").toUpperCase();
         addChild(this.txt_stockTitle);
         this.txt_stock = new BodyTextField({
            "color":14013909,
            "size":20,
            "bold":true,
            "align":"center",
            "autoSize":"center"
         });
         this.txt_stock.text = "0 / 0";
         addChild(this.txt_stock);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get resource() : String
      {
         return this._resource;
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
         var _loc1_:UIStoreResourcePanelOption = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.ui_resourceImage.dispose();
         this.txt_title.dispose();
         this.txt_stock.dispose();
         this.txt_stockTitle.dispose();
         this.txt_desc.dispose();
         for each(_loc1_ in this._panels)
         {
            _loc1_.dispose();
         }
      }
      
      override protected function draw() : void
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:UIStoreResourcePanelOption = null;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.drawHeader();
         this.mc_panelContainer.x = this._padding;
         this.mc_panelContainer.y = this._padding + this._headerPanelHeight + this._panelPadding;
         var _loc1_:int = 0;
         var _loc2_:int = this._height - this.mc_panelContainer.y - this._padding;
         _loc3_ = (_loc2_ - this._panelPadding * (this._panels.length - 1)) / this._panels.length;
         var _loc4_:int = this._width - this._padding * 2;
         var _loc5_:int = 0;
         while(_loc5_ < this._panels.length)
         {
            _loc6_ = this._optionCosts[_loc5_];
            _loc7_ = this._panels[_loc5_];
            _loc7_.width = _loc4_;
            _loc7_.height = _loc3_;
            _loc7_.x = 0;
            _loc7_.y = _loc1_;
            _loc1_ += int(_loc3_ + this._panelPadding);
            _loc5_++;
         }
         this.updatePanels();
      }
      
      private function drawHeader() : void
      {
         var _loc1_:int = 2;
         var _loc2_:int = this._padding;
         var _loc3_:int = this._padding;
         graphics.beginFill(1315860);
         graphics.drawRect(_loc2_,_loc3_,this._width - this._padding * 2,this._headerPanelHeight);
         graphics.endFill();
         this.ui_resourceImage.y = _loc3_ + int((this._headerPanelHeight - this.ui_resourceImage.height) * 0.5);
         this.ui_resourceImage.x = int(this.ui_resourceImage.y);
         graphics.beginFill(2302755);
         graphics.drawRect(this.ui_resourceImage.x - _loc1_,this.ui_resourceImage.y - _loc1_,this.ui_resourceImage.width + _loc1_ * 2,this.ui_resourceImage.height + _loc1_ * 2);
         graphics.endFill();
         var _loc4_:int = 118;
         var _loc5_:int = 50;
         var _loc6_:int = int(this._width - _loc4_ - this._padding * 2);
         var _loc7_:int = this._padding + int(this._headerPanelHeight - this._padding - _loc5_ - _loc1_);
         graphics.beginFill(2302755);
         graphics.drawRect(_loc6_,_loc7_,_loc4_,_loc5_);
         graphics.endFill();
         graphics.beginFill(0);
         graphics.drawRect(_loc6_ + _loc1_,_loc7_ + _loc1_,_loc4_ - _loc1_ * 2,_loc5_ - _loc1_ * 2);
         graphics.endFill();
         this.txt_stockTitle.x = _loc6_ + int((_loc4_ - this.txt_stockTitle.width) * 0.5);
         this.txt_stockTitle.y = this._padding - int((this._headerPanelHeight - _loc7_ - _loc5_ - this.txt_stockTitle.height) * 0.5) + 6;
         this.txt_stock.text = " ";
         this.txt_stock.x = int(_loc6_ + _loc4_ * 0.5 - 2);
         this.txt_stock.y = int(_loc7_ + (_loc5_ - this.txt_stock.height) * 0.5);
         this.txt_stock.maxWidth = int(_loc4_ - _loc1_ * 2);
         var _loc8_:int = int(this.ui_resourceImage.x + this.ui_resourceImage.width + 10);
         var _loc9_:int = int(this.ui_resourceImage.y);
         var _loc10_:int = int(_loc6_ - _loc8_ - 6);
         var _loc11_:int = 34;
         var _loc12_:Matrix = new Matrix();
         _loc12_.createGradientBox(_loc10_,_loc11_,0,_loc8_,_loc9_);
         var _loc13_:uint = uint(GameResources.RESOURCE_COLORS[this._resource]);
         graphics.beginGradientFill("linear",[_loc13_,_loc13_],[0.4,0],[0,255],_loc12_);
         graphics.drawRect(_loc8_,_loc9_,_loc10_,_loc11_);
         graphics.endFill();
         this.txt_title.x = int(_loc8_ + 6);
         this.txt_title.y = int(_loc9_ + (_loc11_ - this.txt_title.height) * 0.5);
         this.txt_desc.x = _loc8_;
         this.txt_desc.y = int(_loc9_ + _loc11_ + 6);
         this.txt_desc.width = int(_loc6_ - this.txt_desc.x - 2);
         this.updateStockCount();
      }
      
      private function updateStockCount() : void
      {
         var _loc1_:Network = Network.getInstance();
         var _loc2_:Number = _loc1_.playerData.compound.resources.getAmount(this._resource);
         var _loc3_:Number = _loc1_.playerData.compound.resources.getTotalStorageCapacity(this._resource);
         this.txt_stock.text = NumberFormatter.format(_loc2_,0) + " / " + NumberFormatter.format(_loc3_,0);
         this.txt_stock.textColor = _loc2_ <= 0 ? Effects.COLOR_WARNING : 14013909;
      }
      
      private function updatePanels() : void
      {
         var _loc7_:Object = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:uint = 0;
         var _loc11_:UIStoreResourcePanelOption = null;
         var _loc1_:Network = Network.getInstance();
         var _loc2_:Number = _loc1_.playerData.compound.resources.getAmount(this._resource);
         var _loc3_:Number = _loc1_.playerData.compound.resources.getTotalStorageCapacity(this._resource);
         var _loc4_:Number = _loc1_.playerData.compound.resources.getAvailableStorageCapacity(this._resource);
         var _loc5_:int = 0;
         var _loc6_:int = int(this._panels.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = this._optionCosts[_loc5_];
            _loc8_ = Number(_loc7_.percent);
            _loc9_ = _loc8_ >= 1 ? _loc4_ : Math.floor(_loc3_ * _loc8_);
            _loc10_ = _loc9_ > _loc4_ ? 0 : uint(Math.ceil(_loc7_.costPerUnit * _loc9_));
            _loc11_ = this._panels[_loc5_];
            _loc11_.cost = _loc10_;
            _loc11_.fillPercentage = _loc8_;
            _loc11_.imageURI = Config.xml.store_resources[this._resource.toLowerCase()].img[_loc5_].@uri.toString();
            _loc11_.label = _loc10_ > 0 ? "+" + NumberFormatter.format(_loc9_,0) + " " + Language.getInstance().getString("items." + this._resource) : Language.getInstance().getString("store_res_na");
            _loc11_.labelAlpha = 0.4 + (1 - 0.4) * ((_loc6_ - _loc5_) / _loc6_);
            if(isInvalid)
            {
               _loc11_.redraw();
            }
            _loc5_++;
         }
         if(_loc4_ == 0)
         {
            this.mc_panelContainer.filters = [Effects.GREYSCALE.filter];
            this.mc_panelContainer.alpha = 0.5;
            if(this.ui_fullBanner == null)
            {
               this.ui_fullBanner = new UIUnavailableBanner();
            }
            this.ui_fullBanner.width = this._width;
            this.ui_fullBanner.height = 90;
            this.ui_fullBanner.x = 0;
            this.ui_fullBanner.y = int(this.mc_panelContainer.y + (this.mc_panelContainer.height - this.ui_fullBanner.height) * 0.5);
            this.ui_fullBanner.title = Language.getInstance().getString("store_res_full");
            this.ui_fullBanner.message = Language.getInstance().getString("store_res_full_msg");
            addChild(this.ui_fullBanner);
         }
         else
         {
            this.mc_panelContainer.filters = [];
            this.mc_panelContainer.cacheAsBitmap = false;
            this.mc_panelContainer.alpha = 1;
            if(this.ui_fullBanner != null && this.ui_fullBanner.parent != null)
            {
               this.ui_fullBanner.parent.removeChild(this.ui_fullBanner);
            }
         }
      }
      
      private function onResourceValueChanged(param1:String, param2:Number) : void
      {
         if(param1 == this._resource)
         {
            this.updatePanels();
            this.updateStockCount();
         }
      }
      
      private function onResourceCapacityChanged(param1:String) : void
      {
         if(param1 == this._resource)
         {
            this.updatePanels();
            this.updateStockCount();
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updatePanels();
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceValueChanged);
         Network.getInstance().playerData.compound.resources.storageCapacityChanged.add(this.onResourceCapacityChanged);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceValueChanged);
         Network.getInstance().playerData.compound.resources.storageCapacityChanged.remove(this.onResourceCapacityChanged);
      }
      
      private function onPurchaseClicked(param1:Object) : void
      {
         var option:Object = param1;
         if(Network.getInstance().isBusy)
         {
            return;
         }
         PaymentSystem.getInstance().buyResource(this._resource,option.key,function(param1:Boolean):void
         {
            if(param1)
            {
               updatePanels();
               updateStockCount();
            }
         });
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import org.osflash.signals.Signal;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.gui.buttons.PurchasePushButton;
import thelaststand.app.gui.UIComponent;
import thelaststand.app.gui.UIImage;
import thelaststand.common.lang.Language;

class UIStoreResourcePanelOption extends UIComponent
{
   
   private var _width:int;
   
   private var _height:int;
   
   private var _imageURI:String;
   
   private var _label:String;
   
   private var _fillPercentage:Number = 0;
   
   private var _cost:Number = 0;
   
   private var _labelAlpha:Number = 1;
   
   private var ui_image:UIImage;
   
   private var btn_buy:PurchasePushButton;
   
   private var txt_fillPerc:BodyTextField;
   
   private var txt_label:BodyTextField;
   
   public var purchaseClicked:Signal = new Signal(Object);
   
   public function UIStoreResourcePanelOption()
   {
      super();
      this.ui_image = new UIImage(48,48,0,1,false);
      this.ui_image.filters = [new GlowFilter(8816262,1,4,4,10,1)];
      addChild(this.ui_image);
      this.btn_buy = new PurchasePushButton(null);
      this.btn_buy.clicked.add(this.onClickPurchase);
      this.btn_buy.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
      this.btn_buy.width = 92;
      addChild(this.btn_buy);
      this.txt_fillPerc = new BodyTextField({
         "color":14399507,
         "size":18,
         "bold":true,
         "filters":[Effects.STROKE]
      });
      addChild(this.txt_fillPerc);
      this.txt_label = new BodyTextField({
         "color":12105912,
         "size":18,
         "bold":true,
         "filters":[Effects.STROKE],
         "align":"right",
         "autoSize":"right"
      });
      addChild(this.txt_label);
   }
   
   public function get cost() : Number
   {
      return this._cost;
   }
   
   public function set cost(param1:Number) : void
   {
      if(param1 < 0)
      {
         param1 = 0;
      }
      this._cost = param1;
      invalidate();
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
      invalidate();
   }
   
   public function get labelAlpha() : Number
   {
      return this._labelAlpha;
   }
   
   public function set labelAlpha(param1:Number) : void
   {
      if(param1 < 0)
      {
         param1 = 0;
      }
      else if(param1 > 1)
      {
         param1 = 1;
      }
      this._labelAlpha = param1;
      invalidate();
   }
   
   public function get fillPercentage() : Number
   {
      return this._fillPercentage;
   }
   
   public function set fillPercentage(param1:Number) : void
   {
      if(param1 < 0)
      {
         param1 = 0;
      }
      else if(param1 > 1)
      {
         param1 = 1;
      }
      this._fillPercentage = param1;
      invalidate();
   }
   
   public function get imageURI() : String
   {
      return this._imageURI;
   }
   
   public function set imageURI(param1:String) : void
   {
      this._imageURI = param1;
      invalidate();
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
      super.dispose();
      this.ui_image.dispose();
      this.btn_buy.dispose();
      this.txt_fillPerc.dispose();
      this.txt_label.dispose();
      this.purchaseClicked.removeAll();
   }
   
   override protected function draw() : void
   {
      graphics.clear();
      graphics.beginFill(1315860);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      this.ui_image.uri = this._imageURI;
      this.ui_image.y = int((this._height - this.ui_image.height) * 0.5);
      this.ui_image.x = this.ui_image.y;
      this.btn_buy.cost = this.cost;
      this.btn_buy.y = int((this._height - this.btn_buy.height) * 0.5);
      this.btn_buy.x = int(this._width - this.btn_buy.width - this.btn_buy.y);
      this.btn_buy.enabled = this.cost > 0;
      this.btn_buy.showIcon = this.cost > 0;
      if(this._fillPercentage == 1)
      {
         this.txt_fillPerc.text = Language.getInstance().getString("store_res_fill").toUpperCase();
      }
      else
      {
         this.txt_fillPerc.text = "+" + NumberFormatter.format(this._fillPercentage * 100,2,",",false) + "%";
      }
      this.txt_fillPerc.alpha = this._labelAlpha;
      this.txt_fillPerc.x = int(this.ui_image.x + this.ui_image.width + 20);
      this.txt_fillPerc.y = int((this._height - this.txt_fillPerc.height) * 0.5);
      this.txt_label.alpha = this._labelAlpha;
      this.txt_label.text = this._label.toUpperCase();
      this.txt_label.x = int(this.btn_buy.x - this.txt_label.width - 40);
      this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
   }
   
   private function onClickPurchase(param1:MouseEvent) : void
   {
      this.purchaseClicked.dispatch(data);
   }
}
