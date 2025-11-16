package com.deadreckoned.threshold.navigation.rvo
{
   public final class AgentKeyValuePair
   {
      
      public var key:Number;
      
      public var value:RVOAgent;
      
      public function AgentKeyValuePair(param1:Number = NaN, param2:RVOAgent = null)
      {
         super();
         this.key = param1;
         this.value = param2;
      }
   }
}

