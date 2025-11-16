package starling.display
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   import starling.core.starling_internal;
   import starling.events.EnterFrameEvent;
   import starling.events.Event;
   
   use namespace starling_internal;
   
   public class Stage extends DisplayObjectContainer
   {
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mColor:uint;
      
      private var mEnterFrameEvent:EnterFrameEvent = new EnterFrameEvent(Event.ENTER_FRAME,0);
      
      public function Stage(param1:int, param2:int, param3:uint = 0)
      {
         super();
         this.mWidth = param1;
         this.mHeight = param2;
         this.mColor = param3;
      }
      
      public function advanceTime(param1:Number) : void
      {
         this.mEnterFrameEvent.starling_internal::reset(Event.ENTER_FRAME,false,param1);
         broadcastEvent(this.mEnterFrameEvent);
      }
      
      override public function hitTest(param1:Point, param2:Boolean = false) : DisplayObject
      {
         if(param2 && (!visible || !touchable))
         {
            return null;
         }
         if(param1.x < 0 || param1.x > this.mWidth || param1.y < 0 || param1.y > this.mHeight)
         {
            return null;
         }
         var _loc3_:DisplayObject = super.hitTest(param1,param2);
         if(_loc3_ == null)
         {
            _loc3_ = this;
         }
         return _loc3_;
      }
      
      override public function set width(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set width of stage");
      }
      
      override public function set height(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set height of stage");
      }
      
      override public function set x(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set x-coordinate of stage");
      }
      
      override public function set y(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot set y-coordinate of stage");
      }
      
      override public function set scaleX(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set scaleY(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set rotation(param1:Number) : void
      {
         throw new IllegalOperationError("Cannot rotate stage");
      }
      
      public function get color() : uint
      {
         return this.mColor;
      }
      
      public function set color(param1:uint) : void
      {
         this.mColor = param1;
      }
      
      public function get stageWidth() : int
      {
         return this.mWidth;
      }
      
      public function set stageWidth(param1:int) : void
      {
         this.mWidth = param1;
      }
      
      public function get stageHeight() : int
      {
         return this.mHeight;
      }
      
      public function set stageHeight(param1:int) : void
      {
         this.mHeight = param1;
      }
   }
}

