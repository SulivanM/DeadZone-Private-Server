package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFormatAlign;
   import thelaststand.app.data.PlayerUpgrades;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.UIIconButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UpgradeCarDialogue extends BaseDialogue
   {
      
      public static var upgradeRename:String;
      
      private const NAMES_URI:String = "xml/vehiclenames.xml";
      
      private var _lang:Language;
      
      private var _buyInfo:Object;
      
      private var _names:XML;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_buy:PurchasePushButton;
      
      private var btn_random:UIIconButton;
      
      private var txt_desc:BodyTextField;
      
      private var ui_image:UIImage;
      
      private var ui_input:UIInputField;
      
      public function UpgradeCarDialogue()
      {
         super("upgrade-car",this.mc_container,true);
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = 548;
         _height = 278;
         var _loc1_:Resource = ResourceManager.getInstance().getResource(this.NAMES_URI);
         if(_loc1_ == null)
         {
            this._names = null;
            ResourceManager.getInstance().load(this.NAMES_URI,{"onComplete":this.onNamesLoaded});
         }
         else
         {
            this._names = _loc1_.content as XML;
         }
         addTitle(this._lang.getString("upgrade_car_title"),BaseDialogue.TITLE_COLOR_BUY);
         var _loc2_:int = _padding * 0.5;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,286,238,0,_loc2_);
         this.ui_image = new UIImage(284,236);
         this.ui_image.uri = "images/ui/buy-car.jpg";
         this.ui_image.x = 1;
         this.ui_image.y = _loc2_ + 1;
         this.mc_container.addChild(this.ui_image);
         this.txt_desc = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true
         });
         this.txt_desc.htmlText = StringUtils.htmlSetDoubleBreakLeading(this._lang.getString("upgrade_car_desc"));
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.txt_desc.x = int(this.ui_image.x + this.ui_image.width + 8);
         this.txt_desc.y = int(this.ui_image.y);
         this.txt_desc.width = int(_width - this.txt_desc.x - _padding * 2);
         this.mc_container.addChild(this.txt_desc);
         this.ui_input = new UIInputField({
            "color":16777215,
            "size":20,
            "align":TextFormatAlign.CENTER
         });
         this.ui_input.textField.addEventListener(Event.CHANGE,this.onNameChanged,false,0,true);
         this.ui_input.textField.restrict = "a-zA-Z0-9 ";
         this.ui_input.textField.maxChars = 22;
         this.ui_input.value = this._lang.getString("blds.car");
         this.ui_input.width = int(this.txt_desc.width - 4);
         this.ui_input.height = 34;
         this.ui_input.x = int(this.txt_desc.x + 2);
         this.ui_input.y = int(this.txt_desc.y + this.txt_desc.height + 6);
         this.mc_container.addChild(this.ui_input);
         this.btn_random = new UIIconButton(new BmpIconRecycle());
         this.btn_random.addEventListener(MouseEvent.CLICK,this.onClickRandom,false,0,true);
         this.btn_random.enabled = this._names != null;
         this.btn_random.x = int(this.ui_input.x + this.ui_input.width - this.btn_random.width - 8);
         this.btn_random.y = int(this.ui_input.y + (this.ui_input.height - this.btn_random.height) * 0.5);
         this.mc_container.addChild(this.btn_random);
         this.btn_buy = new PurchasePushButton(this._lang.getString("upgrade_car_buy2"),0,true);
         this.btn_buy.clicked.add(this.onClickBuy);
         this.btn_buy.enabled = false;
         this.btn_buy.width = 194;
         this.btn_buy.x = int(this.ui_input.x + (this.ui_input.width - this.btn_buy.width) * 0.5);
         this.btn_buy.y = int(this.ui_image.y + this.ui_image.height - this.btn_buy.height - 4);
         var _loc3_:String = PlayerUpgrades.getName(PlayerUpgrades.DeathMobileUpgrade);
         var _loc4_:Object = Network.getInstance().data.costTable.getItemByKey(_loc3_);
         this.btn_buy.setFromData(_loc4_);
         this.mc_container.addChild(this.btn_buy);
         TooltipManager.getInstance().add(this.btn_random,Language.getInstance().getString("tooltip.randomize"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         if(ResourceManager.getInstance().isInQueue(this.NAMES_URI))
         {
            ResourceManager.getInstance().purge(this.NAMES_URI);
         }
         super.dispose();
         this.btn_buy.dispose();
         this.txt_desc.dispose();
         this.ui_image.dispose();
         this.btn_random.dispose();
         this._names = null;
      }
      
      override public function open() : void
      {
         var itemKey:String;
         super.open();
         itemKey = PlayerUpgrades.getName(PlayerUpgrades.DeathMobileUpgrade);
         PaymentSystem.getInstance().getBuyItemDirectData(itemKey,null,function(param1:Object):void
         {
            _buyInfo = param1;
            btn_buy.enabled = true;
         });
      }
      
      private function generateRandomName() : String
      {
         if(this._names == null)
         {
            return "";
         }
         var _loc1_:XMLList = this._names.first.n;
         var _loc2_:XMLList = this._names.last.n;
         var _loc3_:String = _loc1_[int(Math.random() * _loc1_.length())].toString();
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         if(_loc3_.substr(_loc3_.length - 1) == "%")
         {
            _loc3_ = _loc3_.substr(0,_loc3_.length - 1);
            _loc5_ = false;
            while(!_loc4_)
            {
               _loc4_ = _loc2_[int(Math.random() * _loc1_.length())].toString();
               if(_loc4_.substr(0,1) == "%")
               {
                  _loc4_ = null;
               }
            }
         }
         else
         {
            _loc4_ = _loc2_[int(Math.random() * _loc2_.length())].toString();
            if(_loc4_.substr(0,1) == "%")
            {
               _loc4_ = _loc4_.substr(1,_loc4_.length);
               _loc5_ = true;
            }
         }
         return _loc3_ + (_loc5_ ? "" : " ") + _loc4_;
      }
      
      private function onNamesLoaded() : void
      {
         this._names = ResourceManager.getInstance().getResource(this.NAMES_URI).content;
         this.btn_random.enabled = true;
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         var itemKey:String;
         var e:MouseEvent = param1;
         this.btn_buy.enabled = false;
         upgradeRename = this.ui_input.value;
         itemKey = PlayerUpgrades.getName(PlayerUpgrades.DeathMobileUpgrade);
         PaymentSystem.getInstance().buyDirectItem(itemKey,this._buyInfo,null,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
      
      private function onClickRandom(param1:MouseEvent) : void
      {
         this.ui_input.value = this.generateRandomName();
         this.btn_buy.enabled = this.ui_input.value.length > 0;
      }
      
      private function onNameChanged(param1:Event) : void
      {
         this.btn_buy.enabled = this._buyInfo != null && this.ui_input.value.length > 0;
      }
   }
}

