package alternativa.engine3d.loaders.collada
{
   import flash.utils.Dictionary;
   
   use namespace collada;
   
   public class DaeInstanceController extends DaeElement
   {
      
      public var node:DaeNode;
      
      public var topmostJoints:Vector.<DaeNode>;
      
      public function DaeInstanceController(param1:XML, param2:DaeDocument, param3:DaeNode)
      {
         super(param1,param2);
         this.node = param3;
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc1_:DaeController = this.controller;
         if(_loc1_ != null)
         {
            this.topmostJoints = _loc1_.findRootJointNodes(this.skeletons);
            if(this.topmostJoints != null && this.topmostJoints.length > 1)
            {
               this.replaceNodesByTopmost(this.topmostJoints);
            }
         }
         return this.topmostJoints != null;
      }
      
      private function replaceNodesByTopmost(param1:Vector.<DaeNode>) : void
      {
         var _loc2_:int = 0;
         var _loc3_:DaeNode = null;
         var _loc4_:DaeNode = null;
         var _loc5_:int = int(param1.length);
         var _loc6_:Dictionary = new Dictionary();
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc3_ = param1[_loc2_];
            _loc4_ = _loc3_.parent;
            while(_loc4_ != null)
            {
               if(_loc6_[_loc4_])
               {
                  ++_loc6_[_loc4_];
               }
               else
               {
                  _loc6_[_loc4_] = 1;
               }
               _loc4_ = _loc4_.parent;
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc3_ = param1[_loc2_];
            while(true)
            {
               _loc4_ = _loc3_.parent;
               if(!(_loc4_ != null && _loc6_[_loc4_] != _loc5_))
               {
                  break;
               }
               _loc3_ = _loc3_.parent;
            }
            param1[_loc2_] = _loc3_;
            _loc2_++;
         }
      }
      
      private function get controller() : DaeController
      {
         var _loc1_:DaeController = document.findController(data.@url[0]);
         if(_loc1_ == null)
         {
            document.logger.logNotFoundError(data.@url[0]);
         }
         return _loc1_;
      }
      
      private function get skeletons() : Vector.<DaeNode>
      {
         var _loc2_:Vector.<DaeNode> = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         var _loc6_:DaeNode = null;
         var _loc1_:XMLList = data.skeleton;
         if(_loc1_.length() > 0)
         {
            _loc2_ = new Vector.<DaeNode>();
            _loc3_ = 0;
            _loc4_ = int(_loc1_.length());
            while(_loc3_ < _loc4_)
            {
               _loc5_ = _loc1_[_loc3_];
               _loc6_ = document.findNode(_loc5_.text()[0]);
               if(_loc6_ != null)
               {
                  _loc2_.push(_loc6_);
               }
               else
               {
                  document.logger.logNotFoundError(_loc5_);
               }
               _loc3_++;
            }
            return _loc2_;
         }
         return null;
      }
      
      public function parseSkin(param1:Object) : DaeObject
      {
         var _loc2_:DaeController = this.controller;
         if(_loc2_ != null)
         {
            _loc2_.parse();
            return _loc2_.parseSkin(param1,this.topmostJoints,this.skeletons);
         }
         return null;
      }
   }
}

