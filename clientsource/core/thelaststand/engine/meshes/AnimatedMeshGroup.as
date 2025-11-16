package thelaststand.engine.meshes
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.animation.AnimationController;
   import alternativa.engine3d.animation.AnimationNotify;
   import alternativa.engine3d.animation.AnimationSwitcher;
   import alternativa.engine3d.animation.events.NotifyEvent;
   import flash.utils.Dictionary;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import thelaststand.engine.animation.AnimationTable;
   import thelaststand.engine.animation.IAnimatingObject;
   
   public class AnimatedMeshGroup extends MeshGroup implements IAnimatingObject
   {
      
      private var _currentAnim:AnimationClip;
      
      private var _currentAnimName:String;
      
      private var _currentAnimSpeed:Number = 1;
      
      private var _currentAnimLoop:Boolean = false;
      
      private var _delayTimeout:int = -1;
      
      private var _isPlaying:Boolean;
      
      private var _switcher:AnimationSwitcher;
      
      private var _controller:AnimationController;
      
      private var _animsByName:Dictionary;
      
      public var animSpeedMultiplier:Number = 1;
      
      public var animationChanged:Signal;
      
      public var animationCompleted:Signal;
      
      public var animationNotified:Signal;
      
      public function AnimatedMeshGroup(param1:Array = null)
      {
         var _loc2_:String = null;
         super();
         this.animationChanged = new Signal(String);
         this.animationCompleted = new Signal(String);
         this.animationNotified = new Signal(String,String);
         this._animsByName = new Dictionary(true);
         this._switcher = new AnimationSwitcher();
         this._controller = new AnimationController();
         this._controller.root = this._switcher;
         if(param1)
         {
            for each(_loc2_ in param1)
            {
               addChildrenFromResource(_loc2_);
            }
         }
      }
      
      override public function dispose() : void
      {
         clearTimeout(this._delayTimeout);
         this.animationChanged.removeAll();
         this.animationCompleted.removeAll();
         this.animationNotified.removeAll();
         this.removeAllAnimations();
         this._animsByName = null;
         this._switcher = null;
         this._controller.root = null;
         this._controller = null;
         super.dispose();
      }
      
      public function attachAnimations() : void
      {
         var _loc1_:String = null;
         var _loc2_:AnimationClip = null;
         for(_loc1_ in this._animsByName)
         {
            _loc2_ = this._animsByName[_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.attach(this,true);
            }
         }
      }
      
      public function addAnimationTable(param1:AnimationTable) : void
      {
         var _loc4_:AnimationClip = null;
         var _loc5_:AnimationClip = null;
         var _loc6_:AnimationNotify = null;
         var _loc7_:String = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = param1.numAnimations;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = param1.getAnimationAt(_loc2_);
            if(_loc4_ == null)
            {
               return;
            }
            _loc5_ = _loc4_.clone();
            for each(_loc6_ in _loc4_.notifiers)
            {
               _loc5_.addNotify(_loc6_.time,_loc6_.name);
            }
            this._switcher.addAnimation(_loc5_);
            _loc7_ = param1.getName(_loc2_);
            this._animsByName[_loc7_] = _loc5_;
            _loc2_++;
         }
      }
      
      public function removeAllAnimations() : void
      {
         var _loc2_:AnimationClip = null;
         var _loc3_:int = 0;
         var _loc1_:int = this._switcher.numAnimations() - 1;
         while(_loc1_ >= 0)
         {
            _loc2_ = this._switcher.getAnimationAt(_loc1_) as AnimationClip;
            if(_loc2_ != null)
            {
               this._switcher.removeAnimation(_loc2_);
               _loc3_ = int(_loc2_.notifiers.length - 1);
               while(_loc3_ >= 0)
               {
                  _loc2_.removeNotify(_loc2_.notifiers[_loc3_]);
                  _loc3_--;
               }
               if(_loc2_.objects != null)
               {
                  _loc2_.objects.length = 0;
               }
               if(_loc2_.notifiers != null)
               {
                  _loc2_.notifiers.length = 0;
               }
               _loc2_.alternativa3d::_parent = null;
               _loc2_.alternativa3d::controller = null;
            }
            _loc1_--;
         }
         this._animsByName = new Dictionary(true);
      }
      
      public function removeAnimationTable(param1:AnimationTable) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = param1.numAnimations - 1;
         while(_loc2_ >= 0)
         {
            this.removeAnimation(param1.getName(_loc2_));
            _loc2_--;
         }
      }
      
      public function removeAnimation(param1:String) : void
      {
         var _loc2_:AnimationClip = this._animsByName[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this._switcher.removeAnimation(_loc2_);
         var _loc3_:int = int(_loc2_.notifiers.length - 1);
         while(_loc3_ >= 0)
         {
            _loc2_.removeNotify(_loc2_.notifiers[_loc3_]);
            _loc3_--;
         }
         _loc2_.objects.length = 0;
         _loc2_.notifiers.length = 0;
         _loc2_.alternativa3d::_parent = null;
         _loc2_.alternativa3d::controller = null;
         this._animsByName[param1] = null;
         delete this._animsByName[param1];
      }
      
      public function getAnimationLength(param1:String) : Number
      {
         var _loc2_:AnimationClip = this._animsByName[param1];
         return _loc2_ != null ? _loc2_.length : 0;
      }
      
      public function getAnimationNotificationTime(param1:String, param2:String) : Number
      {
         var _loc6_:AnimationNotify = null;
         var _loc3_:AnimationClip = this._animsByName[param1];
         if(_loc3_ == null)
         {
            return 0;
         }
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.notifiers.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc3_.notifiers[_loc4_];
            if(_loc6_ != null)
            {
               if(_loc6_.name == param2)
               {
                  return _loc6_.time;
               }
            }
            _loc4_++;
         }
         return 0;
      }
      
      public function replay() : void
      {
         if(this._currentAnimName == null)
         {
            return;
         }
         this.gotoAndPlay(this._currentAnimName,0,this._currentAnimLoop,this._currentAnimSpeed,0);
      }
      
      public function gotoAndPlay(param1:String, param2:Number = 0, param3:Boolean = false, param4:Number = 1, param5:Number = 0.25) : Boolean
      {
         clearTimeout(this._delayTimeout);
         var _loc6_:AnimationClip = this._animsByName[param1];
         if(_loc6_ == null)
         {
            return false;
         }
         var _loc7_:* = _loc6_ != this._currentAnim;
         _loc6_.animated = true;
         _loc6_.speed = param4;
         _loc6_.loop = param3;
         _loc6_.time = param2;
         this._currentAnim = _loc6_;
         this._currentAnimName = param1;
         this._currentAnimLoop = param3;
         this._currentAnimSpeed = param4;
         this.animSpeedMultiplier = 1;
         this._switcher.activate(_loc6_,param5);
         this._switcher.speed = this.animSpeedMultiplier;
         this.setupNotificationListeners(!param3);
         this._controller.update();
         this._isPlaying = true;
         if(_loc7_)
         {
            this.animationChanged.dispatch(param1);
         }
         return true;
      }
      
      public function gotoAndStop(param1:String, param2:Number = 0, param3:Number = 0.25) : Boolean
      {
         clearTimeout(this._delayTimeout);
         var _loc4_:AnimationClip = this._animsByName[param1];
         if(_loc4_ == null)
         {
            return false;
         }
         var _loc5_:* = _loc4_ != this._currentAnim;
         _loc4_.animated = false;
         _loc4_.speed = 1;
         _loc4_.loop = false;
         _loc4_.time = param2;
         this.clearNotificationListeners();
         this._currentAnim = _loc4_;
         this._currentAnimName = param1;
         this._currentAnimLoop = false;
         this._currentAnimSpeed = 1;
         this.animSpeedMultiplier = 1;
         this._switcher.activate(_loc4_,0);
         this._switcher.speed = this.animSpeedMultiplier;
         this._controller.freeze();
         this._isPlaying = false;
         if(_loc5_)
         {
            this.animationChanged.dispatch(param1);
         }
         return true;
      }
      
      public function play(param1:String, param2:Boolean = false, param3:Number = 1, param4:Number = 0.15) : Boolean
      {
         clearTimeout(this._delayTimeout);
         var _loc5_:AnimationClip = this._animsByName[param1];
         if(_loc5_ == null)
         {
            return false;
         }
         var _loc6_:* = _loc5_ != this._currentAnim;
         _loc5_.animated = true;
         _loc5_.speed = param3;
         _loc5_.loop = param2;
         if(param1 != this._currentAnimName)
         {
            _loc5_.time = 0;
         }
         this._currentAnim = _loc5_;
         this._currentAnimName = param1;
         this._currentAnimSpeed = param3;
         this._currentAnimLoop = true;
         this.animSpeedMultiplier = 1;
         this._switcher.activate(_loc5_,param4);
         this._switcher.speed = this.animSpeedMultiplier;
         this.setupNotificationListeners(!param2);
         this._controller.update();
         this._isPlaying = true;
         if(_loc6_)
         {
            this.animationChanged.dispatch(param1);
         }
         return true;
      }
      
      public function playWithDelay(param1:String, param2:Number = 0, param3:Boolean = false, param4:Number = 1, param5:Number = 0.15) : void
      {
         var name:String = param1;
         var delay:Number = param2;
         var loop:Boolean = param3;
         var speed:Number = param4;
         var blendTime:Number = param5;
         clearTimeout(this._delayTimeout);
         this._currentAnimName = name;
         this._delayTimeout = setTimeout(function():void
         {
            play(name,loop,speed,blendTime);
         },delay * 1000);
      }
      
      public function stop() : void
      {
         clearTimeout(this._delayTimeout);
         if(this._currentAnim != null)
         {
            this._currentAnim.animated = false;
         }
         this._controller.freeze();
         this._currentAnim = null;
         this._currentAnimName = null;
         this._currentAnimLoop = false;
         this._isPlaying = false;
         this.clearNotificationListeners();
      }
      
      public function updateAnimation(param1:Number) : void
      {
         if(this._isPlaying)
         {
            this._switcher.speed = this.animSpeedMultiplier;
            this._controller.update();
         }
         else
         {
            this._controller.freeze();
         }
      }
      
      private function clearNotificationListeners() : void
      {
         var _loc2_:AnimationNotify = null;
         if(this._currentAnim == null)
         {
            return;
         }
         var _loc1_:int = int(this._currentAnim.notifiers.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this._currentAnim.notifiers[_loc1_];
            if(_loc2_ != null)
            {
               _loc2_.removeEventListener(NotifyEvent.NOTIFY,this.onAnimationNotification);
               if(_loc2_.name == "_end")
               {
                  this._currentAnim.removeNotify(_loc2_);
               }
            }
            _loc1_--;
         }
      }
      
      private function setupNotificationListeners(param1:Boolean) : void
      {
         var _loc3_:AnimationNotify = null;
         this.clearNotificationListeners();
         if(this._currentAnim == null)
         {
            return;
         }
         var _loc2_:Boolean = false;
         for each(_loc3_ in this._currentAnim.notifiers)
         {
            if(_loc3_.name == "_end")
            {
               if(!param1)
               {
                  _loc3_.removeEventListener(NotifyEvent.NOTIFY,this.onAnimationNotification);
                  continue;
               }
               _loc2_ = true;
            }
            _loc3_.addEventListener(NotifyEvent.NOTIFY,this.onAnimationNotification,false,0,true);
         }
         if(param1 && !_loc2_)
         {
            this._currentAnim.addNotifyAtEnd(0,"_end").addEventListener(NotifyEvent.NOTIFY,this.onAnimationNotification,false,0,true);
         }
      }
      
      private function onAnimationNotification(param1:NotifyEvent) : void
      {
         if(param1.notify.name == "_end")
         {
            this.animationCompleted.dispatch(this._currentAnimName);
         }
         else
         {
            this.animationNotified.dispatch(this._currentAnimName,param1.notify.name);
         }
      }
      
      public function get currentAnimation() : String
      {
         return this._currentAnimName;
      }
      
      public function get isPlaying() : Boolean
      {
         return this._isPlaying;
      }
   }
}

