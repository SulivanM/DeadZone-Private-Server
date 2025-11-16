package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.gui.UIImage;
   
   public class UISurvivorPortrait extends Sprite
   {
      
      public static const SIZE_32x32:String = "32x32";
      
      public static const SIZE_38x38:String = "38x38";
      
      public static const SIZE_40x40:String = "40x40";
      
      private const INNER_GLOW:GlowFilter = new GlowFilter(0,0.85,20,20,1,2,true);
      
      private var _colorBg:uint;
      
      private var _size:String;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _survivor:Survivor;
      
      private var mc_background:Shape;
      
      private var mc_image:UIImage;
      
      private var bmp_classIcon:Bitmap;
      
      public function UISurvivorPortrait(param1:String, param2:uint)
      {
         super();
         this._size = param1;
         this._colorBg = param2;
         this.setSize();
         this.mc_background = new Shape();
         this.mc_background.filters = [this.INNER_GLOW];
         this.mc_background.cacheAsBitmap = true;
         addChild(this.mc_background);
         this.mc_image = new UIImage(this._width,this._height,0,0,true);
         addChild(this.mc_image);
         this.draw();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.mc_image.dispose();
         this.mc_image = null;
         this.mc_background.filters = [];
         this.mc_background = null;
         if(this.bmp_classIcon)
         {
            this.bmp_classIcon.bitmapData = null;
         }
         this.bmp_classIcon = null;
         filters = [];
         if(this._survivor != null)
         {
            this._survivor.portraitChanged.remove(this.onPortraitChanged);
            this._survivor = null;
         }
      }
      
      public function loadPortrait(param1:*) : void
      {
         if(this.mc_image == null)
         {
            return;
         }
         if(this.bmp_classIcon != null)
         {
            if(this.bmp_classIcon.parent)
            {
               this.bmp_classIcon.parent.removeChild(this.bmp_classIcon);
            }
         }
         if(!this.mc_image.parent)
         {
            addChild(this.mc_image);
         }
         if(param1 is String)
         {
            this.mc_image.uri = String(param1);
         }
         else if(param1 is Function)
         {
            this.mc_image.getURIViaFunction(param1 as Function);
         }
      }
      
      private function draw() : void
      {
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(this._colorBg);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
      }
      
      private function setSize() : void
      {
         var _loc1_:int = 0;
         switch(this._size)
         {
            case SIZE_32x32:
               this._width = this._height = 32;
               break;
            case SIZE_38x38:
               this._width = this._height = 38;
               break;
            case SIZE_40x40:
            default:
               this._width = this._height = 40;
         }
      }
      
      private function showClassIcon() : void
      {
         if(this.mc_image.parent)
         {
            this.mc_image.parent.removeChild(this.mc_image);
         }
         if(this.survivor == null)
         {
            return;
         }
         if(this.bmp_classIcon == null)
         {
            this.bmp_classIcon = new Bitmap(SurvivorClass.getClassIcon(this.survivor.classId),"auto",true);
         }
         else
         {
            this.bmp_classIcon.bitmapData = SurvivorClass.getClassIcon(this.survivor.classId);
         }
         this.bmp_classIcon.x = int((this._width - this.bmp_classIcon.width) * 0.5) + 2;
         this.bmp_classIcon.y = int((this._height - this.bmp_classIcon.height) * 0.5);
         addChild(this.bmp_classIcon);
      }
      
      private function onPortraitChanged(param1:Survivor) : void
      {
         if(this._survivor.portraitURI != null && Boolean(this._survivor.portraitURI))
         {
            this.loadPortrait(this._survivor.portraitURI);
         }
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function set survivor(param1:Survivor) : void
      {
         if(this._survivor != null)
         {
            this._survivor.portraitChanged.remove(this.onPortraitChanged);
         }
         this._survivor = param1;
         if(this._survivor == null)
         {
            this.mc_image.uri = null;
            return;
         }
         this._survivor.portraitChanged.add(this.onPortraitChanged);
         if(this._survivor.portraitURI != null && this._survivor.portraitURI != "")
         {
            this.loadPortrait(this._survivor.portraitURI);
         }
         else
         {
            this.showClassIcon();
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

