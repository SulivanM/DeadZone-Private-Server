package thelaststand.app.core
{
   import flash.external.ExternalInterface;
   import playerio.Message;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.Survivor;
   
   public class Tracking
   {
      
      public static const CV_SCOPE_VISITOR:uint = 1;
      
      public static const CV_SCOPE_SESSION:uint = 2;
      
      public static const CV_SCOPE_PAGEVIEW:uint = 3;
      
      public static var buyCoinsSKU:String = "Facebook Credits";
      
      public static var pathPrefix:String = "/game";
      
      public function Tracking()
      {
         super();
         throw new Error("Tracking cannot be directly instantiated.");
      }
      
      public static function setCustomVar(param1:int, param2:String, param3:String, param4:uint = 1) : void
      {
         push("_setCustomVar",param1,param2,param3,param4);
      }
      
      public static function setCustomVarsForPlayer(param1:PlayerData) : void
      {
         var _loc2_:Survivor = null;
         if(param1 == null)
         {
            return;
         }
         try
         {
            if(param1.user != null)
            {
               if(param1.user.gender != null)
               {
                  setCustomVar(1,"Gender",param1.user.gender,CV_SCOPE_VISITOR);
               }
               if(param1.user.age != null)
               {
                  setCustomVar(2,"Age",param1.user.age,CV_SCOPE_VISITOR);
               }
            }
            _loc2_ = param1.getPlayerSurvivor();
            if(_loc2_ != null)
            {
               setCustomVar(3,"Level",String(_loc2_.level),CV_SCOPE_VISITOR);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      public static function trackPageview(param1:String) : void
      {
         push("_trackPageview",pathPrefix + "/" + param1);
      }
      
      public static function trackEvent(param1:String, param2:String, param3:String = null, param4:Number = 0) : void
      {
         push("_trackEvent",param1,param2,param3,param4);
      }
      
      public static function trackEventMessage(param1:Message) : void
      {
         var i:int = 0;
         var msg:Message = param1;
         try
         {
            i = 0;
            trackEvent(msg.getString(i++),msg.getString(i++),msg.getString(i++),msg.getNumber(i++));
         }
         catch(err:Error)
         {
         }
      }
      
      public static function trackCoinPurchaseFB(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:Number = param3 * 0.1;
         push("_addTrans",param1,"",_loc4_.toFixed(2));
         push("_addItem",param1,buyCoinsSKU,"Fuel","x " + param2,_loc4_.toFixed(2),"1");
         push("_trackTrans");
      }
      
      private static function push(... rest) : void
      {
         try
         {
            if(!ExternalInterface.available)
            {
               return;
            }
            ExternalInterface.call("_gaq.push",rest);
         }
         catch(err:Error)
         {
         }
      }
   }
}

