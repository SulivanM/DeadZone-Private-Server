package thelaststand.app.game.gui.store
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.iteminfo.UIItemTitle;
   import thelaststand.app.game.gui.survivor.UISurvivorModelView;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UISpinner;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIStoreClothingPreview extends UIComponent
   {
      
      private static var _survivor:Survivor;
      
      private var _width:int = 208;
      
      private var _height:int = 382;
      
      private var _storeItem:StoreItem;
      
      private var _item:ClothingAccessory;
      
      private var ui_model:UISurvivorModelView;
      
      private var ui_title:UIItemTitle;
      
      private var ui_survivorList:UISpinner;
      
      private var btn_buy:PurchasePushButton;
      
      private var txt_preview:BodyTextField;
      
      public function UIStoreClothingPreview()
      {
         var _loc3_:Survivor = null;
         super();
         this.ui_model = new UISurvivorModelView(this._width,this.height);
         addChild(this.ui_model);
         this.ui_title = new UIItemTitle();
         this.ui_title.showLevel = this.ui_title.showType = false;
         addChild(this.ui_title);
         this.txt_preview = new BodyTextField({
            "color":7434609,
            "size":13,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_preview.text = Language.getInstance().getString("store_clothing_preview");
         addChild(this.txt_preview);
         this.ui_survivorList = new UISpinner();
         this.ui_survivorList.showBorder = false;
         this.ui_survivorList.backgroundColor = 1184274;
         this.ui_survivorList.height = 30;
         this.ui_survivorList.changed.add(this.onSurvivorChanged);
         addChild(this.ui_survivorList);
         var _loc1_:SurvivorCollection = Network.getInstance().playerData.compound.survivors;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_.getSurvivor(_loc2_);
            this.ui_survivorList.addItem(_loc3_.fullName,_loc3_.id);
            _loc2_++;
         }
         this.btn_buy = new PurchasePushButton();
         this.btn_buy.clicked.add(this.onClickBuy);
         this.btn_buy.enabled = false;
         this.btn_buy.showIcon = true;
         this.btn_buy.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         addChild(this.btn_buy);
         if(_survivor == null)
         {
            this.setSurvivor(Network.getInstance().playerData.getPlayerSurvivor());
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_model.dispose();
         this.ui_title.dispose();
         this.ui_survivorList.dispose();
         this.btn_buy.dispose();
         this.txt_preview.dispose();
         TooltipManager.getInstance().removeAllFromParent(this);
         this._item = null;
         _survivor = null;
      }
      
      public function setItem(param1:StoreItem) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Vector.<AttireData> = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this._storeItem = param1;
         this.ui_model.appearance.clearAccessories();
         if(this._storeItem != null)
         {
            this._item = ClothingAccessory(this._storeItem.item);
            this.ui_title.setItem(this._item);
            _loc2_ = this._item.supportsSurvivorClass(_survivor.classId);
            if(_loc2_)
            {
               _loc3_ = this._item.getAttireList(_survivor.gender);
               _loc4_ = 0;
               _loc5_ = int(_loc3_.length);
               while(_loc4_ < _loc5_)
               {
                  this.ui_model.appearance.addAccessory(_loc3_[_loc4_]);
                  _loc4_++;
               }
               TooltipManager.getInstance().remove(this.ui_survivorList);
               TooltipManager.getInstance().hide();
            }
            else
            {
               TooltipManager.getInstance().add(this.ui_survivorList,Language.getInstance().getString("store_clothing_unsupported"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               TooltipManager.getInstance().show(this.ui_survivorList);
            }
            this.btn_buy.enabled = _loc2_;
            this.btn_buy.showIcon = true;
            this.btn_buy.label = Language.getInstance().getString("store_clothing_buy");
            this.btn_buy.setFromStoreItem(this._storeItem);
            this.ui_survivorList.labelColor = _loc2_ ? 16777215 : Effects.COLOR_WARNING;
            this.btn_buy.transform.colorTransform = Effects.CT_DEFAULT;
            TweenMax.from(this.btn_buy,0.5,{
               "colorTransform":{"exposure":1.5},
               "ease":Quad.easeOut
            });
         }
         else
         {
            this._item = null;
            this.btn_buy.enabled = false;
            this.btn_buy.showIcon = false;
            this.btn_buy.cost = 0;
         }
         this.ui_model.update();
      }
      
      public function setSurvivor(param1:Survivor) : void
      {
         if(_survivor == param1)
         {
            return;
         }
         _survivor = param1;
         this.ui_model.survivor = _survivor;
         this.ui_model.appearance = _survivor.appearance.clone();
         this.ui_model.appearance.clearAccessories();
         this.ui_survivorList.selectItemByData(_survivor.id);
         this.setItem(this._storeItem);
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_title.x = this.ui_title.y = 4;
         this.ui_title.width = int(this._width - this.ui_title.x * 2);
         this.ui_title.height = 28;
         this.btn_buy.x = 14;
         this.btn_buy.y = int(this._height - this.btn_buy.height - 14);
         this.btn_buy.width = int(this._width - this.btn_buy.x * 2);
         this.ui_survivorList.x = 10;
         this.ui_survivorList.y = int(this.btn_buy.y - this.ui_survivorList.height - 14);
         this.ui_survivorList.width = int(this._width - this.ui_survivorList.x * 2);
         this.txt_preview.x = int(this.ui_survivorList.x + (this.ui_survivorList.width - this.txt_preview.width) * 0.5);
         this.txt_preview.y = int(this.ui_survivorList.y - this.txt_preview.height - 2);
         this.ui_model.x = 1;
         this.ui_model.y = int(this.ui_title.y + this.ui_title.height + 2);
         this.ui_model.height = int(this.ui_survivorList.y * 0.85);
         this.ui_model.width = int(this._width - this.ui_model.x * 2);
         this.ui_model.actorMesh.scaleX = this.ui_model.actorMesh.scaleY = this.ui_model.actorMesh.scaleZ = 1.2;
         this.ui_model.updateCamera();
      }
      
      private function onSurvivorChanged() : void
      {
         var _loc1_:Survivor = Network.getInstance().playerData.compound.survivors.getSurvivorById(this.ui_survivorList.selectedData);
         if(_loc1_ != null)
         {
            this.setSurvivor(_loc1_);
         }
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         PaymentSystem.getInstance().buyStoreItem(this._storeItem);
      }
   }
}

