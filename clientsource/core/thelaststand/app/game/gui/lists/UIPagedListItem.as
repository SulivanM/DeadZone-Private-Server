package thelaststand.app.game.gui.lists
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   
   public class UIPagedListItem extends Sprite
   {
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      protected var _width:int;
      
      protected var _height:int;
      
      public var id:String;
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public var mouseOut:NativeSignal;
      
      public var mouseDown:NativeSignal;
      
      public function UIPagedListItem()
      {
         super();
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
         this.mouseDown = new NativeSignal(this,MouseEvent.MOUSE_DOWN,MouseEvent);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.clicked.removeAll();
         this.mouseOver.removeAll();
         this.mouseOut.removeAll();
         this.mouseDown.removeAll();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled;
         this.alpha = this._enabled ? 1 : 0.3;
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
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

