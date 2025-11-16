package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.ui.Mouse;
   import flash.ui.MouseCursor;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.errors.AbstractClassError;
   import starling.errors.AbstractMethodError;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   import starling.events.TouchEvent;
   import starling.filters.FragmentFilter;
   import starling.utils.MatrixUtil;
   
   public class DisplayObject extends EventDispatcher
   {
      
      private static var sAncestors:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private static var sHelperRect:Rectangle = new Rectangle();
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private var mX:Number;
      
      private var mY:Number;
      
      private var mPivotX:Number;
      
      private var mPivotY:Number;
      
      private var mScaleX:Number;
      
      private var mScaleY:Number;
      
      private var mSkewX:Number;
      
      private var mSkewY:Number;
      
      private var mRotation:Number;
      
      private var mAlpha:Number;
      
      private var mVisible:Boolean;
      
      private var mTouchable:Boolean;
      
      private var mBlendMode:String;
      
      private var mName:String;
      
      private var mUseHandCursor:Boolean;
      
      private var mLastTouchTimestamp:Number;
      
      private var mParent:DisplayObjectContainer;
      
      private var mTransformationMatrix:Matrix;
      
      private var mOrientationChanged:Boolean;
      
      private var mFilter:FragmentFilter;
      
      public function DisplayObject()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObject")
         {
            throw new AbstractClassError();
         }
         this.mX = this.mY = this.mPivotX = this.mPivotY = this.mRotation = this.mSkewX = this.mSkewY = 0;
         this.mScaleX = this.mScaleY = this.mAlpha = 1;
         this.mVisible = this.mTouchable = true;
         this.mLastTouchTimestamp = -1;
         this.mBlendMode = BlendMode.AUTO;
         this.mTransformationMatrix = new Matrix();
         this.mOrientationChanged = this.mUseHandCursor = false;
      }
      
      public function dispose() : void
      {
         if(this.mFilter)
         {
            this.mFilter.dispose();
         }
         removeEventListeners();
      }
      
      public function removeFromParent(param1:Boolean = false) : void
      {
         if(this.mParent)
         {
            this.mParent.removeChild(this,param1);
         }
      }
      
      public function getTransformationMatrix(param1:DisplayObject, param2:Matrix = null) : Matrix
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         if(param2)
         {
            param2.identity();
         }
         else
         {
            param2 = new Matrix();
         }
         if(param1 == this)
         {
            return param2;
         }
         if(param1 == this.mParent || param1 == null && this.mParent == null)
         {
            param2.copyFrom(this.transformationMatrix);
            return param2;
         }
         if(param1 == null || param1 == this.base)
         {
            _loc4_ = this;
            while(_loc4_ != param1)
            {
               param2.concat(_loc4_.transformationMatrix);
               _loc4_ = _loc4_.mParent;
            }
            return param2;
         }
         if(param1.mParent == this)
         {
            param1.getTransformationMatrix(this,param2);
            param2.invert();
            return param2;
         }
         _loc3_ = null;
         _loc4_ = this;
         while(_loc4_)
         {
            sAncestors.push(_loc4_);
            _loc4_ = _loc4_.mParent;
         }
         _loc4_ = param1;
         while(Boolean(_loc4_) && sAncestors.indexOf(_loc4_) == -1)
         {
            _loc4_ = _loc4_.mParent;
         }
         sAncestors.length = 0;
         if(_loc4_)
         {
            _loc3_ = _loc4_;
            _loc4_ = this;
            while(_loc4_ != _loc3_)
            {
               param2.concat(_loc4_.transformationMatrix);
               _loc4_ = _loc4_.mParent;
            }
            if(_loc3_ == param1)
            {
               return param2;
            }
            sHelperMatrix.identity();
            _loc4_ = param1;
            while(_loc4_ != _loc3_)
            {
               sHelperMatrix.concat(_loc4_.transformationMatrix);
               _loc4_ = _loc4_.mParent;
            }
            sHelperMatrix.invert();
            param2.concat(sHelperMatrix);
            return param2;
         }
         throw new ArgumentError("Object not connected to target");
      }
      
      public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         throw new AbstractMethodError("Method needs to be implemented in subclass");
      }
      
      public function hitTest(param1:Point, param2:Boolean = false) : DisplayObject
      {
         if(param2 && (!this.mVisible || !this.mTouchable))
         {
            return null;
         }
         if(this.getBounds(this,sHelperRect).containsPoint(param1))
         {
            return this;
         }
         return null;
      }
      
      public function localToGlobal(param1:Point, param2:Point = null) : Point
      {
         this.getTransformationMatrix(this.base,sHelperMatrix);
         return MatrixUtil.transformCoords(sHelperMatrix,param1.x,param1.y,param2);
      }
      
      public function globalToLocal(param1:Point, param2:Point = null) : Point
      {
         this.getTransformationMatrix(this.base,sHelperMatrix);
         sHelperMatrix.invert();
         return MatrixUtil.transformCoords(sHelperMatrix,param1.x,param1.y,param2);
      }
      
      public function render(param1:RenderSupport, param2:Number) : void
      {
         throw new AbstractMethodError("Method needs to be implemented in subclass");
      }
      
      override public function dispatchEvent(param1:Event) : void
      {
         var _loc2_:TouchEvent = null;
         if(param1 is TouchEvent)
         {
            _loc2_ = param1 as TouchEvent;
            if(_loc2_.timestamp == this.mLastTouchTimestamp)
            {
               return;
            }
            this.mLastTouchTimestamp = _loc2_.timestamp;
         }
         super.dispatchEvent(param1);
      }
      
      public function get hasVisibleArea() : Boolean
      {
         return this.mAlpha != 0 && this.mVisible && this.mScaleX != 0 && this.mScaleY != 0;
      }
      
      internal function setParent(param1:DisplayObjectContainer) : void
      {
         var _loc2_:DisplayObject = param1;
         while(_loc2_ != this && _loc2_ != null)
         {
            _loc2_ = _loc2_.mParent;
         }
         if(_loc2_ == this)
         {
            throw new ArgumentError("An object cannot be added as a child to itself or one " + "of its children (or children\'s children, etc.)");
         }
         this.mParent = param1;
      }
      
      private function normalizeAngle(param1:Number) : Number
      {
         while(param1 < -Math.PI)
         {
            param1 += Math.PI * 2;
         }
         while(param1 > Math.PI)
         {
            param1 -= Math.PI * 2;
         }
         return param1;
      }
      
      public function get transformationMatrix() : Matrix
      {
         if(this.mOrientationChanged)
         {
            this.mOrientationChanged = false;
            this.mTransformationMatrix.identity();
            if(this.mSkewX != 0 || this.mSkewY != 0)
            {
               MatrixUtil.skew(this.mTransformationMatrix,this.mSkewX,this.mSkewY);
            }
            if(this.mScaleX != 1 || this.mScaleY != 1)
            {
               this.mTransformationMatrix.scale(this.mScaleX,this.mScaleY);
            }
            if(this.mRotation != 0)
            {
               this.mTransformationMatrix.rotate(this.mRotation);
            }
            if(this.mX != 0 || this.mY != 0)
            {
               this.mTransformationMatrix.translate(this.mX,this.mY);
            }
            if(this.mPivotX != 0 || this.mPivotY != 0)
            {
               this.mTransformationMatrix.tx = this.mX - this.mTransformationMatrix.a * this.mPivotX - this.mTransformationMatrix.c * this.mPivotY;
               this.mTransformationMatrix.ty = this.mY - this.mTransformationMatrix.b * this.mPivotX - this.mTransformationMatrix.d * this.mPivotY;
            }
         }
         return this.mTransformationMatrix;
      }
      
      public function set transformationMatrix(param1:Matrix) : void
      {
         this.mOrientationChanged = false;
         this.mTransformationMatrix.copyFrom(param1);
         this.mX = param1.tx;
         this.mY = param1.ty;
         var _loc2_:Number = param1.a;
         var _loc3_:Number = param1.b;
         var _loc4_:Number = param1.c;
         var _loc5_:Number = param1.d;
         this.mScaleX = Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_);
         if(this.mScaleX != 0)
         {
            this.mRotation = Math.atan2(_loc3_,_loc2_);
         }
         else
         {
            this.mRotation = 0;
         }
         var _loc6_:Number = Math.cos(this.mRotation);
         var _loc7_:Number = Math.sin(this.mRotation);
         this.mScaleY = _loc5_ * _loc6_ - _loc4_ * _loc7_;
         if(this.mScaleY != 0)
         {
            this.mSkewX = Math.atan2(_loc5_ * _loc7_ + _loc4_ * _loc6_,this.mScaleY);
         }
         else
         {
            this.mSkewX = 0;
         }
         this.mSkewY = 0;
         this.mPivotX = 0;
         this.mPivotY = 0;
      }
      
      public function get useHandCursor() : Boolean
      {
         return this.mUseHandCursor;
      }
      
      public function set useHandCursor(param1:Boolean) : void
      {
         if(param1 == this.mUseHandCursor)
         {
            return;
         }
         this.mUseHandCursor = param1;
         if(this.mUseHandCursor)
         {
            addEventListener(TouchEvent.TOUCH,this.onTouch);
         }
         else
         {
            removeEventListener(TouchEvent.TOUCH,this.onTouch);
         }
      }
      
      private function onTouch(param1:TouchEvent) : void
      {
         Mouse.cursor = param1.interactsWith(this) ? MouseCursor.BUTTON : MouseCursor.AUTO;
      }
      
      public function get bounds() : Rectangle
      {
         return this.getBounds(this.mParent);
      }
      
      public function get width() : Number
      {
         return this.getBounds(this.mParent,sHelperRect).width;
      }
      
      public function set width(param1:Number) : void
      {
         this.scaleX = 1;
         var _loc2_:Number = this.width;
         if(_loc2_ != 0)
         {
            this.scaleX = param1 / _loc2_;
         }
         else
         {
            this.scaleX = 1;
         }
      }
      
      public function get height() : Number
      {
         return this.getBounds(this.mParent,sHelperRect).height;
      }
      
      public function set height(param1:Number) : void
      {
         this.scaleY = 1;
         var _loc2_:Number = this.height;
         if(_loc2_ != 0)
         {
            this.scaleY = param1 / _loc2_;
         }
         else
         {
            this.scaleY = 1;
         }
      }
      
      public function get x() : Number
      {
         return this.mX;
      }
      
      public function set x(param1:Number) : void
      {
         if(this.mX != param1)
         {
            this.mX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get y() : Number
      {
         return this.mY;
      }
      
      public function set y(param1:Number) : void
      {
         if(this.mY != param1)
         {
            this.mY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get pivotX() : Number
      {
         return this.mPivotX;
      }
      
      public function set pivotX(param1:Number) : void
      {
         if(this.mPivotX != param1)
         {
            this.mPivotX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get pivotY() : Number
      {
         return this.mPivotY;
      }
      
      public function set pivotY(param1:Number) : void
      {
         if(this.mPivotY != param1)
         {
            this.mPivotY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get scaleX() : Number
      {
         return this.mScaleX;
      }
      
      public function set scaleX(param1:Number) : void
      {
         if(this.mScaleX != param1)
         {
            this.mScaleX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get scaleY() : Number
      {
         return this.mScaleY;
      }
      
      public function set scaleY(param1:Number) : void
      {
         if(this.mScaleY != param1)
         {
            this.mScaleY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get skewX() : Number
      {
         return this.mSkewX;
      }
      
      public function set skewX(param1:Number) : void
      {
         param1 = this.normalizeAngle(param1);
         if(this.mSkewX != param1)
         {
            this.mSkewX = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get skewY() : Number
      {
         return this.mSkewY;
      }
      
      public function set skewY(param1:Number) : void
      {
         param1 = this.normalizeAngle(param1);
         if(this.mSkewY != param1)
         {
            this.mSkewY = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get rotation() : Number
      {
         return this.mRotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         param1 = this.normalizeAngle(param1);
         if(this.mRotation != param1)
         {
            this.mRotation = param1;
            this.mOrientationChanged = true;
         }
      }
      
      public function get alpha() : Number
      {
         return this.mAlpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         this.mAlpha = param1 < 0 ? 0 : (param1 > 1 ? 1 : param1);
      }
      
      public function get visible() : Boolean
      {
         return this.mVisible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this.mVisible = param1;
      }
      
      public function get touchable() : Boolean
      {
         return this.mTouchable;
      }
      
      public function set touchable(param1:Boolean) : void
      {
         this.mTouchable = param1;
      }
      
      public function get blendMode() : String
      {
         return this.mBlendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         this.mBlendMode = param1;
      }
      
      public function get name() : String
      {
         return this.mName;
      }
      
      public function set name(param1:String) : void
      {
         this.mName = param1;
      }
      
      public function get filter() : FragmentFilter
      {
         return this.mFilter;
      }
      
      public function set filter(param1:FragmentFilter) : void
      {
         this.mFilter = param1;
      }
      
      public function get parent() : DisplayObjectContainer
      {
         return this.mParent;
      }
      
      public function get base() : DisplayObject
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_.mParent)
         {
            _loc1_ = _loc1_.mParent;
         }
         return _loc1_;
      }
      
      public function get root() : DisplayObject
      {
         var _loc1_:DisplayObject = this;
         while(_loc1_.mParent)
         {
            if(_loc1_.mParent is Stage)
            {
               return _loc1_;
            }
            _loc1_ = _loc1_.parent;
         }
         return null;
      }
      
      public function get stage() : Stage
      {
         return this.base as Stage;
      }
   }
}

