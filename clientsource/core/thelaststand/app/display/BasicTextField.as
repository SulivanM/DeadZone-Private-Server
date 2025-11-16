package thelaststand.app.display
{
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextLineMetrics;
   
   public class BasicTextField extends TextField
   {
      
      private var _txtFormat:TextFormat;
      
      private var _maxWidth:int = 0;
      
      public function BasicTextField(param1:Object = null)
      {
         super();
         this._maxWidth = Boolean(param1) && param1.maxWidth != undefined ? int(param1.maxWidth) : 0;
         this._txtFormat = new TextFormat(param1 != null && Boolean(param1.hasOwnProperty("font")) ? param1.font : "_sans");
         this._txtFormat.size = 14;
         this._txtFormat.color = 16777215;
         embedFonts = this._txtFormat.font != "_sans";
         selectable = false;
         multiline = wordWrap = false;
         autoSize = TextFieldAutoSize.LEFT;
         mouseEnabled = false;
         mouseWheelEnabled = false;
         if(param1 != null)
         {
            this.setProperties(param1);
         }
         height = Boolean(param1) && param1.height != undefined ? Number(param1.height) : int(this._txtFormat.size + 4);
         defaultTextFormat = this._txtFormat;
         setTextFormat(this._txtFormat);
      }
      
      public static function setFieldSelectionColor(param1:TextField, param2:uint) : void
      {
         param1.backgroundColor = invert(param1.backgroundColor);
         param1.borderColor = invert(param1.borderColor);
         param1.textColor = invert(param1.textColor);
         var _loc3_:ColorTransform = new ColorTransform();
         _loc3_.color = param2;
         _loc3_.redMultiplier = -1;
         _loc3_.greenMultiplier = -1;
         _loc3_.blueMultiplier = -1;
         param1.transform.colorTransform = _loc3_;
      }
      
      protected static function invert(param1:uint) : uint
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = param1;
         return invertColorTransform(_loc2_).color;
      }
      
      protected static function invertColorTransform(param1:ColorTransform) : ColorTransform
      {
         var colorTrans:ColorTransform = param1;
         with(colorTrans)
         {
            redMultiplier = -redMultiplier;
            greenMultiplier = -greenMultiplier;
            blueMultiplier = -blueMultiplier;
            redOffset = 255 - redOffset;
            greenOffset = 255 - greenOffset;
            blueOffset = 255 - blueOffset;
         }
         return colorTrans;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         filters = [];
      }
      
      public function autoSizeToContent() : void
      {
         var _loc3_:TextLineMetrics = null;
         var _loc4_:int = 0;
         multiline = wordWrap = true;
         width = int.MAX_VALUE;
         this.htmlText = this.htmlText;
         var _loc1_:int = int.MIN_VALUE;
         var _loc2_:int = 0;
         while(_loc2_ < numLines)
         {
            _loc3_ = getLineMetrics(_loc2_);
            _loc4_ = _loc3_.width;
            if(_loc4_ > _loc1_)
            {
               _loc1_ = _loc4_;
            }
            _loc2_++;
         }
         width = _loc1_ + 8;
         this.checkWidth();
      }
      
      public function setProperty(param1:String, param2:*) : void
      {
         if(this._txtFormat.hasOwnProperty(param1))
         {
            this._txtFormat[param1] = param2;
         }
         if(this.hasOwnProperty(param1))
         {
            this[param1] = param2;
         }
         defaultTextFormat = this._txtFormat;
         setTextFormat(this._txtFormat);
      }
      
      public function setProperties(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(this._txtFormat.hasOwnProperty(_loc2_))
            {
               this._txtFormat[_loc2_] = param1[_loc2_];
            }
            if(this.hasOwnProperty(_loc2_))
            {
               this[_loc2_] = param1[_loc2_];
            }
         }
         if(Boolean(param1.multiline) && param1.wordWrap == undefined)
         {
            this.multiline = this.wordWrap = param1.multiline;
         }
         defaultTextFormat = this._txtFormat;
         setTextFormat(this._txtFormat);
      }
      
      private function checkWidth() : void
      {
         scaleX = scaleY = 1;
         if(this._maxWidth > 0 && width > this._maxWidth)
         {
            scaleX = this._maxWidth / width;
            width = int(width);
            scaleY = scaleX;
         }
      }
      
      override public function set text(param1:String) : void
      {
         super.text = param1;
         this.checkWidth();
      }
      
      override public function set htmlText(param1:String) : void
      {
         super.htmlText = param1;
         this.checkWidth();
      }
      
      public function get maxWidth() : int
      {
         return this._maxWidth;
      }
      
      public function set maxWidth(param1:int) : void
      {
         this._maxWidth = param1;
         this.checkWidth();
      }
   }
}

