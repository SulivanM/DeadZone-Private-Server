package versions.version2.a3d.materials
{
   public class A3D2CubeMap
   {
      
      private var _backId:int;
      
      private var _bottomId:int;
      
      private var _frontId:int;
      
      private var _id:int;
      
      private var _leftId:int;
      
      private var _rightId:int;
      
      private var _topId:int;
      
      public function A3D2CubeMap(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int)
      {
         super();
         this._backId = param1;
         this._bottomId = param2;
         this._frontId = param3;
         this._id = param4;
         this._leftId = param5;
         this._rightId = param6;
         this._topId = param7;
      }
      
      public function get backId() : int
      {
         return this._backId;
      }
      
      public function set backId(param1:int) : void
      {
         this._backId = param1;
      }
      
      public function get bottomId() : int
      {
         return this._bottomId;
      }
      
      public function set bottomId(param1:int) : void
      {
         this._bottomId = param1;
      }
      
      public function get frontId() : int
      {
         return this._frontId;
      }
      
      public function set frontId(param1:int) : void
      {
         this._frontId = param1;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get leftId() : int
      {
         return this._leftId;
      }
      
      public function set leftId(param1:int) : void
      {
         this._leftId = param1;
      }
      
      public function get rightId() : int
      {
         return this._rightId;
      }
      
      public function set rightId(param1:int) : void
      {
         this._rightId = param1;
      }
      
      public function get topId() : int
      {
         return this._topId;
      }
      
      public function set topId(param1:int) : void
      {
         this._topId = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2CubeMap [";
         _loc1_ += "backId = " + this.backId + " ";
         _loc1_ += "bottomId = " + this.bottomId + " ";
         _loc1_ += "frontId = " + this.frontId + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "leftId = " + this.leftId + " ";
         _loc1_ += "rightId = " + this.rightId + " ";
         _loc1_ += "topId = " + this.topId + " ";
         return _loc1_ + "]";
      }
   }
}

