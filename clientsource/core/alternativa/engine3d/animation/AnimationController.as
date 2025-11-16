package alternativa.engine3d.animation
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.events.NotifyEvent;
   import alternativa.engine3d.core.Object3D;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   use namespace alternativa3d;
   
   public class AnimationController
   {
      
      private var _root:AnimationNode;
      
      private var _objects:Vector.<Object>;
      
      private var _object3ds:Vector.<Object3D> = new Vector.<Object3D>();
      
      private var objectsUsedCount:Dictionary = new Dictionary();
      
      private var states:Object = {};
      
      private var lastTime:int = -1;
      
      alternativa3d var nearestNotifyers:AnimationNotify;
      
      public function AnimationController()
      {
         super();
      }
      
      public function get root() : AnimationNode
      {
         return this._root;
      }
      
      public function set root(param1:AnimationNode) : void
      {
         if(this._root != param1)
         {
            if(this._root != null)
            {
               this._root.alternativa3d::setController(null);
               this._root.alternativa3d::_isActive = false;
            }
            if(param1 != null)
            {
               param1.alternativa3d::setController(this);
               param1.alternativa3d::_isActive = true;
            }
            this._root = param1;
         }
      }
      
      public function update() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:AnimationState = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Object3D = null;
         var _loc8_:AnimationNotify = null;
         if(this.lastTime < 0)
         {
            this.lastTime = getTimer();
            _loc1_ = 0;
         }
         else
         {
            _loc6_ = getTimer();
            _loc1_ = 0.001 * (_loc6_ - this.lastTime);
            this.lastTime = _loc6_;
         }
         if(this._root == null)
         {
            return;
         }
         for each(_loc2_ in this.states)
         {
            _loc2_.reset();
         }
         this._root.alternativa3d::update(_loc1_,1);
         _loc3_ = 0;
         _loc4_ = int(this._object3ds.length);
         while(_loc3_ < _loc4_)
         {
            _loc7_ = this._object3ds[_loc3_];
            _loc2_ = this.states[_loc7_.name];
            if(_loc2_ != null)
            {
               _loc2_.apply(_loc7_);
            }
            _loc3_++;
         }
         var _loc5_:AnimationNotify = this.alternativa3d::nearestNotifyers;
         while(_loc5_ != null)
         {
            if(_loc5_.willTrigger(NotifyEvent.NOTIFY))
            {
               _loc5_.dispatchEvent(new NotifyEvent(_loc5_));
            }
            _loc8_ = _loc5_;
            _loc5_ = _loc5_.alternativa3d::processNext;
            _loc8_.alternativa3d::processNext = null;
         }
         this.alternativa3d::nearestNotifyers = null;
      }
      
      alternativa3d function addObject(param1:Object) : void
      {
         if(param1 in this.objectsUsedCount)
         {
            ++this.objectsUsedCount[param1];
         }
         else
         {
            if(param1 is Object3D)
            {
               this._object3ds.push(param1);
            }
            else
            {
               this._objects.push(param1);
            }
            this.objectsUsedCount[param1] = 1;
         }
      }
      
      alternativa3d function removeObject(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = int(this.objectsUsedCount[param1]);
         _loc2_--;
         if(_loc2_ <= 0)
         {
            if(param1 is Object3D)
            {
               _loc3_ = int(this._object3ds.indexOf(param1 as Object3D));
               _loc5_ = int(this._object3ds.length - 1);
               _loc4_ = _loc3_ + 1;
               while(_loc3_ < _loc5_)
               {
                  this._object3ds[_loc3_] = this._object3ds[_loc4_];
                  _loc3_++;
                  _loc4_++;
               }
               this._object3ds.length = _loc5_;
            }
            else
            {
               _loc3_ = int(this._objects.indexOf(param1));
               _loc5_ = int(this._objects.length - 1);
               _loc4_ = _loc3_ + 1;
               while(_loc3_ < _loc5_)
               {
                  this._objects[_loc3_] = this._objects[_loc4_];
                  _loc3_++;
                  _loc4_++;
               }
               this._objects.length = _loc5_;
            }
            delete this.objectsUsedCount[param1];
         }
         else
         {
            this.objectsUsedCount[param1] = _loc2_;
         }
      }
      
      alternativa3d function getState(param1:String) : AnimationState
      {
         var _loc2_:AnimationState = this.states[param1];
         if(_loc2_ == null)
         {
            _loc2_ = new AnimationState();
            this.states[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function freeze() : void
      {
         this.lastTime = -1;
      }
   }
}

