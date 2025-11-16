package thelaststand.app.game.gui.chat.components
{
   import com.greensock.TweenMax;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   
   public class UIChatPopupMenuButton extends Sprite
   {
      
      public static const WIDTH:uint = 110;
      
      public var onClick:Signal = new Signal(UIChatPopupMenuButton);
      
      public var data:Object;
      
      private var txt_message:BodyTextField;
      
      private var bg:Shape;
      
      private var _enabled:Boolean = true;
      
      public function UIChatPopupMenuButton(param1:uint = 13421772)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         this.bg = new Shape();
         this.bg.graphics.beginFill(4605510,1);
         this.bg.alpha = 0;
         this.bg.graphics.drawRect(0,0,WIDTH,10);
         addChild(this.bg);
         this.txt_message = new BodyTextField({
            "color":param1,
            "size":12,
            "leading":1,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_message.x = 5;
         addChild(this.txt_message);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.onClick.removeAll();
      }
      
      public function get label() : String
      {
         return this.txt_message.text;
      }
      
      public function set label(param1:String) : void
      {
         this.txt_message.text = param1;
         this.bg.height = this.txt_message.height;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled;
         alpha = this._enabled ? 1 : 0.4;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         this.onClick.dispatch(this);
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.bg,0.05,{"alpha":0.5});
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bg,0.2,{"alpha":0});
      }
   }
}

