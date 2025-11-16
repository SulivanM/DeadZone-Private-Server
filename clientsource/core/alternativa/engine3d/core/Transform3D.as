package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   
   public class Transform3D
   {
      
      public var a:Number = 1;
      
      public var b:Number = 0;
      
      public var c:Number = 0;
      
      public var d:Number = 0;
      
      public var e:Number = 0;
      
      public var f:Number = 1;
      
      public var g:Number = 0;
      
      public var h:Number = 0;
      
      public var i:Number = 0;
      
      public var j:Number = 0;
      
      public var k:Number = 1;
      
      public var l:Number = 0;
      
      public function Transform3D()
      {
         super();
      }
      
      public function identity() : void
      {
         this.a = 1;
         this.b = 0;
         this.c = 0;
         this.d = 0;
         this.e = 0;
         this.f = 1;
         this.g = 0;
         this.h = 0;
         this.i = 0;
         this.j = 0;
         this.k = 1;
         this.l = 0;
      }
      
      public function compose(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number) : void
      {
         var _loc10_:Number = Math.cos(param4);
         var _loc11_:Number = Math.sin(param4);
         var _loc12_:Number = Math.cos(param5);
         var _loc13_:Number = Math.sin(param5);
         var _loc14_:Number = Math.cos(param6);
         var _loc15_:Number = Math.sin(param6);
         var _loc16_:Number = _loc14_ * _loc13_;
         var _loc17_:Number = _loc15_ * _loc13_;
         var _loc18_:Number = _loc12_ * param7;
         var _loc19_:Number = _loc11_ * param8;
         var _loc20_:Number = _loc10_ * param8;
         var _loc21_:Number = _loc10_ * param9;
         var _loc22_:Number = _loc11_ * param9;
         this.a = _loc14_ * _loc18_;
         this.b = _loc16_ * _loc19_ - _loc15_ * _loc20_;
         this.c = _loc16_ * _loc21_ + _loc15_ * _loc22_;
         this.d = param1;
         this.e = _loc15_ * _loc18_;
         this.f = _loc17_ * _loc19_ + _loc14_ * _loc20_;
         this.g = _loc17_ * _loc21_ - _loc14_ * _loc22_;
         this.h = param2;
         this.i = -_loc13_ * param7;
         this.j = _loc12_ * _loc19_;
         this.k = _loc12_ * _loc21_;
         this.l = param3;
      }
      
      public function composeInverse(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number) : void
      {
         var _loc10_:Number = Math.cos(param4);
         var _loc11_:Number = Math.sin(-param4);
         var _loc12_:Number = Math.cos(param5);
         var _loc13_:Number = Math.sin(-param5);
         var _loc14_:Number = Math.cos(param6);
         var _loc15_:Number = Math.sin(-param6);
         var _loc16_:Number = _loc11_ * _loc13_;
         var _loc17_:Number = _loc12_ / param7;
         var _loc18_:Number = _loc10_ / param8;
         var _loc19_:Number = _loc11_ / param9;
         var _loc20_:Number = _loc10_ / param9;
         this.a = _loc14_ * _loc17_;
         this.b = -_loc15_ * _loc17_;
         this.c = _loc13_ / param7;
         this.d = -this.a * param1 - this.b * param2 - this.c * param3;
         this.e = _loc15_ * _loc18_ + _loc16_ * _loc14_ / param8;
         this.f = _loc14_ * _loc18_ - _loc16_ * _loc15_ / param8;
         this.g = -_loc11_ * _loc12_ / param8;
         this.h = -this.e * param1 - this.f * param2 - this.g * param3;
         this.i = _loc15_ * _loc19_ - _loc14_ * _loc13_ * _loc20_;
         this.j = _loc14_ * _loc19_ + _loc13_ * _loc15_ * _loc20_;
         this.k = _loc12_ * _loc20_;
         this.l = -this.i * param1 - this.j * param2 - this.k * param3;
      }
      
      public function invert() : void
      {
         var _loc1_:Number = this.a;
         var _loc2_:Number = this.b;
         var _loc3_:Number = this.c;
         var _loc4_:Number = this.d;
         var _loc5_:Number = this.e;
         var _loc6_:Number = this.f;
         var _loc7_:Number = this.g;
         var _loc8_:Number = this.h;
         var _loc9_:Number = this.i;
         var _loc10_:Number = this.j;
         var _loc11_:Number = this.k;
         var _loc12_:Number = this.l;
         var _loc13_:Number = 1 / (-_loc3_ * _loc6_ * _loc9_ + _loc2_ * _loc7_ * _loc9_ + _loc3_ * _loc5_ * _loc10_ - _loc1_ * _loc7_ * _loc10_ - _loc2_ * _loc5_ * _loc11_ + _loc1_ * _loc6_ * _loc11_);
         this.a = (-_loc7_ * _loc10_ + _loc6_ * _loc11_) * _loc13_;
         this.b = (_loc3_ * _loc10_ - _loc2_ * _loc11_) * _loc13_;
         this.c = (-_loc3_ * _loc6_ + _loc2_ * _loc7_) * _loc13_;
         this.d = (_loc4_ * _loc7_ * _loc10_ - _loc3_ * _loc8_ * _loc10_ - _loc4_ * _loc6_ * _loc11_ + _loc2_ * _loc8_ * _loc11_ + _loc3_ * _loc6_ * _loc12_ - _loc2_ * _loc7_ * _loc12_) * _loc13_;
         this.e = (_loc7_ * _loc9_ - _loc5_ * _loc11_) * _loc13_;
         this.f = (-_loc3_ * _loc9_ + _loc1_ * _loc11_) * _loc13_;
         this.g = (_loc3_ * _loc5_ - _loc1_ * _loc7_) * _loc13_;
         this.h = (_loc3_ * _loc8_ * _loc9_ - _loc4_ * _loc7_ * _loc9_ + _loc4_ * _loc5_ * _loc11_ - _loc1_ * _loc8_ * _loc11_ - _loc3_ * _loc5_ * _loc12_ + _loc1_ * _loc7_ * _loc12_) * _loc13_;
         this.i = (-_loc6_ * _loc9_ + _loc5_ * _loc10_) * _loc13_;
         this.j = (_loc2_ * _loc9_ - _loc1_ * _loc10_) * _loc13_;
         this.k = (-_loc2_ * _loc5_ + _loc1_ * _loc6_) * _loc13_;
         this.l = (_loc4_ * _loc6_ * _loc9_ - _loc2_ * _loc8_ * _loc9_ - _loc4_ * _loc5_ * _loc10_ + _loc1_ * _loc8_ * _loc10_ + _loc2_ * _loc5_ * _loc12_ - _loc1_ * _loc6_ * _loc12_) * _loc13_;
      }
      
      public function initFromVector(param1:Vector.<Number>) : void
      {
         this.a = param1[0];
         this.b = param1[1];
         this.c = param1[2];
         this.d = param1[3];
         this.e = param1[4];
         this.f = param1[5];
         this.g = param1[6];
         this.h = param1[7];
         this.i = param1[8];
         this.j = param1[9];
         this.k = param1[10];
         this.l = param1[11];
      }
      
      public function append(param1:Transform3D) : void
      {
         var _loc2_:Number = this.a;
         var _loc3_:Number = this.b;
         var _loc4_:Number = this.c;
         var _loc5_:Number = this.d;
         var _loc6_:Number = this.e;
         var _loc7_:Number = this.f;
         var _loc8_:Number = this.g;
         var _loc9_:Number = this.h;
         var _loc10_:Number = this.i;
         var _loc11_:Number = this.j;
         var _loc12_:Number = this.k;
         var _loc13_:Number = this.l;
         this.a = param1.a * _loc2_ + param1.b * _loc6_ + param1.c * _loc10_;
         this.b = param1.a * _loc3_ + param1.b * _loc7_ + param1.c * _loc11_;
         this.c = param1.a * _loc4_ + param1.b * _loc8_ + param1.c * _loc12_;
         this.d = param1.a * _loc5_ + param1.b * _loc9_ + param1.c * _loc13_ + param1.d;
         this.e = param1.e * _loc2_ + param1.f * _loc6_ + param1.g * _loc10_;
         this.f = param1.e * _loc3_ + param1.f * _loc7_ + param1.g * _loc11_;
         this.g = param1.e * _loc4_ + param1.f * _loc8_ + param1.g * _loc12_;
         this.h = param1.e * _loc5_ + param1.f * _loc9_ + param1.g * _loc13_ + param1.h;
         this.i = param1.i * _loc2_ + param1.j * _loc6_ + param1.k * _loc10_;
         this.j = param1.i * _loc3_ + param1.j * _loc7_ + param1.k * _loc11_;
         this.k = param1.i * _loc4_ + param1.j * _loc8_ + param1.k * _loc12_;
         this.l = param1.i * _loc5_ + param1.j * _loc9_ + param1.k * _loc13_ + param1.l;
      }
      
      public function prepend(param1:Transform3D) : void
      {
         var _loc2_:Number = this.a;
         var _loc3_:Number = this.b;
         var _loc4_:Number = this.c;
         var _loc5_:Number = this.d;
         var _loc6_:Number = this.e;
         var _loc7_:Number = this.f;
         var _loc8_:Number = this.g;
         var _loc9_:Number = this.h;
         var _loc10_:Number = this.i;
         var _loc11_:Number = this.j;
         var _loc12_:Number = this.k;
         var _loc13_:Number = this.l;
         this.a = _loc2_ * param1.a + _loc3_ * param1.e + _loc4_ * param1.i;
         this.b = _loc2_ * param1.b + _loc3_ * param1.f + _loc4_ * param1.j;
         this.c = _loc2_ * param1.c + _loc3_ * param1.g + _loc4_ * param1.k;
         this.d = _loc2_ * param1.d + _loc3_ * param1.h + _loc4_ * param1.l + _loc5_;
         this.e = _loc6_ * param1.a + _loc7_ * param1.e + _loc8_ * param1.i;
         this.f = _loc6_ * param1.b + _loc7_ * param1.f + _loc8_ * param1.j;
         this.g = _loc6_ * param1.c + _loc7_ * param1.g + _loc8_ * param1.k;
         this.h = _loc6_ * param1.d + _loc7_ * param1.h + _loc8_ * param1.l + _loc9_;
         this.i = _loc10_ * param1.a + _loc11_ * param1.e + _loc12_ * param1.i;
         this.j = _loc10_ * param1.b + _loc11_ * param1.f + _loc12_ * param1.j;
         this.k = _loc10_ * param1.c + _loc11_ * param1.g + _loc12_ * param1.k;
         this.l = _loc10_ * param1.d + _loc11_ * param1.h + _loc12_ * param1.l + _loc13_;
      }
      
      public function combine(param1:Transform3D, param2:Transform3D) : void
      {
         this.a = param1.a * param2.a + param1.b * param2.e + param1.c * param2.i;
         this.b = param1.a * param2.b + param1.b * param2.f + param1.c * param2.j;
         this.c = param1.a * param2.c + param1.b * param2.g + param1.c * param2.k;
         this.d = param1.a * param2.d + param1.b * param2.h + param1.c * param2.l + param1.d;
         this.e = param1.e * param2.a + param1.f * param2.e + param1.g * param2.i;
         this.f = param1.e * param2.b + param1.f * param2.f + param1.g * param2.j;
         this.g = param1.e * param2.c + param1.f * param2.g + param1.g * param2.k;
         this.h = param1.e * param2.d + param1.f * param2.h + param1.g * param2.l + param1.h;
         this.i = param1.i * param2.a + param1.j * param2.e + param1.k * param2.i;
         this.j = param1.i * param2.b + param1.j * param2.f + param1.k * param2.j;
         this.k = param1.i * param2.c + param1.j * param2.g + param1.k * param2.k;
         this.l = param1.i * param2.d + param1.j * param2.h + param1.k * param2.l + param1.l;
      }
      
      public function calculateInversion(param1:Transform3D) : void
      {
         var _loc2_:Number = param1.a;
         var _loc3_:Number = param1.b;
         var _loc4_:Number = param1.c;
         var _loc5_:Number = param1.d;
         var _loc6_:Number = param1.e;
         var _loc7_:Number = param1.f;
         var _loc8_:Number = param1.g;
         var _loc9_:Number = param1.h;
         var _loc10_:Number = param1.i;
         var _loc11_:Number = param1.j;
         var _loc12_:Number = param1.k;
         var _loc13_:Number = param1.l;
         var _loc14_:Number = 1 / (-_loc4_ * _loc7_ * _loc10_ + _loc3_ * _loc8_ * _loc10_ + _loc4_ * _loc6_ * _loc11_ - _loc2_ * _loc8_ * _loc11_ - _loc3_ * _loc6_ * _loc12_ + _loc2_ * _loc7_ * _loc12_);
         this.a = (-_loc8_ * _loc11_ + _loc7_ * _loc12_) * _loc14_;
         this.b = (_loc4_ * _loc11_ - _loc3_ * _loc12_) * _loc14_;
         this.c = (-_loc4_ * _loc7_ + _loc3_ * _loc8_) * _loc14_;
         this.d = (_loc5_ * _loc8_ * _loc11_ - _loc4_ * _loc9_ * _loc11_ - _loc5_ * _loc7_ * _loc12_ + _loc3_ * _loc9_ * _loc12_ + _loc4_ * _loc7_ * _loc13_ - _loc3_ * _loc8_ * _loc13_) * _loc14_;
         this.e = (_loc8_ * _loc10_ - _loc6_ * _loc12_) * _loc14_;
         this.f = (-_loc4_ * _loc10_ + _loc2_ * _loc12_) * _loc14_;
         this.g = (_loc4_ * _loc6_ - _loc2_ * _loc8_) * _loc14_;
         this.h = (_loc4_ * _loc9_ * _loc10_ - _loc5_ * _loc8_ * _loc10_ + _loc5_ * _loc6_ * _loc12_ - _loc2_ * _loc9_ * _loc12_ - _loc4_ * _loc6_ * _loc13_ + _loc2_ * _loc8_ * _loc13_) * _loc14_;
         this.i = (-_loc7_ * _loc10_ + _loc6_ * _loc11_) * _loc14_;
         this.j = (_loc3_ * _loc10_ - _loc2_ * _loc11_) * _loc14_;
         this.k = (-_loc3_ * _loc6_ + _loc2_ * _loc7_) * _loc14_;
         this.l = (_loc5_ * _loc7_ * _loc10_ - _loc3_ * _loc9_ * _loc10_ - _loc5_ * _loc6_ * _loc11_ + _loc2_ * _loc9_ * _loc11_ + _loc3_ * _loc6_ * _loc13_ - _loc2_ * _loc7_ * _loc13_) * _loc14_;
      }
      
      public function copy(param1:Transform3D) : void
      {
         this.a = param1.a;
         this.b = param1.b;
         this.c = param1.c;
         this.d = param1.d;
         this.e = param1.e;
         this.f = param1.f;
         this.g = param1.g;
         this.h = param1.h;
         this.i = param1.i;
         this.j = param1.j;
         this.k = param1.k;
         this.l = param1.l;
      }
      
      public function toString() : String
      {
         return "[Transform3D" + " a:" + this.a.toFixed(3) + " b:" + this.b.toFixed(3) + " c:" + this.a.toFixed(3) + " d:" + this.d.toFixed(3) + " e:" + this.e.toFixed(3) + " f:" + this.f.toFixed(3) + " g:" + this.a.toFixed(3) + " h:" + this.h.toFixed(3) + " i:" + this.i.toFixed(3) + " j:" + this.j.toFixed(3) + " k:" + this.a.toFixed(3) + " l:" + this.l.toFixed(3) + "]";
      }
   }
}

