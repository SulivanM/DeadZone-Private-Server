package thelaststand.app.display
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.utils.getTimer;
   
   public class NoiseOverlay extends Bitmap
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _data:BitmapData;
      
      private var _frames:Vector.<BitmapData>;
      
      private var _frameIndex:int;
      
      private var _fps:Number;
      
      private var _invFps:Number;
      
      private var _frameAccumulator:Number = 0;
      
      private var _numFrames:int;
      
      private var _lastFrameTime:int = 0;
      
      public function NoiseOverlay(param1:int, param2:int, param3:int = 5, param4:Number = 24)
      {
         super();
         this._frames = new Vector.<BitmapData>();
         this._numFrames = param3;
         this._fps = param4;
         this._invFps = 1 / this._fps;
         this._width = param1;
         this._height = param2;
         this.renderFrames();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:BitmapData = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         bitmapData = null;
         this._data = null;
         for each(_loc1_ in this._frames)
         {
            _loc1_.dispose();
         }
         this._frames = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      private function renderFrames() : void
      {
         var _loc2_:BitmapData = null;
         this._frames.length = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this._numFrames)
         {
            _loc2_ = new BitmapData(this._width,this._height,false,0);
            _loc2_.noise(Math.random() * 1000,0,255,7,true);
            this._frames[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      private function update(param1:Event = null) : void
      {
         var _loc2_:Number = getTimer();
         var _loc3_:Number = _loc2_ - this._lastFrameTime;
         this._lastFrameTime = _loc2_;
         this._frameAccumulator += _loc3_ / 1000;
         if(this._frameAccumulator > this._invFps)
         {
            this._frameAccumulator = 0;
            if(++this._frameIndex >= this._numFrames)
            {
               this._frameIndex = 0;
            }
            this._data = this._frames[this._frameIndex];
            bitmapData = this._data;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._lastFrameTime = getTimer();
         this._frameIndex = int(Math.random() * this._numFrames);
         this._data = this._frames[this._frameIndex];
         bitmapData = this._data;
         addEventListener(Event.ENTER_FRAME,this.update);
         this.update(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.update);
      }
   }
}

