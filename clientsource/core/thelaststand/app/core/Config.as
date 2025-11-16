package thelaststand.app.core
{
   import flash.system.Security;
   import thelaststand.common.resources.ResourceManager;
   
   public dynamic class Config
   {
      
      public static var xml:XML;
      
      public static var constant:Object;
      
      public function Config()
      {
         super();
         throw new Error("Config cannot be directly instantiated.");
      }
      
      public static function init() : void
      {
         parse(ResourceManager.getInstance().getResource("xml/config.xml").content as XML);
      }
      
      public static function getPath(param1:String) : String
      {
         var _loc2_:Array = param1.split(".");
         var _loc3_:XML = xml.paths[0];
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc3_[_loc2_[_loc4_]][0];
            if(_loc3_ == null)
            {
               throw new Error("Path \'" + param1 + "\' is not defined.");
            }
            _loc4_++;
         }
         return _loc3_.toString();
      }
      
      public static function runSecurityPolicies() : void
      {
         var _loc1_:String = null;
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         if(Config.xml == null)
         {
            return;
         }
         for each(_loc2_ in Config.xml.security.policy)
         {
            _loc1_ = _loc2_.toString();
            Security.loadPolicyFile(_loc1_);
         }
         for each(_loc3_ in Config.xml.security.domain + Config.xml.security.insecure_domain)
         {
            _loc1_ = _loc3_.toString();
            if(_loc3_.localName() == "insecure_domain")
            {
               Security.allowInsecureDomain(_loc1_);
            }
            else
            {
               Security.allowDomain(_loc1_);
            }
         }
      }
      
      public static function parse(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         Config.xml = param1;
         constant = {};
         for each(_loc2_ in param1.children())
         {
            if(_loc2_.text().length() != 0)
            {
               _loc3_ = _loc2_.localName();
               _loc4_ = _loc2_.toString();
               _loc5_ = Number(_loc4_);
               if(!(_loc3_ == null || _loc4_ == null || _loc4_.length == 0))
               {
                  Config.constant[_loc3_] = isNaN(_loc5_) ? _loc4_ : _loc5_;
               }
            }
         }
      }
   }
}

