package starling.core
{
   import flash.geom.Point;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.textures.Texture;
   
   internal class TouchMarker extends Sprite
   {
      
      private static var TouchMarkerBmp:Class = TouchMarker_TouchMarkerBmp;
      
      private var mCenter:Point;
      
      private var mTexture:Texture;
      
      public function TouchMarker()
      {
         var _loc2_:Image = null;
         super();
         this.mCenter = new Point();
         this.mTexture = Texture.fromBitmap(new TouchMarkerBmp());
         var _loc1_:int = 0;
         while(_loc1_ < 2)
         {
            _loc2_ = new Image(this.mTexture);
            _loc2_.pivotX = this.mTexture.width / 2;
            _loc2_.pivotY = this.mTexture.height / 2;
            _loc2_.touchable = false;
            addChild(_loc2_);
            _loc1_++;
         }
      }
      
      override public function dispose() : void
      {
         this.mTexture.dispose();
         super.dispose();
      }
      
      public function moveMarker(param1:Number, param2:Number, param3:Boolean = false) : void
      {
         if(param3)
         {
            this.mCenter.x += param1 - this.realMarker.x;
            this.mCenter.y += param2 - this.realMarker.y;
         }
         this.realMarker.x = param1;
         this.realMarker.y = param2;
         this.mockMarker.x = 2 * this.mCenter.x - param1;
         this.mockMarker.y = 2 * this.mCenter.y - param2;
      }
      
      public function moveCenter(param1:Number, param2:Number) : void
      {
         this.mCenter.x = param1;
         this.mCenter.y = param2;
         this.moveMarker(this.realX,this.realY);
      }
      
      private function get realMarker() : Image
      {
         return getChildAt(0) as Image;
      }
      
      private function get mockMarker() : Image
      {
         return getChildAt(1) as Image;
      }
      
      public function get realX() : Number
      {
         return this.realMarker.x;
      }
      
      public function get realY() : Number
      {
         return this.realMarker.y;
      }
      
      public function get mockX() : Number
      {
         return this.mockMarker.x;
      }
      
      public function get mockY() : Number
      {
         return this.mockMarker.y;
      }
   }
}

