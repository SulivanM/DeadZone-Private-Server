package commons
{
   public class A3DMatrix
   {
      
      private var _a:Number;
      
      private var _b:Number;
      
      private var _c:Number;
      
      private var _d:Number;
      
      private var _e:Number;
      
      private var _f:Number;
      
      private var _g:Number;
      
      private var _h:Number;
      
      private var _i:Number;
      
      private var _j:Number;
      
      private var _k:Number;
      
      private var _l:Number;
      
      public function A3DMatrix(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number, param10:Number, param11:Number, param12:Number)
      {
         super();
         this._a = param1;
         this._b = param2;
         this._c = param3;
         this._d = param4;
         this._e = param5;
         this._f = param6;
         this._g = param7;
         this._h = param8;
         this._i = param9;
         this._j = param10;
         this._k = param11;
         this._l = param12;
      }
      
      public function get a() : Number
      {
         return this._a;
      }
      
      public function set a(param1:Number) : void
      {
         this._a = param1;
      }
      
      public function get b() : Number
      {
         return this._b;
      }
      
      public function set b(param1:Number) : void
      {
         this._b = param1;
      }
      
      public function get c() : Number
      {
         return this._c;
      }
      
      public function set c(param1:Number) : void
      {
         this._c = param1;
      }
      
      public function get d() : Number
      {
         return this._d;
      }
      
      public function set d(param1:Number) : void
      {
         this._d = param1;
      }
      
      public function get e() : Number
      {
         return this._e;
      }
      
      public function set e(param1:Number) : void
      {
         this._e = param1;
      }
      
      public function get f() : Number
      {
         return this._f;
      }
      
      public function set f(param1:Number) : void
      {
         this._f = param1;
      }
      
      public function get g() : Number
      {
         return this._g;
      }
      
      public function set g(param1:Number) : void
      {
         this._g = param1;
      }
      
      public function get h() : Number
      {
         return this._h;
      }
      
      public function set h(param1:Number) : void
      {
         this._h = param1;
      }
      
      public function get i() : Number
      {
         return this._i;
      }
      
      public function set i(param1:Number) : void
      {
         this._i = param1;
      }
      
      public function get j() : Number
      {
         return this._j;
      }
      
      public function set j(param1:Number) : void
      {
         this._j = param1;
      }
      
      public function get k() : Number
      {
         return this._k;
      }
      
      public function set k(param1:Number) : void
      {
         this._k = param1;
      }
      
      public function get l() : Number
      {
         return this._l;
      }
      
      public function set l(param1:Number) : void
      {
         this._l = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DMatrix [";
         _loc1_ += "a = " + this.a + " ";
         _loc1_ += "b = " + this.b + " ";
         _loc1_ += "c = " + this.c + " ";
         _loc1_ += "d = " + this.d + " ";
         _loc1_ += "e = " + this.e + " ";
         _loc1_ += "f = " + this.f + " ";
         _loc1_ += "g = " + this.g + " ";
         _loc1_ += "h = " + this.h + " ";
         _loc1_ += "i = " + this.i + " ";
         _loc1_ += "j = " + this.j + " ";
         _loc1_ += "k = " + this.k + " ";
         _loc1_ += "l = " + this.l + " ";
         return _loc1_ + "]";
      }
   }
}

