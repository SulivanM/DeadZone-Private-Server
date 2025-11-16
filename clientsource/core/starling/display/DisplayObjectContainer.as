package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.utils.getQualifiedClassName;
   import starling.core.RenderSupport;
   import starling.core.starling_internal;
   import starling.errors.AbstractClassError;
   import starling.events.Event;
   import starling.filters.FragmentFilter;
   import starling.utils.MatrixUtil;
   
   use namespace starling_internal;
   
   public class DisplayObjectContainer extends DisplayObject
   {
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperPoint:Point = new Point();
      
      private static var sBroadcastListeners:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private var mChildren:Vector.<DisplayObject>;
      
      public function DisplayObjectContainer()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObjectContainer")
         {
            throw new AbstractClassError();
         }
         this.mChildren = new Vector.<DisplayObject>(0);
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = int(this.mChildren.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            this.mChildren[_loc2_].dispose();
            _loc2_++;
         }
         super.dispose();
      }
      
      public function addChild(param1:DisplayObject) : DisplayObject
      {
         this.addChildAt(param1,this.numChildren);
         return param1;
      }
      
      public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         var _loc4_:DisplayObjectContainer = null;
         var _loc3_:int = int(this.mChildren.length);
         if(param2 >= 0 && param2 <= _loc3_)
         {
            param1.removeFromParent();
            if(param2 == _loc3_)
            {
               this.mChildren.push(param1);
            }
            else
            {
               this.mChildren.splice(param2,0,param1);
            }
            param1.setParent(this);
            param1.dispatchEventWith(Event.ADDED,true);
            if(stage)
            {
               _loc4_ = param1 as DisplayObjectContainer;
               if(_loc4_)
               {
                  _loc4_.broadcastEventWith(Event.ADDED_TO_STAGE);
               }
               else
               {
                  param1.dispatchEventWith(Event.ADDED_TO_STAGE);
               }
            }
            return param1;
         }
         throw new RangeError("Invalid child index");
      }
      
      public function removeChild(param1:DisplayObject, param2:Boolean = false) : DisplayObject
      {
         var _loc3_:int = this.getChildIndex(param1);
         if(_loc3_ != -1)
         {
            this.removeChildAt(_loc3_,param2);
         }
         return param1;
      }
      
      public function removeChildAt(param1:int, param2:Boolean = false) : DisplayObject
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObjectContainer = null;
         if(param1 >= 0 && param1 < this.numChildren)
         {
            _loc3_ = this.mChildren[param1];
            _loc3_.dispatchEventWith(Event.REMOVED,true);
            if(stage)
            {
               _loc4_ = _loc3_ as DisplayObjectContainer;
               if(_loc4_)
               {
                  _loc4_.broadcastEventWith(Event.REMOVED_FROM_STAGE);
               }
               else
               {
                  _loc3_.dispatchEventWith(Event.REMOVED_FROM_STAGE);
               }
            }
            _loc3_.setParent(null);
            param1 = int(this.mChildren.indexOf(_loc3_));
            if(param1 >= 0)
            {
               this.mChildren.splice(param1,1);
            }
            if(param2)
            {
               _loc3_.dispose();
            }
            return _loc3_;
         }
         throw new RangeError("Invalid child index");
      }
      
      public function removeChildren(param1:int = 0, param2:int = -1, param3:Boolean = false) : void
      {
         if(param2 < 0 || param2 >= this.numChildren)
         {
            param2 = this.numChildren - 1;
         }
         var _loc4_:int = param1;
         while(_loc4_ <= param2)
         {
            this.removeChildAt(param1,param3);
            _loc4_++;
         }
      }
      
      public function getChildAt(param1:int) : DisplayObject
      {
         if(param1 >= 0 && param1 < this.numChildren)
         {
            return this.mChildren[param1];
         }
         throw new RangeError("Invalid child index");
      }
      
      public function getChildByName(param1:String) : DisplayObject
      {
         var _loc2_:int = int(this.mChildren.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.mChildren[_loc3_].name == param1)
            {
               return this.mChildren[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getChildIndex(param1:DisplayObject) : int
      {
         return this.mChildren.indexOf(param1);
      }
      
      public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         var _loc3_:int = this.getChildIndex(param1);
         if(_loc3_ == -1)
         {
            throw new ArgumentError("Not a child of this container");
         }
         this.mChildren.splice(_loc3_,1);
         this.mChildren.splice(param2,0,param1);
      }
      
      public function swapChildren(param1:DisplayObject, param2:DisplayObject) : void
      {
         var _loc3_:int = this.getChildIndex(param1);
         var _loc4_:int = this.getChildIndex(param2);
         if(_loc3_ == -1 || _loc4_ == -1)
         {
            throw new ArgumentError("Not a child of this container");
         }
         this.swapChildrenAt(_loc3_,_loc4_);
      }
      
      public function swapChildrenAt(param1:int, param2:int) : void
      {
         var _loc3_:DisplayObject = this.getChildAt(param1);
         var _loc4_:DisplayObject = this.getChildAt(param2);
         this.mChildren[param1] = _loc4_;
         this.mChildren[param2] = _loc3_;
      }
      
      public function sortChildren(param1:Function) : void
      {
         this.mChildren = this.mChildren.sort(param1);
      }
      
      public function contains(param1:DisplayObject) : Boolean
      {
         while(param1)
         {
            if(param1 == this)
            {
               return true;
            }
            param1 = param1.parent;
         }
         return false;
      }
      
      override public function getBounds(param1:DisplayObject, param2:Rectangle = null) : Rectangle
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         if(param2 == null)
         {
            param2 = new Rectangle();
         }
         var _loc3_:int = int(this.mChildren.length);
         if(_loc3_ == 0)
         {
            getTransformationMatrix(param1,sHelperMatrix);
            MatrixUtil.transformCoords(sHelperMatrix,0,0,sHelperPoint);
            param2.setTo(sHelperPoint.x,sHelperPoint.y,0,0);
            return param2;
         }
         if(_loc3_ == 1)
         {
            return this.mChildren[0].getBounds(param1,param2);
         }
         _loc4_ = Number.MAX_VALUE;
         _loc5_ = -Number.MAX_VALUE;
         _loc6_ = Number.MAX_VALUE;
         _loc7_ = -Number.MAX_VALUE;
         _loc8_ = 0;
         while(_loc8_ < _loc3_)
         {
            this.mChildren[_loc8_].getBounds(param1,param2);
            _loc4_ = _loc4_ < param2.x ? _loc4_ : param2.x;
            _loc5_ = _loc5_ > param2.right ? _loc5_ : param2.right;
            _loc6_ = _loc6_ < param2.y ? _loc6_ : param2.y;
            _loc7_ = _loc7_ > param2.bottom ? _loc7_ : param2.bottom;
            _loc8_++;
         }
         param2.setTo(_loc4_,_loc6_,_loc5_ - _loc4_,_loc7_ - _loc6_);
         return param2;
      }
      
      override public function hitTest(param1:Point, param2:Boolean = false) : DisplayObject
      {
         var _loc7_:DisplayObject = null;
         var _loc8_:DisplayObject = null;
         if(param2 && (!visible || !touchable))
         {
            return null;
         }
         var _loc3_:Number = param1.x;
         var _loc4_:Number = param1.y;
         var _loc5_:int = int(this.mChildren.length);
         var _loc6_:int = _loc5_ - 1;
         while(_loc6_ >= 0)
         {
            _loc7_ = this.mChildren[_loc6_];
            getTransformationMatrix(_loc7_,sHelperMatrix);
            MatrixUtil.transformCoords(sHelperMatrix,_loc3_,_loc4_,sHelperPoint);
            _loc8_ = _loc7_.hitTest(sHelperPoint,param2);
            if(_loc8_)
            {
               return _loc8_;
            }
            _loc6_--;
         }
         return null;
      }
      
      override public function render(param1:RenderSupport, param2:Number) : void
      {
         var _loc7_:DisplayObject = null;
         var _loc8_:FragmentFilter = null;
         var _loc3_:Number = param2 * this.alpha;
         var _loc4_:int = int(this.mChildren.length);
         var _loc5_:String = param1.blendMode;
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = this.mChildren[_loc6_];
            if(_loc7_.hasVisibleArea)
            {
               _loc8_ = _loc7_.filter;
               param1.pushMatrix();
               param1.transformMatrix(_loc7_);
               param1.blendMode = _loc7_.blendMode;
               if(_loc8_)
               {
                  _loc8_.render(_loc7_,param1,_loc3_);
               }
               else
               {
                  _loc7_.render(param1,_loc3_);
               }
               param1.blendMode = _loc5_;
               param1.popMatrix();
            }
            _loc6_++;
         }
      }
      
      public function broadcastEvent(param1:Event) : void
      {
         if(param1.bubbles)
         {
            throw new ArgumentError("Broadcast of bubbling events is prohibited");
         }
         var _loc2_:int = int(sBroadcastListeners.length);
         this.getChildEventListeners(this,param1.type,sBroadcastListeners);
         var _loc3_:int = int(sBroadcastListeners.length);
         var _loc4_:int = _loc2_;
         while(_loc4_ < _loc3_)
         {
            sBroadcastListeners[_loc4_].dispatchEvent(param1);
            _loc4_++;
         }
         sBroadcastListeners.length = _loc2_;
      }
      
      public function broadcastEventWith(param1:String, param2:Object = null) : void
      {
         var _loc3_:Event = Event.starling_internal::fromPool(param1,false,param2);
         this.broadcastEvent(_loc3_);
         Event.starling_internal::toPool(_loc3_);
      }
      
      private function getChildEventListeners(param1:DisplayObject, param2:String, param3:Vector.<DisplayObject>) : void
      {
         var _loc5_:Vector.<DisplayObject> = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:DisplayObjectContainer = param1 as DisplayObjectContainer;
         if(param1.hasEventListener(param2))
         {
            param3.push(param1);
         }
         if(_loc4_)
         {
            _loc5_ = _loc4_.mChildren;
            _loc6_ = int(_loc5_.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               this.getChildEventListeners(_loc5_[_loc7_],param2,param3);
               _loc7_++;
            }
         }
      }
      
      public function get numChildren() : int
      {
         return this.mChildren.length;
      }
   }
}

