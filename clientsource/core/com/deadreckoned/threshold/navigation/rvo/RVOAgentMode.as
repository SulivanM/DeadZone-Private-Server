package com.deadreckoned.threshold.navigation.rvo
{
   public class RVOAgentMode
   {
      
      public static const FREE:uint = 0;
      
      public static const GROUP_ONLY:uint = 1;
      
      public static const STATIC:uint = 2;
      
      public function RVOAgentMode()
      {
         super();
      }
      
      public function NavigatorMode() : void
      {
         throw new Error("NavigatorMode cannot be directly instantiated.");
      }
   }
}

