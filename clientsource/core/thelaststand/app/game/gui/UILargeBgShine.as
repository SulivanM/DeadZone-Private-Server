package thelaststand.app.game.gui
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.utils.getTimer;
   
   public class UILargeBgShine extends Sprite
   {
      
      private var _rotationSpeed:Number = 0.5;
      
      private var _lastUpdate:Number = 0;
      
      private var mc_container:Sprite;
      
      private var bmp_shine:Bitmap;
      
      public function UILargeBgShine()
      {
         super();
         this.mc_container = new Sprite();
         addChild(this.mc_container);
         this.bmp_shine = new Bitmap(new BmpShine(),"never",true);
         this.bmp_shine.x = -(this.bmp_shine.width * 0.5);
         this.bmp_shine.y = -(this.bmp_shine.height * 0.5);
         this.mc_container.addChild(this.bmp_shine);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_shine.bitmapData.dispose();
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Number = getTimer();
         var _loc3_:Number = (_loc2_ - this._lastUpdate) / 1000;
         this.mc_container.rotation += _loc3_ / this._rotationSpeed;
         this._lastUpdate = _loc2_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this._lastUpdate = getTimer();
         this.mc_container.rotation = Math.random() * 360;
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
   }
}

