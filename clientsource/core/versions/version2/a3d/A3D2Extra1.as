package versions.version2.a3d
{
   import versions.version2.a3d.objects.A3D2Layer;
   
   public class A3D2Extra1
   {
      
      private var _layers:Vector.<A3D2Layer>;
      
      public function A3D2Extra1(param1:Vector.<A3D2Layer>)
      {
         super();
         this._layers = param1;
      }
      
      public function get layers() : Vector.<A3D2Layer>
      {
         return this._layers;
      }
      
      public function set layers(param1:Vector.<A3D2Layer>) : void
      {
         this._layers = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Extra1 [";
         _loc1_ += "layers = " + this.layers + " ";
         return _loc1_ + "]";
      }
   }
}

