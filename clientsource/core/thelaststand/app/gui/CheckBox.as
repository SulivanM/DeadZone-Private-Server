package thelaststand.app.gui
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class CheckBox extends Sprite
   {
      
      public static const ALIGN_LEFT:String = "left";
      
      public static const ALIGN_RIGHT:String = "right";
      
      private var _checkColor:uint = 7829367;
      
      private var _labelAlign:String;
      
      private var _label:String;
      
      private var _selected:Boolean;
      
      private var _enabled:Boolean = true;
      
      private var _width:int = 20;
      
      private var _height:int = 20;
      
      private var txt_label:BodyTextField;
      
      private var mc_border:Shape;
      
      private var mc_checkbox:Shape;
      
      private var mc_check:Sprite;
      
      private var mc_hitArea:Sprite;
      
      public var changed:Signal;
      
      public function CheckBox(param1:Object = null, param2:String = "left")
      {
         super();
         mouseChildren = false;
         this.changed = new Signal(CheckBox);
         this._labelAlign = param2;
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,10);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.mc_checkbox = new Shape();
         this.mc_checkbox.filters = [new DropShadowFilter(0,0,0,1,8,8,0.9,1,true)];
         addChild(this.mc_checkbox);
         this.mc_border = new Shape();
         addChild(this.mc_border);
         this.mc_check = new Sprite();
         this.mc_check.visible = this._selected;
         addChild(this.mc_check);
         if(param1 == null)
         {
            param1 = {
               "color":16777215,
               "size":13
            };
         }
         if(!param1.filters)
         {
            param1.filters = [Effects.TEXT_SHADOW];
         }
         this._label = param1.htmlText || "";
         this.txt_label = new BodyTextField(param1);
         this.txt_label.htmlText = this._label;
         addChild(this.txt_label);
         this.draw();
         this.positionElements();
         addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.txt_label.dispose();
         this.txt_label = null;
         this.mc_checkbox.filters = [];
         this.mc_checkbox = null;
         this.changed.removeAll();
      }
      
      public function setLabelProperties(param1:Object) : void
      {
         this.txt_label.setProperties(param1);
         this.positionElements();
      }
      
      private function draw() : void
      {
         this.mc_checkbox.graphics.clear();
         this.mc_checkbox.graphics.beginFill(3552051);
         this.mc_checkbox.graphics.drawRect(0,0,this._width,this._height);
         this.mc_checkbox.graphics.endFill();
         var _loc1_:int = 1;
         this.mc_border.graphics.clear();
         this.mc_border.graphics.beginFill(7829367);
         this.mc_border.graphics.drawRect(0,0,this._width,this._height);
         this.mc_border.graphics.drawRect(_loc1_,_loc1_,this._width - _loc1_ * 2,this._height - _loc1_ * 2);
         this.mc_border.graphics.endFill();
         this.mc_check.graphics.clear();
         this.mc_check.graphics.beginFill(7829367);
         this.mc_check.graphics.drawRect(0,0,Math.round(this._width * 0.5),Math.round(this._height * 0.5));
         this.mc_check.graphics.endFill();
      }
      
      private function positionElements() : void
      {
         if(this._label == null || this._label.length == 0)
         {
            this.mc_checkbox.x = 0;
            this.txt_label.visible = false;
            this.txt_label.x = this.txt_label.y = 0;
         }
         else
         {
            if(this._labelAlign == CheckBox.ALIGN_LEFT)
            {
               this.txt_label.x = 0;
               this.mc_checkbox.x = int(this.txt_label.x + this.txt_label.width + 6);
               this.mc_hitArea.width = int(this.mc_checkbox.x + this.mc_checkbox.width);
            }
            else if(this._labelAlign == CheckBox.ALIGN_RIGHT)
            {
               this.mc_checkbox.x = 0;
               this.txt_label.x = int(this.mc_checkbox.x + this.mc_checkbox.width + 6);
               this.mc_hitArea.width = int(this.txt_label.x + this.txt_label.width);
            }
            this.txt_label.y = Math.round(this.mc_checkbox.y + (this.mc_checkbox.height - this.txt_label.height) * 0.5);
            this.txt_label.visible = true;
         }
         this.mc_hitArea.y = Math.min(this.mc_checkbox.y,this.txt_label.y);
         this.mc_hitArea.height = Math.max(this.mc_checkbox.height,this.txt_label.height);
         this.mc_border.x = this.mc_checkbox.x;
         this.mc_border.y = this.mc_checkbox.y;
         this.mc_check.x = int(this.mc_checkbox.x + (this.mc_checkbox.width - this.mc_check.width) * 0.5);
         this.mc_check.y = int(this.mc_checkbox.y + (this.mc_checkbox.height - this.mc_check.height) * 0.5);
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         this.draw();
         this.positionElements();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         this.selected = !this.selected;
         this.changed.dispatch(this);
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get align() : String
      {
         return this._labelAlign;
      }
      
      public function set align(param1:String) : void
      {
         this._labelAlign = param1;
         this.positionElements();
      }
      
      public function get checkColor() : uint
      {
         return this._checkColor;
      }
      
      public function set checkColor(param1:uint) : void
      {
         this._checkColor = param1;
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = this._checkColor;
         this.mc_check.transform.colorTransform = _loc2_;
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.txt_label.htmlText = this._label;
         this.positionElements();
      }
      
      public function get labelAlign() : String
      {
         return this._labelAlign;
      }
      
      public function set labelAlign(param1:String) : void
      {
         this._labelAlign = param1;
         this.positionElements();
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         this.mc_check.visible = this._selected;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled;
         alpha = this._enabled ? 1 : 0.3;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this._height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this._width,param1);
      }
   }
}

