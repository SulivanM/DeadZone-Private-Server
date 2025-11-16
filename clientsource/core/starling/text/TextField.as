package starling.text
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import starling.core.RenderSupport;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Quad;
   import starling.display.QuadBatch;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.textures.Texture;
   import starling.utils.HAlign;
   import starling.utils.VAlign;
   
   public class TextField extends DisplayObjectContainer
   {
      
      private static var sNativeTextField:flash.text.TextField = new flash.text.TextField();
      
      private static var sBitmapFonts:Dictionary = new Dictionary();
      
      private var mFontSize:Number;
      
      private var mColor:uint;
      
      private var mText:String;
      
      private var mFontName:String;
      
      private var mHAlign:String;
      
      private var mVAlign:String;
      
      private var mBold:Boolean;
      
      private var mItalic:Boolean;
      
      private var mUnderline:Boolean;
      
      private var mAutoScale:Boolean;
      
      private var mKerning:Boolean;
      
      private var mNativeFilters:Array;
      
      private var mRequiresRedraw:Boolean;
      
      private var mIsRenderedText:Boolean;
      
      private var mTextBounds:Rectangle;
      
      private var mHitArea:DisplayObject;
      
      private var mBorder:DisplayObjectContainer;
      
      private var mImage:Image;
      
      private var mQuadBatch:QuadBatch;
      
      public function TextField(param1:int, param2:int, param3:String, param4:String = "Verdana", param5:Number = 12, param6:uint = 0, param7:Boolean = false)
      {
         super();
         this.mText = param3 ? param3 : "";
         this.mFontSize = param5;
         this.mColor = param6;
         this.mHAlign = HAlign.CENTER;
         this.mVAlign = VAlign.CENTER;
         this.mBorder = null;
         this.mKerning = true;
         this.mBold = param7;
         this.fontName = param4;
         this.mHitArea = new Quad(param1,param2);
         this.mHitArea.alpha = 0;
         addChild(this.mHitArea);
         addEventListener(Event.FLATTEN,this.onFlatten);
      }
      
      public static function registerBitmapFont(param1:BitmapFont, param2:String = null) : String
      {
         if(param2 == null)
         {
            param2 = param1.name;
         }
         sBitmapFonts[param2] = param1;
         return param2;
      }
      
      public static function unregisterBitmapFont(param1:String, param2:Boolean = true) : void
      {
         if(param2 && sBitmapFonts[param1] != undefined)
         {
            sBitmapFonts[param1].dispose();
         }
         delete sBitmapFonts[param1];
      }
      
      public static function getBitmapFont(param1:String) : BitmapFont
      {
         return sBitmapFonts[param1];
      }
      
      override public function dispose() : void
      {
         removeEventListener(Event.FLATTEN,this.onFlatten);
         if(this.mImage)
         {
            this.mImage.texture.dispose();
         }
         if(this.mQuadBatch)
         {
            this.mQuadBatch.dispose();
         }
         super.dispose();
      }
      
      private function onFlatten(param1:Event) : void
      {
         if(this.mRequiresRedraw)
         {
            this.redrawContents();
         }
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         if(this.mRequiresRedraw)
         {
            this.redrawContents();
         }
         super.render(param1,param2);
      }
      
      private function redrawContents() : void
      {
         if(this.mIsRenderedText)
         {
            this.createRenderedContents();
         }
         else
         {
            this.createComposedContents();
         }
         this.mRequiresRedraw = false;
      }
      
      private function createRenderedContents() : void
      {
         if(this.mQuadBatch)
         {
            this.mQuadBatch.removeFromParent(true);
            this.mQuadBatch = null;
         }
         var _loc1_:Number = Starling.contentScaleFactor;
         var _loc2_:Number = this.mHitArea.width * _loc1_;
         var _loc3_:Number = this.mHitArea.height * _loc1_;
         var _loc4_:TextFormat = new TextFormat(this.mFontName,this.mFontSize * _loc1_,this.mColor,this.mBold,this.mItalic,this.mUnderline,null,null,this.mHAlign);
         _loc4_.kerning = this.mKerning;
         sNativeTextField.defaultTextFormat = _loc4_;
         sNativeTextField.width = _loc2_;
         sNativeTextField.height = _loc3_;
         sNativeTextField.antiAliasType = AntiAliasType.ADVANCED;
         sNativeTextField.selectable = false;
         sNativeTextField.multiline = true;
         sNativeTextField.wordWrap = true;
         sNativeTextField.text = this.mText;
         sNativeTextField.embedFonts = true;
         sNativeTextField.filters = this.mNativeFilters;
         if(sNativeTextField.textWidth == 0 || sNativeTextField.textHeight == 0)
         {
            sNativeTextField.embedFonts = false;
         }
         if(this.mAutoScale)
         {
            this.autoScaleNativeTextField(sNativeTextField);
         }
         var _loc5_:Number = sNativeTextField.textWidth;
         var _loc6_:Number = sNativeTextField.textHeight;
         var _loc7_:Number = 0;
         if(this.mHAlign == HAlign.LEFT)
         {
            _loc7_ = 2;
         }
         else if(this.mHAlign == HAlign.CENTER)
         {
            _loc7_ = (_loc2_ - _loc5_) / 2;
         }
         else if(this.mHAlign == HAlign.RIGHT)
         {
            _loc7_ = _loc2_ - _loc5_ - 2;
         }
         var _loc8_:Number = 0;
         if(this.mVAlign == VAlign.TOP)
         {
            _loc8_ = 2;
         }
         else if(this.mVAlign == VAlign.CENTER)
         {
            _loc8_ = (_loc3_ - _loc6_) / 2;
         }
         else if(this.mVAlign == VAlign.BOTTOM)
         {
            _loc8_ = _loc3_ - _loc6_ - 2;
         }
         var _loc9_:BitmapData = new BitmapData(_loc2_,_loc3_,true,0);
         _loc9_.draw(sNativeTextField,new Matrix(1,0,0,1,0,int(_loc8_) - 2));
         sNativeTextField.text = "";
         if(this.mTextBounds == null)
         {
            this.mTextBounds = new Rectangle();
         }
         this.mTextBounds.setTo(_loc7_ / _loc1_,_loc8_ / _loc1_,_loc5_ / _loc1_,_loc6_ / _loc1_);
         var _loc10_:Texture = Texture.fromBitmapData(_loc9_,false,false,_loc1_);
         if(this.mImage == null)
         {
            this.mImage = new Image(_loc10_);
            this.mImage.touchable = false;
            addChild(this.mImage);
         }
         else
         {
            this.mImage.texture.dispose();
            this.mImage.texture = _loc10_;
            this.mImage.readjustSize();
         }
      }
      
      private function autoScaleNativeTextField(param1:flash.text.TextField) : void
      {
         var _loc5_:TextFormat = null;
         var _loc2_:Number = Number(param1.defaultTextFormat.size);
         var _loc3_:int = param1.height - 4;
         var _loc4_:int = param1.width - 4;
         while(param1.textWidth > _loc4_ || param1.textHeight > _loc3_)
         {
            if(_loc2_ <= 4)
            {
               break;
            }
            _loc5_ = param1.defaultTextFormat;
            _loc5_.size = _loc2_--;
            param1.setTextFormat(_loc5_);
         }
      }
      
      private function createComposedContents() : void
      {
         if(this.mImage)
         {
            this.mImage.removeFromParent(true);
            this.mImage = null;
         }
         if(this.mQuadBatch == null)
         {
            this.mQuadBatch = new QuadBatch();
            this.mQuadBatch.touchable = false;
            addChild(this.mQuadBatch);
         }
         else
         {
            this.mQuadBatch.reset();
         }
         var _loc1_:BitmapFont = sBitmapFonts[this.mFontName];
         if(_loc1_ == null)
         {
            throw new Error("Bitmap font not registered: " + this.mFontName);
         }
         _loc1_.fillQuadBatch(this.mQuadBatch,this.mHitArea.width,this.mHitArea.height,this.mText,this.mFontSize,this.mColor,this.mHAlign,this.mVAlign,this.mAutoScale,this.mKerning);
         this.mTextBounds = null;
      }
      
      private function updateBorder() : void
      {
         if(this.mBorder == null)
         {
            return;
         }
         var _loc1_:Number = this.mHitArea.width;
         var _loc2_:Number = this.mHitArea.height;
         var _loc3_:Quad = this.mBorder.getChildAt(0) as Quad;
         var _loc4_:Quad = this.mBorder.getChildAt(1) as Quad;
         var _loc5_:Quad = this.mBorder.getChildAt(2) as Quad;
         var _loc6_:Quad = this.mBorder.getChildAt(3) as Quad;
         _loc3_.width = _loc1_;
         _loc3_.height = 1;
         _loc5_.width = _loc1_;
         _loc5_.height = 1;
         _loc6_.width = 1;
         _loc6_.height = _loc2_;
         _loc4_.width = 1;
         _loc4_.height = _loc2_;
         _loc4_.x = _loc1_ - 1;
         _loc5_.y = _loc2_ - 1;
         _loc3_.color = _loc4_.color = _loc5_.color = _loc6_.color = this.mColor;
      }
      
      public function get textBounds() : Rectangle
      {
         if(this.mRequiresRedraw)
         {
            this.redrawContents();
         }
         if(this.mTextBounds == null)
         {
            this.mTextBounds = this.mQuadBatch.getBounds(this.mQuadBatch);
         }
         return this.mTextBounds.clone();
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         return this.mHitArea.getBounds(param1,param2);
      }
      
      override public function set width(param1:Number) : void
      {
         this.mHitArea.width = param1;
         this.mRequiresRedraw = true;
         this.updateBorder();
      }
      
      override public function set height(param1:Number) : void
      {
         this.mHitArea.height = param1;
         this.mRequiresRedraw = true;
         this.updateBorder();
      }
      
      public function get text() : String
      {
         return this.mText;
      }
      
      public function set text(param1:String) : void
      {
         if(param1 == null)
         {
            param1 = "";
         }
         if(this.mText != param1)
         {
            this.mText = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get fontName() : String
      {
         return this.mFontName;
      }
      
      public function set fontName(param1:String) : void
      {
         if(this.mFontName != param1)
         {
            if(param1 == BitmapFont.MINI && sBitmapFonts[param1] == undefined)
            {
               registerBitmapFont(new BitmapFont());
            }
            this.mFontName = param1;
            this.mRequiresRedraw = true;
            this.mIsRenderedText = sBitmapFonts[param1] == undefined;
         }
      }
      
      public function get fontSize() : Number
      {
         return this.mFontSize;
      }
      
      public function set fontSize(param1:Number) : void
      {
         if(this.mFontSize != param1)
         {
            this.mFontSize = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get color() : uint
      {
         return this.mColor;
      }
      
      public function set color(param1:uint) : void
      {
         if(this.mColor != param1)
         {
            this.mColor = param1;
            this.updateBorder();
            this.mRequiresRedraw = true;
         }
      }
      
      public function get hAlign() : String
      {
         return this.mHAlign;
      }
      
      public function set hAlign(param1:String) : void
      {
         if(!HAlign.isValid(param1))
         {
            throw new ArgumentError("Invalid horizontal align: " + param1);
         }
         if(this.mHAlign != param1)
         {
            this.mHAlign = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get vAlign() : String
      {
         return this.mVAlign;
      }
      
      public function set vAlign(param1:String) : void
      {
         if(!VAlign.isValid(param1))
         {
            throw new ArgumentError("Invalid vertical align: " + param1);
         }
         if(this.mVAlign != param1)
         {
            this.mVAlign = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get border() : Boolean
      {
         return this.mBorder != null;
      }
      
      public function set border(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         if(param1 && this.mBorder == null)
         {
            this.mBorder = new Sprite();
            addChild(this.mBorder);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               this.mBorder.addChild(new Quad(1,1));
               _loc2_++;
            }
            this.updateBorder();
         }
         else if(!param1 && this.mBorder != null)
         {
            this.mBorder.removeFromParent(true);
            this.mBorder = null;
         }
      }
      
      public function get bold() : Boolean
      {
         return this.mBold;
      }
      
      public function set bold(param1:Boolean) : void
      {
         if(this.mBold != param1)
         {
            this.mBold = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get italic() : Boolean
      {
         return this.mItalic;
      }
      
      public function set italic(param1:Boolean) : void
      {
         if(this.mItalic != param1)
         {
            this.mItalic = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get underline() : Boolean
      {
         return this.mUnderline;
      }
      
      public function set underline(param1:Boolean) : void
      {
         if(this.mUnderline != param1)
         {
            this.mUnderline = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get kerning() : Boolean
      {
         return this.mKerning;
      }
      
      public function set kerning(param1:Boolean) : void
      {
         if(this.mKerning != param1)
         {
            this.mKerning = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get autoScale() : Boolean
      {
         return this.mAutoScale;
      }
      
      public function set autoScale(param1:Boolean) : void
      {
         if(this.mAutoScale != param1)
         {
            this.mAutoScale = param1;
            this.mRequiresRedraw = true;
         }
      }
      
      public function get nativeFilters() : Array
      {
         return this.mNativeFilters;
      }
      
      public function set nativeFilters(param1:Array) : void
      {
         if(!this.mIsRenderedText)
         {
            throw new Error("The TextField.nativeFilters property cannot be used on Bitmap fonts.");
         }
         this.mNativeFilters = param1.concat();
         this.mRequiresRedraw = true;
      }
   }
}

