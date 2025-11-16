package versions.version2.a3d.geometry
{
   public class A3D2VertexAttributes
   {
      
      public static const POSITION:A3D2VertexAttributes = new A3D2VertexAttributes(0);
      
      public static const NORMAL:A3D2VertexAttributes = new A3D2VertexAttributes(1);
      
      public static const TANGENT4:A3D2VertexAttributes = new A3D2VertexAttributes(2);
      
      public static const JOINT:A3D2VertexAttributes = new A3D2VertexAttributes(3);
      
      public static const TEXCOORD:A3D2VertexAttributes = new A3D2VertexAttributes(4);
      
      public var value:int;
      
      public function A3D2VertexAttributes(param1:int)
      {
         super();
         this.value = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:* = "A3D2VertexAttributes [";
         if(this.value == 0)
         {
            _loc1_ += "POSITION";
         }
         if(this.value == 1)
         {
            _loc1_ += "NORMAL";
         }
         if(this.value == 2)
         {
            _loc1_ += "TANGENT4";
         }
         if(this.value == 3)
         {
            _loc1_ += "JOINT";
         }
         if(this.value == 4)
         {
            _loc1_ += "TEXCOORD";
         }
         return _loc1_ + "]";
      }
   }
}

