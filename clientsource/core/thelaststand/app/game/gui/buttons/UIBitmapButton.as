package thelaststand.app.game.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class UIBitmapButton extends Sprite
   {
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      private var _normalBD:BitmapData;
      
      private var _selectedBD:BitmapData;
      
      private var _bitmap:Bitmap;
      
      public function UIBitmapButton(param1:BitmapData, param2:BitmapData = null)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this._normalBD = param1;
         this._selectedBD = param2;
         this._bitmap = new Bitmap(this._normalBD);
         this._bitmap.alpha = 0.8;
         addChild(this._bitmap);
      }
      
      public function destroy() : void
      {
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         if(parent)
         {
            parent.removeChild(this);
         }
         this._bitmap.bitmapData = null;
      }
      
      private function setEnabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled && !this._selected;
         this._bitmap.alpha = this._enabled ? 0.8 : 0.3;
      }
      
      private function setSelected(param1:Boolean) : void
      {
         this._selected = param1;
         mouseEnabled = this._enabled && !this._selected;
         if(this._selected)
         {
            if(this._selectedBD)
            {
               this._bitmap.bitmapData = this._selectedBD;
            }
         }
         else
         {
            this._bitmap.bitmapData = this._normalBD;
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this._bitmap,0.1,{"alpha":1});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this._selected)
         {
            return;
         }
         TweenMax.to(this._bitmap,0.1,{"alpha":0.8});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.setEnabled(param1);
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.setSelected(param1);
      }
      
      public function get normalBD() : BitmapData
      {
         return this._normalBD;
      }
      
      public function set normalBD(param1:BitmapData) : void
      {
         this._normalBD = param1;
         if(!this._selected)
         {
            this._bitmap.bitmapData = this._normalBD;
         }
      }
      
      public function get selectedBD() : BitmapData
      {
         return this._selectedBD;
      }
      
      public function set selectedBD(param1:BitmapData) : void
      {
         this._selectedBD = param1;
         if(this._selected)
         {
            this._bitmap.bitmapData = this._selectedBD;
         }
      }
   }
}

