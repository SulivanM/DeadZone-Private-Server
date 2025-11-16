package com.deadreckoned.threshold.navigation.core
{
   import com.deadreckoned.threshold.ns.threshold_navigation;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   
   use namespace threshold_navigation;
   
   public class NavAgent
   {
      
      private static var _orthonormalType:String = ORTHONORMAL_2D;
      
      public static const FORWARD:Vector3D = new Vector3D();
      
      public static const UP:Vector3D = new Vector3D();
      
      public static const RIGHT:Vector3D = new Vector3D();
      
      public static const ORTHONORMAL_2D:String = "2d";
      
      public static const ORTHONORMAL_3D:String = "3d";
      
      setOrthonormalBasis(ORTHONORMAL_2D);
      
      threshold_navigation var _updatePosition:Boolean = true;
      
      threshold_navigation var _position:Vector3D;
      
      threshold_navigation var _velocity:Vector3D;
      
      threshold_navigation var _orientation:Matrix3D;
      
      threshold_navigation var _radius:Number = 10;
      
      threshold_navigation var _maxSpeed:Number = 1;
      
      threshold_navigation var _mass:Number = 1;
      
      threshold_navigation var _inverseMass:Number = 1;
      
      threshold_navigation var _forward:Vector3D;
      
      threshold_navigation var _right:Vector3D;
      
      threshold_navigation var _up:Vector3D;
      
      public function NavAgent()
      {
         super();
         this.threshold_navigation::_velocity = new Vector3D();
         this.threshold_navigation::_position = new Vector3D();
         this.threshold_navigation::_orientation = new Matrix3D();
         this.threshold_navigation::_forward = new Vector3D(FORWARD.x,FORWARD.y,FORWARD.z);
         this.threshold_navigation::_right = new Vector3D(RIGHT.x,RIGHT.y,RIGHT.z);
         this.threshold_navigation::_up = new Vector3D(UP.x,UP.y,UP.z);
      }
      
      public static function get orthonormalType() : String
      {
         return _orthonormalType;
      }
      
      public static function setOrthonormalBasis(param1:String) : void
      {
         if(param1 == ORTHONORMAL_3D)
         {
            _orthonormalType = ORTHONORMAL_3D;
            RIGHT.setTo(1,0,0);
            UP.setTo(0,1,0);
            FORWARD.setTo(0,0,1);
         }
         else
         {
            _orthonormalType = ORTHONORMAL_2D;
            FORWARD.setTo(1,0,0);
            RIGHT.setTo(0,1,0);
            UP.setTo(0,0,1);
         }
      }
      
      public function get position() : Vector3D
      {
         return this.threshold_navigation::_position;
      }
      
      public function set position(param1:Vector3D) : void
      {
         this.threshold_navigation::_position = param1;
      }
      
      public function get velocity() : Vector3D
      {
         return this.threshold_navigation::_velocity;
      }
      
      public function set velocity(param1:Vector3D) : void
      {
         this.threshold_navigation::_velocity = param1;
      }
      
      public function get orientation() : Matrix3D
      {
         return this.threshold_navigation::_orientation;
      }
      
      public function set orientation(param1:Matrix3D) : void
      {
         this.threshold_navigation::_orientation = param1;
      }
      
      public function get radius() : Number
      {
         return this.threshold_navigation::_radius;
      }
      
      public function set radius(param1:Number) : void
      {
         this.threshold_navigation::_radius = param1;
      }
      
      public function get maxSpeed() : Number
      {
         return this.threshold_navigation::_maxSpeed;
      }
      
      public function set maxSpeed(param1:Number) : void
      {
         this.threshold_navigation::_maxSpeed = param1;
      }
      
      public function get speed() : Number
      {
         return Math.sqrt(this.threshold_navigation::_velocity.x * this.threshold_navigation::_velocity.x + this.threshold_navigation::_velocity.y * this.threshold_navigation::_velocity.y + this.threshold_navigation::_velocity.z * this.threshold_navigation::_velocity.z);
      }
      
      public function get speedSq() : Number
      {
         return this.threshold_navigation::_velocity.x * this.threshold_navigation::_velocity.x + this.threshold_navigation::_velocity.y * this.threshold_navigation::_velocity.y + this.threshold_navigation::_velocity.z * this.threshold_navigation::_velocity.z;
      }
      
      public function get mass() : Number
      {
         return this.threshold_navigation::_mass;
      }
      
      public function set mass(param1:Number) : void
      {
         this.threshold_navigation::_mass = param1;
         this.threshold_navigation::_inverseMass = 1 / this.threshold_navigation::_mass;
      }
      
      public function get forward() : Vector3D
      {
         return this.threshold_navigation::_forward;
      }
      
      public function get right() : Vector3D
      {
         return this.threshold_navigation::_right;
      }
      
      public function get up() : Vector3D
      {
         return this.threshold_navigation::_up;
      }
      
      public function update(param1:Number) : void
      {
         if(this.threshold_navigation::_updatePosition)
         {
            this.threshold_navigation::_position.x += this.threshold_navigation::_velocity.x * param1;
            this.threshold_navigation::_position.y += this.threshold_navigation::_velocity.y * param1;
            this.threshold_navigation::_position.z += this.threshold_navigation::_velocity.z * param1;
         }
      }
      
      protected function regenerateLocalSpace() : void
      {
         var _loc1_:Number = this.threshold_navigation::_velocity.x * this.threshold_navigation::_velocity.x + this.threshold_navigation::_velocity.y * this.threshold_navigation::_velocity.y + this.threshold_navigation::_velocity.z * this.threshold_navigation::_velocity.z;
         if(_loc1_ <= 0.0001)
         {
            return;
         }
         _loc1_ = 1 / Math.sqrt(_loc1_);
         this.threshold_navigation::_forward.x = this.threshold_navigation::_velocity.x * _loc1_;
         this.threshold_navigation::_forward.y = this.threshold_navigation::_velocity.y * _loc1_;
         this.threshold_navigation::_forward.z = this.threshold_navigation::_velocity.z * _loc1_;
         var _loc2_:Number = this.threshold_navigation::_forward.y * this.threshold_navigation::_up.z - this.threshold_navigation::_forward.z * this.threshold_navigation::_up.y;
         var _loc3_:Number = this.threshold_navigation::_forward.z * this.threshold_navigation::_up.x - this.threshold_navigation::_forward.x * this.threshold_navigation::_up.z;
         var _loc4_:Number = this.threshold_navigation::_forward.x * this.threshold_navigation::_up.y - this.threshold_navigation::_forward.y * this.threshold_navigation::_up.x;
         var _loc5_:Number = Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_ + _loc4_ * _loc4_);
         this.threshold_navigation::_right.x = _loc2_ / _loc5_;
         this.threshold_navigation::_right.y = _loc3_ / _loc5_;
         this.threshold_navigation::_right.z = _loc4_ / _loc5_;
         var _loc6_:Number = this.threshold_navigation::_right.y * this.threshold_navigation::_forward.z - this.threshold_navigation::_right.z * this.threshold_navigation::_forward.y;
         var _loc7_:Number = this.threshold_navigation::_right.z * this.threshold_navigation::_forward.x - this.threshold_navigation::_right.x * this.threshold_navigation::_forward.z;
         var _loc8_:Number = this.threshold_navigation::_right.x * this.threshold_navigation::_forward.y - this.threshold_navigation::_right.y * this.threshold_navigation::_forward.x;
         this.threshold_navigation::_up.x = _loc6_;
         this.threshold_navigation::_up.y = _loc7_;
         this.threshold_navigation::_up.z = _loc8_;
      }
      
      protected function updateOrientation() : void
      {
         if(_orthonormalType == "3d")
         {
            this.threshold_navigation::_orientation.copyRowFrom(0,this.threshold_navigation::_right);
            this.threshold_navigation::_orientation.copyRowFrom(1,this.threshold_navigation::_up);
            this.threshold_navigation::_orientation.copyRowFrom(2,this.threshold_navigation::_forward);
         }
         else
         {
            this.threshold_navigation::_orientation.copyRowFrom(0,this.threshold_navigation::_forward);
            this.threshold_navigation::_orientation.copyRowFrom(1,this.threshold_navigation::_right);
            this.threshold_navigation::_orientation.copyRowFrom(2,this.threshold_navigation::_up);
         }
      }
   }
}

