package thelaststand.app.game.gui.injury
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.game.gui.buttons.UICraftBuyButtons;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIInputItem extends UIComponent
   {
      
      private var _width:int = 128;
      
      private var _height:int = 36;
      
      private var _item:Item;
      
      private var _label:String;
      
      private var bmp_input:Bitmap;
      
      private var ui_image:UIItemImage;
      
      private var mc_border:Shape;
      
      private var btn_getOptions:UICraftBuyButtons;
      
      private var txt_itemType:BodyTextField;
      
      private var mc_hitArea:Sprite;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public function UIInputItem()
      {
         super();
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(0,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.mc_border = new Shape();
         this.mc_border.graphics.beginFill(4276545);
         this.mc_border.graphics.drawRect(0,0,this._height,this._height);
         this.mc_border.graphics.endFill();
         addChild(this.mc_border);
         this.bmp_input = new Bitmap(new BmpItemInputBG());
         this.bmp_input.x = this.bmp_input.y = 2;
         this.ui_image = new UIItemImage(32,32);
         this.ui_image.x = this.ui_image.y = 2;
         this.ui_image.showQuantity = false;
         this.ui_image.mouseEnabled = false;
         this.btn_getOptions = new UICraftBuyButtons();
         this.txt_itemType = new BodyTextField({
            "color":12434877,
            "size":11,
            "bold":true,
            "multiline":true,
            "filters":[Effects.STROKE]
         });
         this.txt_itemType.mouseEnabled = false;
         addChild(this.txt_itemType);
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         if(param1 == this._label)
         {
            return;
         }
         this._label = param1;
         invalidate();
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function set item(param1:Item) : void
      {
         if(param1 == this._item)
         {
            return;
         }
         this._item = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp_input.bitmapData.dispose();
         this.ui_image.dispose();
         this.txt_itemType.dispose();
         this.clicked.removeAll();
         this.mouseOver.removeAll();
      }
      
      public function getBuyCraftOptions() : UICraftBuyButtons
      {
         return this.btn_getOptions;
      }
      
      override protected function draw() : void
      {
         if(this.btn_getOptions.parent != null)
         {
            this.btn_getOptions.parent.removeChild(this.btn_getOptions);
         }
         this.mc_hitArea.width = this._width;
         this.mc_hitArea.height = this._height;
         var _loc1_:ColorTransform = new ColorTransform();
         if(this._item == null)
         {
            if(this.ui_image.parent != null)
            {
               this.ui_image.parent.removeChild(this.ui_image);
            }
            this.ui_image.item = null;
            addChild(this.bmp_input);
            this.btn_getOptions.x = int(this.ui_image.x + this.ui_image.width + 2);
            this.btn_getOptions.y = int(this.ui_image.y + (this.ui_image.height - this.btn_getOptions.height) * 0.5);
            addChild(this.btn_getOptions);
            this.txt_itemType.htmlText = (this._label || "").toUpperCase();
            this.txt_itemType.x = int(this.btn_getOptions.x + this.btn_getOptions.width + 4);
            this.txt_itemType.textColor = 14550272;
            _loc1_.color = 14550272;
         }
         else
         {
            if(this.bmp_input.parent != null)
            {
               this.bmp_input.parent.removeChild(this.bmp_input);
            }
            this.ui_image.item = this._item;
            addChild(this.ui_image);
            this.txt_itemType.textColor = Effects.COLOR_NEUTRAL;
            this.txt_itemType.text = Language.getInstance().getString("items." + this._item.type).toUpperCase();
            this.txt_itemType.x = int(this.ui_image.x + this.ui_image.width + 6);
            _loc1_.color = new Color(Effects["COLOR_" + ItemQualityType.getName(this._item.qualityType)]).tint(0,0.5).RGB;
         }
         this.txt_itemType.width = int(this._width - this.txt_itemType.x);
         this.txt_itemType.y = int(this.ui_image.y + (this.ui_image.height - this.txt_itemType.height) * 0.5);
         this.mc_border.transform.colorTransform = _loc1_;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this,0.25,{"colorTransform":{"exposure":1.1}});
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this,0.25,{"colorTransform":{"exposure":1}});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
      }
   }
}

