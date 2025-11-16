package alternativa.engine3d.loaders.collada
{
   use namespace collada;
   
   public class DaeVisualScene extends DaeElement
   {
      
      public var nodes:Vector.<DaeNode>;
      
      public function DaeVisualScene(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
         this.constructNodes();
      }
      
      public function constructNodes() : void
      {
         var _loc4_:DaeNode = null;
         var _loc1_:XMLList = data.node;
         var _loc2_:int = int(_loc1_.length());
         this.nodes = new Vector.<DaeNode>(_loc2_);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = new DaeNode(_loc1_[_loc3_],document,this);
            if(_loc4_.id != null)
            {
               document.nodes[_loc4_.id] = _loc4_;
            }
            this.nodes[_loc3_] = _loc4_;
            _loc3_++;
         }
      }
   }
}

