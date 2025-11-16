package alternativa.engine3d.animation
{
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   
   public class AnimationNode
   {
      
      alternativa3d var _isActive:Boolean = false;
      
      alternativa3d var _parent:AnimationNode;
      
      alternativa3d var controller:AnimationController;
      
      public var speed:Number = 1;
      
      public function AnimationNode()
      {
         super();
      }
      
      public function get isActive() : Boolean
      {
         return this.alternativa3d::_isActive && this.alternativa3d::controller != null;
      }
      
      public function get parent() : AnimationNode
      {
         return this.alternativa3d::_parent;
      }
      
      alternativa3d function update(param1:Number, param2:Number) : void
      {
      }
      
      alternativa3d function setController(param1:AnimationController) : void
      {
         this.alternativa3d::controller = param1;
      }
      
      alternativa3d function addNode(param1:AnimationNode) : void
      {
         if(param1.alternativa3d::_parent != null)
         {
            param1.alternativa3d::_parent.alternativa3d::removeNode(param1);
         }
         param1.alternativa3d::_parent = this;
         param1.alternativa3d::setController(this.alternativa3d::controller);
      }
      
      alternativa3d function removeNode(param1:AnimationNode) : void
      {
         param1.alternativa3d::setController(null);
         param1.alternativa3d::_isActive = false;
         param1.alternativa3d::_parent = null;
      }
   }
}

