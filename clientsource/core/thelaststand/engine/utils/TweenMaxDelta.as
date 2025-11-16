package thelaststand.engine.utils
{
   import com.greensock.TweenMax;
   import com.greensock.core.SimpleTimeline;
   import com.greensock.events.TweenEvent;
   
   public class TweenMaxDelta extends TweenMax
   {
      
      private static var _timeElapsed:Number = 0;
      
      private static var _list:Vector.<TweenMaxDelta> = new Vector.<TweenMaxDelta>();
      
      private static var _deltaTimeLine:SimpleTimeline = new SimpleTimeline();
      
      public static var isTweening:Function = TweenMax.isTweening;
      
      _deltaTimeLine.pause();
      
      public function TweenMaxDelta(param1:Object, param2:Number, param3:Object)
      {
         param3.timeline = _deltaTimeLine;
         super(param1,param2,param3);
         addEventListener(TweenEvent.COMPLETE,this.onTweenCompleted,false,0,true);
      }
      
      public static function to(param1:Object, param2:Number, param3:Object) : TweenMaxDelta
      {
         var _loc4_:TweenMaxDelta = new TweenMaxDelta(param1,param2,param3);
         _loc4_.startTime = _timeElapsed + (param3.hasOwnProperty("delay") ? param3.delay : 0);
         _list.push(_loc4_);
         return _loc4_;
      }
      
      public static function delayedCall(param1:Number, param2:Function, param3:Array = null, param4:Boolean = false) : TweenMaxDelta
      {
         return new TweenMaxDelta(param2,0,{
            "delay":param1,
            "onComplete":param2,
            "onCompleteParams":param3,
            "immediateRender":false,
            "useFrames":param4,
            "overwrite":0
         });
      }
      
      public static function killDelayedCallsTo(param1:Function) : void
      {
         TweenMax.killDelayedCallsTo(param1);
      }
      
      public static function from(param1:Object, param2:Number, param3:Object) : TweenMaxDelta
      {
         param3.runBackwards = true;
         if(!("immediateRender" in param3))
         {
            param3.immediateRender = true;
         }
         var _loc4_:TweenMaxDelta = new TweenMaxDelta(param1,param2,param3);
         _loc4_.startTime = _timeElapsed + (param3.hasOwnProperty("delay") ? param3.delay : 0);
         _list.push(_loc4_);
         return _loc4_;
      }
      
      public static function killTweensOf(param1:Object, param2:Boolean = false, param3:Object = null) : void
      {
         var _loc6_:TweenMaxDelta = null;
         var _loc4_:int = 0;
         var _loc5_:int = int(_list.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _list[_loc4_];
            if(_loc6_.target == param1)
            {
               _list.splice(_loc4_,1);
               break;
            }
            _loc4_++;
         }
         TweenMax.killTweensOf(param1,param2,param3);
      }
      
      public static function render(param1:Number, param2:Boolean = false) : void
      {
         _timeElapsed = param1 / 1000;
         _deltaTimeLine.renderTime(_timeElapsed);
      }
      
      private function onTweenCompleted(param1:TweenEvent) : void
      {
         removeEventListener(TweenEvent.COMPLETE,this.onTweenCompleted);
         delete vars.onComplete;
      }
   }
}

