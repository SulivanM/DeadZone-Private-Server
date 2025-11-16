package alternativa.engine3d.loaders.collada
{
   public class DaeLogger
   {
      
      public function DaeLogger()
      {
         super();
      }
      
      private function logMessage(param1:String, param2:XML) : void
      {
         var _loc3_:int = 0;
         var _loc4_:String = param2.nodeKind() == "attribute" ? "@" + param2.localName() : param2.localName() + (_loc3_ > 0 ? "[" + _loc3_ + "]" : "");
         var _loc5_:* = param2.parent();
         while(_loc5_ != null)
         {
            _loc4_ = _loc5_.localName() + (_loc3_ > 0 ? "[" + _loc3_ + "]" : "") + "." + _loc4_;
            _loc5_ = _loc5_.parent();
         }
      }
      
      private function logError(param1:String, param2:XML) : void
      {
         this.logMessage("[ERROR] " + param1,param2);
      }
      
      public function logExternalError(param1:XML) : void
      {
         this.logError("External urls don\'t supported",param1);
      }
      
      public function logSkewError(param1:XML) : void
      {
         this.logError("<skew> don\'t supported",param1);
      }
      
      public function logJointInAnotherSceneError(param1:XML) : void
      {
         this.logError("Joints in different scenes don\'t supported",param1);
      }
      
      public function logInstanceNodeError(param1:XML) : void
      {
         this.logError("<instance_node> don\'t supported",param1);
      }
      
      public function logNotFoundError(param1:XML) : void
      {
         this.logError("Element with url \"" + param1.toString() + "\" not found",param1);
      }
      
      public function logNotEnoughDataError(param1:XML) : void
      {
         this.logError("Not enough data",param1);
      }
   }
}

