package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.core.Object3D;
   
   public class DaeObject
   {
      
      public var object:Object3D;
      
      public var animation:AnimationClip;
      
      public var jointNode:DaeNode;
      
      public function DaeObject(param1:Object3D, param2:AnimationClip = null)
      {
         super();
         this.object = param1;
         this.animation = param2;
      }
   }
}

