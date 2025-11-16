package alternativa.engine3d.core
{
   public class CullingPlane
   {
      
      public static var collector:CullingPlane;
      
      public var x:Number;
      
      public var y:Number;
      
      public var z:Number;
      
      public var offset:Number;
      
      public var next:CullingPlane;
      
      public function CullingPlane()
      {
         super();
      }
      
      public static function create() : CullingPlane
      {
         var _loc1_:CullingPlane = null;
         if(collector != null)
         {
            _loc1_ = collector;
            collector = _loc1_.next;
            _loc1_.next = null;
            return _loc1_;
         }
         return new CullingPlane();
      }
      
      public function create() : CullingPlane
      {
         var _loc1_:CullingPlane = null;
         if(collector != null)
         {
            _loc1_ = collector;
            collector = _loc1_.next;
            _loc1_.next = null;
            return _loc1_;
         }
         return new CullingPlane();
      }
   }
}

