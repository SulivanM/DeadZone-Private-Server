package alternativa.engine3d.loaders.collada
{
   import flash.geom.Vector3D;
   
   public class DaeVertex
   {
      
      public var vertexInIndex:int;
      
      public var vertexOutIndex:int;
      
      public var indices:Vector.<int> = new Vector.<int>();
      
      public var x:Number;
      
      public var y:Number;
      
      public var z:Number;
      
      public var uvs:Vector.<Number> = new Vector.<Number>();
      
      public var normal:Vector3D;
      
      public var tangent:Vector3D;
      
      public function DaeVertex()
      {
         super();
      }
      
      public function addPosition(param1:Vector.<Number>, param2:int, param3:int, param4:Number) : void
      {
         this.indices.push(param2);
         var _loc5_:int = param3 * param2;
         this.x = param1[int(_loc5_)] * param4;
         this.y = param1[int(_loc5_ + 1)] * param4;
         this.z = param1[int(_loc5_ + 2)] * param4;
      }
      
      public function addNormal(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         this.indices.push(param2);
         var _loc4_:int = param3 * param2;
         this.normal = new Vector3D();
         this.normal.x = param1[int(_loc4_++)];
         this.normal.y = param1[int(_loc4_++)];
         this.normal.z = param1[_loc4_];
      }
      
      public function addTangentBiDirection(param1:Vector.<Number>, param2:int, param3:int, param4:Vector.<Number>, param5:int, param6:int) : void
      {
         this.indices.push(param2);
         this.indices.push(param5);
         var _loc7_:int = param3 * param2;
         var _loc8_:int = param6 * param5;
         var _loc9_:Number = param4[int(_loc8_++)];
         var _loc10_:Number = param4[int(_loc8_++)];
         var _loc11_:Number = param4[_loc8_];
         this.tangent = new Vector3D(param1[int(_loc7_++)],param1[int(_loc7_++)],param1[_loc7_]);
         var _loc12_:Number = this.normal.y * this.tangent.z - this.normal.z * this.tangent.y;
         var _loc13_:Number = this.normal.z * this.tangent.x - this.normal.x * this.tangent.z;
         var _loc14_:Number = this.normal.x * this.tangent.y - this.normal.y * this.tangent.x;
         var _loc15_:Number = _loc12_ * _loc9_ + _loc13_ * _loc10_ + _loc14_ * _loc11_;
         this.tangent.w = _loc15_ < 0 ? -1 : 1;
      }
      
      public function appendUV(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         this.indices.push(param2);
         this.uvs.push(param1[int(param2 * param3)]);
         this.uvs.push(1 - param1[int(param2 * param3 + 1)]);
      }
   }
}

