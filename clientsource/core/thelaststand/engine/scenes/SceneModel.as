package thelaststand.engine.scenes
{
   import alternativa.engine3d.core.Object3D;
   import thelaststand.engine.animation.IAnimatingObject;
   import thelaststand.engine.meshes.MeshGroup;
   
   public class SceneModel extends MeshGroup implements IAnimatingObject
   {
      
      private var _animatingChildren:Vector.<IAnimatingObject>;
      
      public function SceneModel()
      {
         super();
         name = "$scene-model";
         mouseEnabled = mouseChildren = false;
         this._animatingChildren = new Vector.<IAnimatingObject>();
      }
      
      public function updateAnimation(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(this._animatingChildren.length);
         while(_loc2_ < _loc3_)
         {
            this._animatingChildren[_loc2_].updateAnimation(param1);
            _loc2_++;
         }
      }
      
      override public function addChildrenFromResource(param1:String, param2:Boolean = false, param3:Vector.<Object3D> = null) : void
      {
         var _loc6_:IAnimatingObject = null;
         super.addChildrenFromResource(param1,param2,param3);
         this._animatingChildren.length = 0;
         var _loc4_:int = 0;
         var _loc5_:int = numChildren;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = getChildAt(_loc4_) as IAnimatingObject;
            if(_loc6_ != null)
            {
               this._animatingChildren.push(_loc6_);
            }
            _loc4_++;
         }
      }
   }
}

