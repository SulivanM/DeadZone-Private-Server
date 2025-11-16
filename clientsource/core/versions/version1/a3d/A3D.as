package versions.version1.a3d
{
   import versions.version1.a3d.geometry.A3DGeometry;
   import versions.version1.a3d.materials.A3DImage;
   import versions.version1.a3d.materials.A3DMap;
   import versions.version1.a3d.materials.A3DMaterial;
   import versions.version1.a3d.objects.A3DBox;
   import versions.version1.a3d.objects.A3DObject;
   
   public class A3D
   {
      
      private var _boxes:Vector.<A3DBox>;
      
      private var _geometries:Vector.<A3DGeometry>;
      
      private var _images:Vector.<A3DImage>;
      
      private var _maps:Vector.<A3DMap>;
      
      private var _materials:Vector.<A3DMaterial>;
      
      private var _objects:Vector.<A3DObject>;
      
      public function A3D(param1:Vector.<A3DBox>, param2:Vector.<A3DGeometry>, param3:Vector.<A3DImage>, param4:Vector.<A3DMap>, param5:Vector.<A3DMaterial>, param6:Vector.<A3DObject>)
      {
         super();
         this._boxes = param1;
         this._geometries = param2;
         this._images = param3;
         this._maps = param4;
         this._materials = param5;
         this._objects = param6;
      }
      
      public function get boxes() : Vector.<A3DBox>
      {
         return this._boxes;
      }
      
      public function set boxes(param1:Vector.<A3DBox>) : void
      {
         this._boxes = param1;
      }
      
      public function get geometries() : Vector.<A3DGeometry>
      {
         return this._geometries;
      }
      
      public function set geometries(param1:Vector.<A3DGeometry>) : void
      {
         this._geometries = param1;
      }
      
      public function get images() : Vector.<A3DImage>
      {
         return this._images;
      }
      
      public function set images(param1:Vector.<A3DImage>) : void
      {
         this._images = param1;
      }
      
      public function get maps() : Vector.<A3DMap>
      {
         return this._maps;
      }
      
      public function set maps(param1:Vector.<A3DMap>) : void
      {
         this._maps = param1;
      }
      
      public function get materials() : Vector.<A3DMaterial>
      {
         return this._materials;
      }
      
      public function set materials(param1:Vector.<A3DMaterial>) : void
      {
         this._materials = param1;
      }
      
      public function get objects() : Vector.<A3DObject>
      {
         return this._objects;
      }
      
      public function set objects(param1:Vector.<A3DObject>) : void
      {
         this._objects = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D [";
         _loc1_ += "boxes = " + this.boxes + " ";
         _loc1_ += "geometries = " + this.geometries + " ";
         _loc1_ += "images = " + this.images + " ";
         _loc1_ += "maps = " + this.maps + " ";
         _loc1_ += "materials = " + this.materials + " ";
         _loc1_ += "objects = " + this.objects + " ";
         return _loc1_ + "]";
      }
   }
}

