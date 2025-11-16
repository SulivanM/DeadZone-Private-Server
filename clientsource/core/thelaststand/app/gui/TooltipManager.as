package thelaststand.app.gui
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class TooltipManager
   {
      
      private static var _instance:TooltipManager;
      
      private var _currentObject:InteractiveObject;
      
      private var _dataByObject:Dictionary;
      
      private var _defaultDelay:Number = 0.4;
      
      private var _timer:Timer;
      
      private var _tooltip:Tooltip;
      
      public var stage:Stage;
      
      public function TooltipManager(param1:TooltipManagerSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("TooltipManager is a Singleton and cannot be directly instantiated. Use TooltipManager.getInstance().");
         }
         this._tooltip = new Tooltip();
         this._dataByObject = new Dictionary(true);
         this._timer = new Timer(this._defaultDelay * 1000,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
      }
      
      public static function getInstance() : TooltipManager
      {
         if(!_instance)
         {
            _instance = new TooltipManager(new TooltipManagerSingletonEnforcer());
         }
         return _instance;
      }
      
      public function add(param1:InteractiveObject, param2:*, param3:Point = null, param4:int = 0, param5:Number = NaN) : void
      {
         if(!(param2 is String) && !(param2 is DisplayObject) && !(param2 is Function))
         {
            throw new Error("Tooltip content must be of type String, DisplayObject or Function");
         }
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.onObjectMouseOver,false,int.MAX_VALUE,true);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.onObjectMouseLeave,false,int.MAX_VALUE,true);
         param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onObjectMouseLeave,false,int.MAX_VALUE,true);
         var _loc6_:TooltipData = new TooltipData();
         _loc6_.content = param2;
         _loc6_.position = param3;
         _loc6_.direction = param4;
         _loc6_.delay = param5;
         this._dataByObject[param1] = _loc6_;
      }
      
      public function show(param1:InteractiveObject) : void
      {
         this._currentObject = param1;
         this._timer.stop();
         this.showTooltip();
      }
      
      public function hide() : void
      {
         this.hideTooltip();
      }
      
      public function removeAll() : void
      {
         var _loc1_:Object = null;
         var _loc2_:InteractiveObject = null;
         for each(_loc1_ in this._dataByObject)
         {
            _loc2_ = _loc1_ as InteractiveObject;
            if(_loc2_ != null)
            {
               this.remove(_loc2_);
            }
         }
      }
      
      public function removeAllFromParent(param1:DisplayObjectContainer, param2:Boolean = true) : void
      {
         var _loc5_:InteractiveObject = null;
         if(param1 is InteractiveObject)
         {
            this.remove(InteractiveObject(param1));
         }
         var _loc3_:int = 0;
         var _loc4_:int = param1.numChildren;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param1.getChildAt(_loc3_) as InteractiveObject;
            if(_loc5_ != null && this._dataByObject[_loc5_] != null)
            {
               this.remove(_loc5_);
               if(param2 && _loc5_ is DisplayObjectContainer)
               {
                  this.removeAllFromParent(_loc5_ as DisplayObjectContainer);
               }
            }
            _loc3_++;
         }
      }
      
      public function remove(param1:InteractiveObject) : void
      {
         if(param1 == this._currentObject)
         {
            this._timer.stop();
         }
         param1.removeEventListener(MouseEvent.MOUSE_OVER,this.onObjectMouseOver);
         param1.removeEventListener(MouseEvent.MOUSE_OUT,this.onObjectMouseLeave);
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onObjectMouseLeave);
         var _loc2_:TooltipData = this._dataByObject[param1] as TooltipData;
         if(_loc2_ != null)
         {
            _loc2_.dispose();
         }
         this._dataByObject[param1] = null;
         delete this._dataByObject[param1];
      }
      
      private function showTooltip() : void
      {
         var _loc1_:Point = null;
         if(this._currentObject == null || this.stage == null || this._tooltip == null)
         {
            return;
         }
         var _loc2_:TooltipData = this._dataByObject[this._currentObject];
         if(_loc2_ == null || _loc2_.content == null)
         {
            return;
         }
         var _loc3_:Rectangle = this._currentObject.getBounds(this._currentObject);
         if(_loc2_ != null && _loc2_.position != null)
         {
            if(isNaN(_loc2_.position.x))
            {
               _loc2_.position.x = _loc3_.x + _loc3_.width * 0.5;
            }
            if(isNaN(_loc2_.position.y))
            {
               _loc2_.position.y = _loc3_.y + _loc3_.height * 0.5;
            }
            _loc1_ = this._currentObject.localToGlobal(_loc2_.position);
         }
         else
         {
            _loc1_ = this._currentObject.localToGlobal(new Point(_loc3_.x + _loc3_.width * 0.5,_loc3_.y + _loc3_.height * 0.5));
         }
         this.stage.addChild(this._tooltip);
         this._tooltip.setTooltip(_loc2_.content,_loc2_.direction,_loc1_);
      }
      
      private function hideTooltip() : void
      {
         if(this._tooltip != null && this._tooltip.parent != null)
         {
            this._tooltip.parent.removeChild(this._tooltip);
         }
         this._currentObject = null;
      }
      
      private function onObjectMouseOver(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         this._currentObject = param1.currentTarget as InteractiveObject;
         var _loc2_:TooltipData = this._dataByObject[this._currentObject];
         if(_loc2_ == null)
         {
            return;
         }
         this._timer.delay = (isNaN(_loc2_.delay) ? this._defaultDelay : _loc2_.delay) * 1000;
         this._timer.reset();
         this._timer.start();
      }
      
      private function onObjectMouseLeave(param1:MouseEvent) : void
      {
         if(param1.currentTarget as InteractiveObject == this._currentObject)
         {
            this.hideTooltip();
         }
         this._timer.stop();
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         this.showTooltip();
      }
      
      public function get defaultDelay() : Number
      {
         return this._defaultDelay;
      }
      
      public function set defaultDelay(param1:Number) : void
      {
         this._defaultDelay = param1;
      }
   }
}

import flash.geom.Point;

class TooltipManagerSingletonEnforcer
{
   
   public function TooltipManagerSingletonEnforcer()
   {
      super();
   }
}

class TooltipData
{
   
   public var position:Point;
   
   public var content:*;
   
   public var direction:int;
   
   public var delay:Number = NaN;
   
   public function TooltipData()
   {
      super();
   }
   
   public function dispose() : void
   {
      this.position = null;
      this.content = null;
   }
}
