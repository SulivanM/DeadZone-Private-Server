package alternativa.engine3d.animation
{
   import alternativa.engine3d.alternativa3d;
   
   use namespace alternativa3d;
   
   public class AnimationSwitcher extends AnimationNode
   {
      
      private var _numAnimations:int = 0;
      
      private var _animations:Vector.<AnimationNode> = new Vector.<AnimationNode>();
      
      private var _weights:Vector.<Number> = new Vector.<Number>();
      
      private var _active:AnimationNode;
      
      private var fadingSpeed:Number = 0;
      
      public function AnimationSwitcher()
      {
         super();
      }
      
      override alternativa3d function update(param1:Number, param2:Number) : void
      {
         var _loc6_:AnimationNode = null;
         var _loc7_:Number = NaN;
         var _loc3_:Number = speed * param1;
         var _loc4_:Number = this.fadingSpeed * _loc3_;
         var _loc5_:int = 0;
         while(_loc5_ < this._numAnimations)
         {
            _loc6_ = this._animations[_loc5_];
            _loc7_ = this._weights[_loc5_];
            if(_loc6_ == this._active)
            {
               _loc7_ += _loc4_;
               _loc7_ = _loc7_ >= 1 ? 1 : _loc7_;
               _loc6_.alternativa3d::update(_loc3_,param2 * _loc7_);
               this._weights[_loc5_] = _loc7_;
            }
            else
            {
               _loc7_ -= _loc4_;
               if(_loc7_ > 0)
               {
                  _loc6_.alternativa3d::update(_loc3_,param2 * _loc7_);
                  this._weights[_loc5_] = _loc7_;
               }
               else
               {
                  _loc6_.alternativa3d::_isActive = false;
                  this._weights[_loc5_] = 0;
               }
            }
            _loc5_++;
         }
      }
      
      public function get active() : AnimationNode
      {
         return this._active;
      }
      
      public function activate(param1:AnimationNode, param2:Number = 0) : void
      {
         var _loc3_:int = 0;
         if(param1.alternativa3d::_parent != this)
         {
            throw new Error("Animation is not child of this blender");
         }
         this._active = param1;
         param1.alternativa3d::_isActive = true;
         if(param2 <= 0)
         {
            _loc3_ = 0;
            while(_loc3_ < this._numAnimations)
            {
               if(this._animations[_loc3_] == param1)
               {
                  this._weights[_loc3_] = 1;
               }
               else
               {
                  this._weights[_loc3_] = 0;
                  this._animations[_loc3_].alternativa3d::_isActive = false;
               }
               _loc3_++;
            }
            this.fadingSpeed = 0;
         }
         else
         {
            this.fadingSpeed = 1 / param2;
         }
      }
      
      override alternativa3d function setController(param1:AnimationController) : void
      {
         var _loc3_:AnimationNode = null;
         this.alternativa3d::controller = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this._numAnimations)
         {
            _loc3_ = this._animations[_loc2_];
            _loc3_.alternativa3d::setController(alternativa3d::controller);
            _loc2_++;
         }
      }
      
      override alternativa3d function removeNode(param1:AnimationNode) : void
      {
         this.removeAnimation(param1);
      }
      
      public function addAnimation(param1:AnimationNode) : AnimationNode
      {
         if(param1 == null)
         {
            throw new Error("Animation cannot be null");
         }
         if(param1.alternativa3d::_parent == this)
         {
            throw new Error("Animation already exist in blender");
         }
         this._animations[this._numAnimations] = param1;
         if(this._numAnimations == 0)
         {
            this._active = param1;
            param1.alternativa3d::_isActive = true;
            this._weights[this._numAnimations] = 1;
         }
         else
         {
            this._weights[this._numAnimations] = 0;
         }
         ++this._numAnimations;
         alternativa3d::addNode(param1);
         return param1;
      }
      
      public function removeAnimation(param1:AnimationNode) : AnimationNode
      {
         var _loc2_:int = int(this._animations.indexOf(param1));
         if(_loc2_ < 0)
         {
            throw new ArgumentError("Animation not found");
         }
         --this._numAnimations;
         var _loc3_:int = _loc2_ + 1;
         while(_loc2_ < this._numAnimations)
         {
            this._animations[_loc2_] = this._animations[_loc3_];
            _loc2_++;
            _loc3_++;
         }
         this._animations.length = this._numAnimations;
         this._weights.length = this._numAnimations;
         if(this._active == param1)
         {
            if(this._numAnimations > 0)
            {
               this._active = this._animations[int(this._numAnimations - 1)];
               this._weights[int(this._numAnimations - 1)] = 1;
            }
            else
            {
               this._active = null;
            }
         }
         super.alternativa3d::removeNode(param1);
         return param1;
      }
      
      public function getAnimationAt(param1:int) : AnimationNode
      {
         return this._animations[param1];
      }
      
      public function numAnimations() : int
      {
         return this._numAnimations;
      }
   }
}

