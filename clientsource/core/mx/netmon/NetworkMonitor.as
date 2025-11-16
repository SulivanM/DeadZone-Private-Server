package mx.netmon
{
   import flash.events.Event;
   import flash.net.URLRequest;
   
   public class NetworkMonitor
   {
      
      public static var isMonitoringImpl:Function;
      
      public static var adjustURLRequestImpl:Function;
      
      public static var adjustNetConnectionURLImpl:Function;
      
      public static var monitorEventImpl:Function;
      
      public static var monitorInvocationImpl:Function;
      
      public static var monitorResultImpl:Function;
      
      public static var monitorFaultImpl:Function;
      
      public function NetworkMonitor()
      {
         super();
      }
      
      public static function isMonitoring() : Boolean
      {
         return isMonitoringImpl != null ? isMonitoringImpl() : false;
      }
      
      public static function adjustURLRequest(param1:URLRequest, param2:String, param3:String) : void
      {
         if(adjustURLRequestImpl != null)
         {
            adjustURLRequestImpl(param1,param2,param3);
         }
      }
      
      public static function adjustNetConnectionURL(param1:String, param2:String) : String
      {
         if(adjustNetConnectionURLImpl != null)
         {
            return adjustNetConnectionURLImpl(param1,param2);
         }
         return null;
      }
      
      public static function monitorEvent(param1:Event, param2:String) : void
      {
         if(monitorEventImpl != null)
         {
            monitorEventImpl(param1,param2);
         }
      }
      
      public static function monitorInvocation(param1:String, param2:Object, param3:Object) : void
      {
         if(monitorInvocationImpl != null)
         {
            monitorInvocationImpl(param1,param2,param3);
         }
      }
      
      public static function monitorResult(param1:Object, param2:Object) : void
      {
         if(monitorResultImpl != null)
         {
            monitorResultImpl(param1,param2);
         }
      }
      
      public static function monitorFault(param1:Object, param2:Object) : void
      {
         if(monitorFaultImpl != null)
         {
            monitorFaultImpl(param1,param2);
         }
      }
   }
}

