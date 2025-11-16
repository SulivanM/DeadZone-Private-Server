package thelaststand.app.game.gui.mission
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   
   public class UIHealingParticles extends Sprite
   {
      
      private static const BMP_PARTICLE:BitmapData = new BmpParticleHealing();
      
      private static const X_POSITIONS:Array = [0,-5,5];
      
      private var _particles:Vector.<Bitmap>;
      
      private var _posIndex:int = 0;
      
      private var _maxParticles:int = 3;
      
      public function UIHealingParticles()
      {
         super();
         this._particles = new Vector.<Bitmap>();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:Bitmap = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         for each(_loc1_ in this._particles)
         {
            _loc1_.bitmapData = null;
         }
         this._particles = null;
      }
      
      private function createParticle() : void
      {
         var _loc1_:Bitmap = new Bitmap(BMP_PARTICLE,"never",true);
         _loc1_.scaleX = _loc1_.scaleY = 0.5 + Math.random() * 0.5;
         _loc1_.x = X_POSITIONS[this._posIndex];
         _loc1_.y = Math.random() * 6 - _loc1_.height;
         _loc1_.alpha = 0.5 + Math.random() * 0.5;
         if(++this._posIndex >= X_POSITIONS.length)
         {
            this._posIndex = 0;
         }
         this._particles.push(_loc1_);
         addChild(_loc1_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc3_:Bitmap = null;
         if(this._particles.length == 0 || this._particles.length < this._maxParticles && Math.random() < 0.05)
         {
            this.createParticle();
         }
         var _loc2_:int = int(this._particles.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._particles[_loc2_];
            _loc3_.y -= _loc3_.scaleY * 1.25;
            _loc3_.alpha -= 0.05;
            if(_loc3_.alpha <= 0)
            {
               this._particles.splice(_loc2_,1);
            }
            _loc2_--;
         }
      }
   }
}

