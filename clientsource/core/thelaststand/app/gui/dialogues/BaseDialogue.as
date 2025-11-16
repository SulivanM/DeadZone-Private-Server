package thelaststand.app.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.common.gui.dialogues.Dialogue;
   
   public class BaseDialogue extends Dialogue
   {
      
      public static const STROKE:GlowFilter = new GlowFilter(3618358,1,1.5,1.5,10,1);
      
      public static const INNER_SHADOW:DropShadowFilter = new DropShadowFilter(1,45,16777215,0.3,2,2,1,1,true);
      
      public static const DROP_SHADOW:DropShadowFilter = new DropShadowFilter(0,45,0,0.7,10,10,1,1);
      
      public static const BMP_GRIME:BitmapData = new BmpDialogueBackground();
      
      public static const TITLE_BAR_STROKE:GlowFilter = new GlowFilter(2696996,1,1.5,1.5,10,1);
      
      public static const TITLE_BAR_SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,5,5,0.25,2);
      
      public static const TITLE_COLOR_BUY:uint = 8113445;
      
      public static const TITLE_COLOR_GREY:uint = 4671303;
      
      public static const TITLE_COLOR_RUST:uint = 9582109;
      
      public static const TITLE_COLOR_GREEN:uint = 3183890;
      
      public static const TITLE_COLOR_LIGHT_BLUE:uint = 6398924;
      
      private var _title:String;
      
      private var _titleColor:uint;
      
      private var _titleWidth:int;
      
      private var _checkBoxAlign:String;
      
      private var bmp_titleBackground:Bitmap;
      
      private var mc_background:Shape;
      
      private var mc_titleColor_overlay:Shape;
      
      protected var mc_icon:DisplayObject;
      
      protected var btn_close:PushButton;
      
      protected var mc_titleBar:Sprite;
      
      protected var mc_check:CheckBox;
      
      protected var txt_title:TitleTextField;
      
      public var playSounds:Boolean = true;
      
      public function BaseDialogue(param1:String = null, param2:DisplayObject = null, param3:Boolean = false, param4:Boolean = true)
      {
         super(param1,param2,param4);
         _padding = 14;
         _buttonSpacing = 14;
         _buttonClass = PushButton;
         this.mc_background = new Shape();
         this.mc_background.filters = [INNER_SHADOW,STROKE,DROP_SHADOW];
         sprite.addChildAt(this.mc_background,0);
         if(param3)
         {
            this.btn_close = new PushButton("",new BmpIconButtonClose(),-1,null,7545099);
            this.btn_close.width = this.btn_close.height;
            this.btn_close.clicked.add(this.onClickClose);
            sprite.addChild(this.btn_close);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.bmp_titleBackground != null)
         {
            if(this.bmp_titleBackground.bitmapData != null)
            {
               this.bmp_titleBackground.bitmapData.dispose();
            }
            this.bmp_titleBackground.bitmapData = null;
            this.bmp_titleBackground = null;
         }
         if(this.mc_titleBar != null)
         {
            this.mc_titleBar.filters = [];
            this.mc_titleBar = null;
         }
         if(this.txt_title != null)
         {
            this.txt_title.dispose();
            this.txt_title = null;
         }
         if(this.mc_check != null)
         {
            this.mc_check.dispose();
            this.mc_check = null;
         }
         if(this.btn_close != null)
         {
            this.btn_close.dispose();
            this.btn_close = null;
         }
         if(this.mc_icon is Bitmap)
         {
            Bitmap(this.mc_icon).bitmapData.dispose();
            this.mc_icon.filters = [];
         }
      }
      
      public function addTitle(param1:String, param2:uint = 9582109, param3:int = -1, param4:Object = null) : void
      {
         this._title = param1.toUpperCase();
         this._titleWidth = param3;
         this.bmp_titleBackground = new Bitmap(new BmpTopBarBackground());
         this.bmp_titleBackground.scaleY = -1;
         this.bmp_titleBackground.y = this.bmp_titleBackground.height;
         this.mc_titleColor_overlay = new Shape();
         this.setTitleColor(param2);
         this.mc_titleBar = new Sprite();
         this.mc_titleBar.addChild(this.bmp_titleBackground);
         this.mc_titleBar.addChild(this.mc_titleColor_overlay);
         this.mc_titleBar.filters = [TITLE_BAR_STROKE,TITLE_BAR_SHADOW];
         sprite.addChild(this.mc_titleBar);
         this.txt_title = new TitleTextField({
            "color":16777215,
            "size":24
         });
         this.txt_title.text = this._title.toUpperCase();
         this.txt_title.filters = [Effects.TEXT_SHADOW_DARK];
         sprite.addChild(this.txt_title);
         if(param4)
         {
            if(param4 is BitmapData)
            {
               this.mc_icon = new Bitmap(BitmapData(param4),"auto",true);
               this.mc_icon.filters = [Effects.ICON_SHADOW];
            }
            else
            {
               if(!(param4 is DisplayObject))
               {
                  throw new Error("Attempting to apss invalid icon type to title");
               }
               this.mc_icon = DisplayObject(param4);
            }
            sprite.addChild(this.mc_icon);
         }
      }
      
      public function addCheckbox(param1:String, param2:Boolean = false, param3:String = "left") : CheckBox
      {
         if(this.mc_check != null)
         {
            this.mc_check.dispose();
         }
         this._checkBoxAlign = param3;
         this.mc_check = new CheckBox({
            "color":16777215,
            "size":14,
            "leading":1
         },CheckBox.ALIGN_RIGHT);
         this.mc_check.label = param1;
         this.mc_check.align = CheckBox.ALIGN_RIGHT;
         this.mc_check.selected = param2;
         this.mc_check.filters = [Effects.TEXT_SHADOW_DARK];
         sprite.addChild(this.mc_check);
         return this.mc_check;
      }
      
      public function setTitleColor(param1:uint) : void
      {
         if(this.mc_titleColor_overlay == null)
         {
            return;
         }
         this._titleColor = param1;
         this.mc_titleColor_overlay.graphics.clear();
         this.mc_titleColor_overlay.graphics.beginFill(this._titleColor,1);
         this.mc_titleColor_overlay.graphics.drawRect(0,0,this.bmp_titleBackground.width,this.bmp_titleBackground.height);
         this.mc_titleColor_overlay.graphics.endFill();
         this.mc_titleColor_overlay.blendMode = BlendMode.OVERLAY;
      }
      
      override public function open() : void
      {
         if(!isOpen && this.playSounds)
         {
            Audio.sound.play("sound/interface/int-open.mp3");
         }
         super.open();
      }
      
      override public function close() : void
      {
         if(isOpen && this.playSounds)
         {
            Audio.sound.play("sound/interface/int-close.mp3");
         }
         super.close();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = _height;
         if(this.mc_titleBar != null)
         {
            _loc1_ += this.mc_titleBar.y + this.mc_titleBar.height - _padding;
         }
         if(this.mc_check != null)
         {
            _loc1_ += this.mc_check.height + _padding;
         }
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(5460819);
         this.mc_background.graphics.drawRect(0,0,_width,_loc1_);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(BMP_GRIME);
         this.mc_background.graphics.drawRect(0,0,_width,_loc1_);
         this.mc_background.graphics.endFill();
      }
      
      override protected function updateElements() : void
      {
         super.updateElements();
         if(this.mc_titleBar != null)
         {
            this.mc_titleBar.x = -4;
            this.mc_titleBar.y = 8;
            this.mc_titleBar.width = this._titleWidth == -1 ? _width + 8 - (this.btn_close != null ? this.btn_close.width + _padding + 16 : 0) : this._titleWidth;
            this.mc_titleBar.height = 34;
            if(this.mc_icon)
            {
               this.mc_icon.x = _padding;
               this.mc_icon.y = Math.round(this.mc_titleBar.y + (this.mc_titleBar.height - this.mc_icon.height) * 0.5);
            }
            this.txt_title.x = this.mc_icon ? this.mc_icon.x + this.mc_icon.width + _padding : _padding;
            this.txt_title.maxWidth = int(this.mc_titleBar.width - (this.txt_title.x + _padding));
            this.txt_title.y = Math.round(this.mc_titleBar.y + (this.mc_titleBar.height - this.txt_title.height) * 0.5);
            if(content != null)
            {
               content.y += this.mc_titleBar.height;
            }
            if(this.mc_check != null)
            {
               this.mc_check.y = int(content.y + content.height + _padding);
               switch(this._checkBoxAlign)
               {
                  case "left":
                     this.mc_check.x = int(content.x);
                     break;
                  case "center":
                     this.mc_check.x = int((_width - this.mc_check.width) * 0.5);
                     break;
                  case "right":
                     this.mc_check.x = int(_width - _padding - this.mc_check.width);
               }
            }
            if(mc_buttons != null)
            {
               mc_buttons.y += mc_buttons.height;
               if(this.mc_check != null)
               {
                  mc_buttons.y += this.mc_check.height + _padding;
               }
            }
         }
         if(this.btn_close != null)
         {
            this.btn_close.y = this.mc_titleBar != null ? int(this.mc_titleBar.y + (this.mc_titleBar.height - this.btn_close.height) * 0.5) : _padding;
            this.btn_close.x = _width - this.btn_close.width - Math.min(_padding,this.btn_close.y);
         }
      }
      
      private function onClickClose(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override public function get width() : Number
      {
         return this.mc_background.width;
      }
      
      override public function get height() : Number
      {
         return this.mc_background.height;
      }
   }
}

