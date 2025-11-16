package mx.rpc
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AsyncDispatcher
   {
      
      private var _method:Function;
      
      private var _args:Array;
      
      private var _timer:Timer;
      
      public function AsyncDispatcher(param1:Function, param2:Array, param3:Number)
      {
         super();
         this._method = param1;
         this._args = param2;
         this._timer = new Timer(param3);
         this._timer.addEventListener(TimerEvent.TIMER,this.timerEventHandler);
         this._timer.start();
      }
      
      private function timerEventHandler(param1:TimerEvent) : void
      {
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER,this.timerEventHandler);
         this._method.apply(null,this._args);
      }
   }
}

