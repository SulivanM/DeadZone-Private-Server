package thelaststand.app.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.gui.dialogues.HelpDialogue;
   import thelaststand.common.gui.buttons.AbstractButton;
   
   public class HelpButton extends AbstractButton
   {
      
      private var bmp:Bitmap;
      
      private var langRef:String;
      
      private var _enabled:Boolean = true;
      
      public function HelpButton(param1:String)
      {
         super();
         this.langRef = param1;
         mouseChildren = false;
         this.bmp = new Bitmap(new BmpIconHelp(),"auto",true);
         this.bmp.alpha = 0.7;
         addChild(this.bmp);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClick,false,int.MAX_VALUE,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.bmp.bitmapData.dispose();
         this.bmp = null;
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp,0.1,{"alpha":1});
         if(this._enabled)
         {
            Audio.sound.play("sound/interface/int-over.mp3");
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp,0.3,{"alpha":0.7});
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(!this._enabled)
         {
            param1.stopImmediatePropagation();
            return;
         }
         var _loc2_:HelpDialogue = new HelpDialogue(this.langRef);
         _loc2_.open();
      }
   }
}

