package thelaststand.common.gui.buttons
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.natives.NativeSignal;
   
   public class AbstractButton extends Sprite
   {
      
      public var clicked:NativeSignal;
      
      public var mouseOver:NativeSignal;
      
      public var mouseOut:NativeSignal;
      
      public var mouseDown:NativeSignal;
      
      public var mouseUp:NativeSignal;
      
      public function AbstractButton()
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         useHandCursor = false;
         tabEnabled = tabChildren = false;
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         this.mouseOver = new NativeSignal(this,MouseEvent.MOUSE_OVER,MouseEvent);
         this.mouseOut = new NativeSignal(this,MouseEvent.MOUSE_OUT,MouseEvent);
         this.mouseDown = new NativeSignal(this,MouseEvent.MOUSE_DOWN,MouseEvent);
         this.mouseUp = new NativeSignal(this,MouseEvent.MOUSE_UP,MouseEvent);
      }
      
      public function dispose() : void
      {
         this.clicked.removeAll();
         this.mouseOver.removeAll();
         this.mouseOut.removeAll();
         this.mouseDown.removeAll();
         this.mouseUp.removeAll();
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function get autoSize() : Boolean
      {
         return false;
      }
      
      public function set autoSize(param1:Boolean) : void
      {
      }
   }
}

