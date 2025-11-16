package thelaststand.app.game.gui.crafting
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.game.gui.buttons.UICraftBuyButtons;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UICraftKitInput extends UIComponent
   {
      
      private var _width:int = 131;
      
      private var _height:int = 61;
      
      private var _item:Item;
      
      private var _label:String;
      
      private var bmp_background:Bitmap;
      
      private var bmp_input:Bitmap;
      
      private var ui_image:UIItemImage;
      
      private var mc_border:Shape;
      
      private var btn_getOptions:UICraftBuyButtons;
      
      private var txt_title:BodyTextField;
      
      private var txt_itemType:BodyTextField;
      
      private var mc_hitArea:Sprite;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public function UICraftKitInput()
      {
         super();
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.bmp_background = new Bitmap(new BmpCraftKitAreaBG());
         addChild(this.bmp_background);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(0,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.bmp_input = new Bitmap(new BmpItemInputBG());
         this.bmp_input.x = 10;
         this.bmp_input.y = 21;
         this.ui_image = new UIItemImage(32,32);
         this.ui_image.x = this.bmp_input.x;
         this.ui_image.y = this.bmp_input.y;
         this.ui_image.showQuantity = false;
         this.ui_image.mouseEnabled = false;
         this.mc_border = new Shape();
         this.mc_border.graphics.beginFill(9417759);
         this.mc_border.graphics.drawRect(this.ui_image.x - 2,this.ui_image.y - 2,this.ui_image.width + 4,this.ui_image.height + 4);
         this.mc_border.graphics.endFill();
         addChild(this.mc_border);
         this.btn_getOptions = new UICraftBuyButtons();
         this.btn_getOptions.mouseChildren = false;
         this.btn_getOptions.mouseEnabled = false;
         this.txt_title = new BodyTextField({
            "color":11986973,
            "size":11,
            "bold":true,
            "multiline":true,
            "filters":[Effects.stroke(2897169,1.5)]
         });
         this.txt_title.text = Language.getInstance().getString("crafting_select_craftkit");
         this.txt_title.x = this.ui_image.x - 4;
         this.txt_title.mouseEnabled = false;
         addChild(this.txt_title);
         this.txt_itemType = new BodyTextField({
            "color":11986973,
            "size":11,
            "bold":true,
            "multiline":true,
            "filters":[Effects.stroke(2897169,1.5)]
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
         this.bmp_background.bitmapData.dispose();
         this.bmp_input.bitmapData.dispose();
         this.ui_image.dispose();
         this.txt_title.dispose();
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
         this.txt_itemType.textColor = 11986973;
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
            this.txt_itemType.text = "";
            this.txt_itemType.x = int(this.btn_getOptions.x + this.btn_getOptions.width + 4);
         }
         else
         {
            if(this.bmp_input.parent != null)
            {
               this.bmp_input.parent.removeChild(this.bmp_input);
            }
            this.ui_image.item = this._item;
            addChild(this.ui_image);
            this.txt_itemType.text = Language.getInstance().getString("items." + this._item.type).toUpperCase();
            this.txt_itemType.x = int(this.ui_image.x + this.ui_image.width + 6);
         }
         this.txt_itemType.width = int(this._width - this.txt_itemType.x);
         this.txt_itemType.y = int(this.ui_image.y + (this.ui_image.height - this.txt_itemType.height) * 0.5);
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

