package thelaststand.app.game.gui.buttons
{
   import flash.display.DisplayObject;
   
   public class UIBarToggleButton extends UIBarButton
   {
      
      private var _iconUnpressed:DisplayObject;
      
      private var _iconPressed:DisplayObject;
      
      private var _pressed:Boolean;
      
      public function UIBarToggleButton(param1:DisplayObject = null, param2:DisplayObject = null)
      {
         super();
         this._pressed = false;
         this._iconUnpressed = param1;
         this._iconPressed = param2;
         icon = param1;
      }
      
      public function get pressed() : Boolean
      {
         return this._pressed;
      }
      
      public function set pressed(param1:Boolean) : void
      {
         this._pressed = param1;
         icon = this._pressed ? (this._iconPressed != null ? this._iconPressed : this._iconUnpressed) : this._iconUnpressed;
      }
   }
}

