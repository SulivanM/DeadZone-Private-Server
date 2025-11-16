package starling.display
{
   import flash.geom.Matrix;
   import starling.core.RenderSupport;
   import starling.events.Event;
   
   public class Sprite extends DisplayObjectContainer
   {
      
      private var mFlattenedContents:Vector.<QuadBatch>;
      
      private var mFlattenRequested:Boolean;
      
      public function Sprite()
      {
         super();
      }
      
      override public function dispose() : void
      {
         this.disposeFlattenedContents();
         super.dispose();
      }
      
      private function disposeFlattenedContents() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.mFlattenedContents)
         {
            _loc1_ = 0;
            _loc2_ = int(this.mFlattenedContents.length);
            while(_loc1_ < _loc2_)
            {
               this.mFlattenedContents[_loc1_].dispose();
               _loc1_++;
            }
            this.mFlattenedContents = null;
         }
      }
      
      public function flatten() : void
      {
         this.mFlattenRequested = true;
         broadcastEventWith(Event.FLATTEN);
      }
      
      public function unflatten() : void
      {
         this.mFlattenRequested = false;
         this.disposeFlattenedContents();
      }
      
      public function get isFlattened() : Boolean
      {
         return Boolean(this.mFlattenedContents) || this.mFlattenRequested;
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc5_:Matrix = null;
         var _loc6_:int = 0;
         var _loc7_:QuadBatch = null;
         var _loc8_:String = null;
         if(Boolean(this.mFlattenedContents) || this.mFlattenRequested)
         {
            if(this.mFlattenedContents == null)
            {
               this.mFlattenedContents = new Vector.<QuadBatch>(0);
            }
            if(this.mFlattenRequested)
            {
               QuadBatch.compile(this,this.mFlattenedContents);
               this.mFlattenRequested = false;
            }
            _loc3_ = param2 * this.alpha;
            _loc4_ = int(this.mFlattenedContents.length);
            _loc5_ = param1.mvpMatrix;
            param1.finishQuadBatch();
            param1.raiseDrawCount(_loc4_);
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc7_ = this.mFlattenedContents[_loc6_];
               _loc8_ = _loc7_.blendMode == BlendMode.AUTO ? param1.blendMode : _loc7_.blendMode;
               _loc7_.renderCustom(_loc5_,_loc3_,_loc8_);
               _loc6_++;
            }
         }
         else
         {
            super.render(param1,param2);
         }
      }
   }
}

