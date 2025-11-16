package thelaststand.common.resources
{
   import flash.utils.Dictionary;
   import thelaststand.engine.animation.AnimationTable;
   
   public class AnimationLibrary
   {
      
      private var _animsTablesByURI:Dictionary;
      
      public function AnimationLibrary()
      {
         super();
         this._animsTablesByURI = new Dictionary(true);
      }
      
      public function dispose() : void
      {
         this.purge();
         this._animsTablesByURI = null;
      }
      
      public function getAnimationTable(param1:String) : AnimationTable
      {
         var _loc2_:AnimationTable = null;
         if(this._animsTablesByURI[param1] == null)
         {
            _loc2_ = new AnimationTable(param1);
            if(_loc2_.numAnimations > 0)
            {
               this._animsTablesByURI[param1] = _loc2_;
            }
         }
         return this._animsTablesByURI[param1];
      }
      
      public function purge(param1:String = null) : void
      {
         var _loc2_:AnimationTable = null;
         if(param1)
         {
            param1 = param1.toLowerCase();
            if(this._animsTablesByURI[param1] != null)
            {
               AnimationTable(this._animsTablesByURI[param1]).dispose();
               this._animsTablesByURI[param1] = null;
               delete this._animsTablesByURI[param1];
            }
            return;
         }
         for each(_loc2_ in this._animsTablesByURI)
         {
            _loc2_.dispose();
         }
         this._animsTablesByURI = new Dictionary(true);
      }
   }
}

