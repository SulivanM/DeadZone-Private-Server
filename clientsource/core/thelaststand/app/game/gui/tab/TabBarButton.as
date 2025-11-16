package thelaststand.app.game.gui.tab
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.common.gui.buttons.AbstractButton;
   
   public class TabBarButton extends AbstractButton
   {
      
      private var _selected:Boolean;
      
      private var _enabled:Boolean = true;
      
      private var bg:TabButtonBase;
      
      private var labelContainer:Sprite;
      
      private var txt_label:BodyTextField;
      
      private var _icon:DisplayObject;
      
      private var _minWidth:int = 95;
      
      private var _padding:Number = 10;
      
      private var _iconOffsetX:int = 0;
      
      private var _iconOffsetY:int = 0;
      
      private var _iconSpace:int = 2;
      
      public var id:String;
      
      public function TabBarButton(param1:String, param2:String = "", param3:Object = null, param4:Object = null)
      {
         super();
         this.id = param1;
         this.bg = new TabButtonBase();
         addChild(this.bg);
         this.labelContainer = new Sprite();
         addChild(this.labelContainer);
         if(param4 == null)
         {
            param4 = {};
         }
         if(!param4.hasOwnProperty("color"))
         {
            param4.color = 16777215;
         }
         if(!param4.hasOwnProperty("size"))
         {
            param4.size = 12;
         }
         if(!param4.hasOwnProperty("bold"))
         {
            param4.bold = true;
         }
         this.txt_label = new BodyTextField(param4);
         this.txt_label.filters = [Effects.STROKE];
         this.labelContainer.addChild(this.txt_label);
         if(param2 != null)
         {
            this.label = param2;
         }
         if(param3)
         {
            if("iconOffsetX" in param3)
            {
               this._iconOffsetX = param3.iconOffsetX;
            }
            if("iconOffsetY" in param3)
            {
               this._iconOffsetY = param3.iconOffsetY;
            }
            if("iconSpace" in param3)
            {
               this._iconSpace = param3.iconSpace;
            }
            if("minWidth" in param3)
            {
               this._minWidth = Math.max(param3.minWidth,this._padding * 4);
            }
            if("icon" in param3)
            {
               if(param3.icon is BitmapData)
               {
                  this.icon = new Bitmap(param3.icon);
               }
               else
               {
                  this.icon = param3.icon as DisplayObject;
               }
            }
         }
         this.selected = false;
         this.highlight(false);
         this.updateLayout();
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,int.MAX_VALUE,true);
      }
      
      override public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.CLICK,this.onClick);
         this.txt_label.dispose();
         var _loc1_:Bitmap = this._icon as Bitmap;
         if(_loc1_ != null)
         {
            if(_loc1_.bitmapData != null)
            {
               _loc1_.bitmapData.dispose();
               _loc1_.bitmapData = null;
            }
            _loc1_ = null;
         }
         if(this._icon != null)
         {
            this._icon.filters = [];
            this._icon = null;
         }
         this.highlight(false);
         super.dispose();
      }
      
      private function setSelected(param1:Boolean) : void
      {
         this._selected = param1;
         if(this._selected)
         {
            TweenMax.to(this.bg.base,0,{"colorTransform":{
               "tint":0,
               "tintAmount":0
            }});
            this.txt_label.alpha = 1;
         }
         else
         {
            TweenMax.to(this.bg.base,0,{"colorTransform":{
               "tint":0,
               "tintAmount":1
            }});
            this.txt_label.alpha = 0.5;
         }
      }
      
      private function setEnabled(param1:Boolean) : void
      {
         this._enabled = param1;
         if(this._selected)
         {
            this.selected = false;
         }
         if(!this._enabled)
         {
            TweenMax.to(this.bg.base,0,{"colorTransform":{
               "tint":0,
               "tintAmount":1
            }});
            this.bg.alpha = 0.3;
            this.labelContainer.alpha = 0.3;
         }
         else
         {
            this.bg.alpha = 1;
            this.highlight(false);
            this.setSelected(this._selected);
         }
      }
      
      private function updateLayout() : void
      {
         if(this._icon)
         {
            this._icon.y = int((this.bg.height - this._icon.height) * 0.5) + this._iconOffsetY;
            this._icon.x = this._iconOffsetX;
            this.txt_label.x = this._icon.x + this._icon.width + this._iconSpace;
         }
         else
         {
            this.txt_label.x = 0;
         }
         this.txt_label.y = int((this.bg.height - this.txt_label.height) * 0.5) - 1;
         var _loc1_:Number = this.txt_label.x + this.txt_label.width;
         var _loc2_:Number = _loc1_ + this._padding * 2;
         if(_loc2_ < this._minWidth)
         {
            _loc2_ = this._minWidth;
         }
         if(this.bg.width != _loc2_)
         {
            this.bg.base.width = this.bg.outline.width = _loc2_;
            this.bg.maskShape.width = _loc2_ + 2;
         }
         this.labelContainer.x = int((_loc2_ - _loc1_) * 0.5);
      }
      
      public function highlight(param1:Boolean) : void
      {
         if(this._selected || !this._enabled)
         {
            return;
         }
         if(param1)
         {
            TweenMax.to(this.bg.base,0,{"colorTransform":{
               "tint":0,
               "tintAmount":0.2
            }});
            TweenMax.to(this.labelContainer,0,{"alpha":0.8});
         }
         else
         {
            TweenMax.to(this.bg.base,0,{"colorTransform":{
               "tint":0,
               "tintAmount":1
            }});
            TweenMax.to(this.labelContainer,0,{"alpha":0.5});
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         this.highlight(true);
         if(!this._selected && this._enabled)
         {
            Audio.sound.play("sound/interface/int-over.mp3");
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         this.highlight(false);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(this._selected || !this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this._selected || !this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.setSelected(param1);
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.setEnabled(param1);
      }
      
      public function get label() : String
      {
         return this.txt_label.text;
      }
      
      public function set label(param1:String) : void
      {
         this.txt_label.text = param1;
         this.updateLayout();
      }
      
      public function get icon() : DisplayObject
      {
         return this._icon;
      }
      
      public function set icon(param1:DisplayObject) : void
      {
         if(this._icon != null)
         {
            if(this._icon.parent)
            {
               this._icon.parent.removeChild(this._icon);
            }
         }
         this._icon = param1;
         if(this._icon)
         {
            this.labelContainer.addChild(this._icon);
            this.updateLayout();
         }
      }
      
      public function get minWidth() : int
      {
         return this._minWidth;
      }
      
      public function set minWidth(param1:int) : void
      {
         this._minWidth = Math.max(param1,this._padding * 4);
         this.updateLayout();
      }
      
      override public function get width() : Number
      {
         return this.bg.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.bg.maskShape.y + this.bg.maskShape.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

