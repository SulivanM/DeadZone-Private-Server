package thelaststand.app.gui
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   
   public class UIPaginationDot extends PaginationDot
   {
      
      private var _selected:Boolean;
      
      private var _width:int;
      
      private var _height:int;
      
      private var mc_hitArea:Sprite;
      
      public function UIPaginationDot()
      {
         super();
         this._width = 10;
         this._height = 10;
         mc_dot.scaleX = mc_dot.scaleY = 0;
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(0,0);
         this.mc_hitArea.graphics.drawRect(-10,-10,this.width + 20,this.height + 20);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         hitArea = this.mc_hitArea;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killTweensOf(this);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         TweenMax.to(mc_dot,0.15,{
            "scale":(this._selected ? 1 : 0),
            "ease":(this._selected ? Quad.easeOut : Quad.easeIn)
         });
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

