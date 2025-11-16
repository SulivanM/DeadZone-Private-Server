package versions.version2.a3d
{
   import versions.version2.a3d.objects.A3D2Camera;
   import versions.version2.a3d.objects.A3D2LOD;
   
   public class A3D2Extra2
   {
      
      private var _cameras:Vector.<A3D2Camera>;
      
      private var _lods:Vector.<A3D2LOD>;
      
      public function A3D2Extra2(param1:Vector.<A3D2Camera>, param2:Vector.<A3D2LOD>)
      {
         super();
         this._cameras = param1;
         this._lods = param2;
      }
      
      public function get cameras() : Vector.<A3D2Camera>
      {
         return this._cameras;
      }
      
      public function set cameras(param1:Vector.<A3D2Camera>) : void
      {
         this._cameras = param1;
      }
      
      public function get lods() : Vector.<A3D2LOD>
      {
         return this._lods;
      }
      
      public function set lods(param1:Vector.<A3D2LOD>) : void
      {
         this._lods = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Extra2 [";
         _loc1_ += "cameras = " + this.cameras + " ";
         _loc1_ += "lods = " + this.lods + " ";
         return _loc1_ + "]";
      }
   }
}

