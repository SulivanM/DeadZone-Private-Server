package com.greensock.plugins
{
   import com.greensock.*;
   import com.greensock.core.*;
   import flash.display.*;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   
   public class TransformAroundPointPlugin extends TweenPlugin
   {
      
      private static var _classInitted:Boolean;
      
      private static var _isFlex:Boolean;
      
      public static const API:Number = 1;
      
      protected var _target:DisplayObject;
      
      protected var _local:Point;
      
      protected var _point:Point;
      
      protected var _shortRotation:ShortRotationPlugin;
      
      protected var _proxy:DisplayObject;
      
      protected var _proxySizeData:Object;
      
      protected var _useAddElement:Boolean;
      
      public function TransformAroundPointPlugin()
      {
         super();
         this.propName = "transformAroundPoint";
         this.overwriteProps = ["x","y"];
         this.priority = -1;
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         var p:String = null;
         var short:ShortRotationPlugin = null;
         var sp:String = null;
         var m:Matrix = null;
         var point:Point = null;
         var b:Rectangle = null;
         var s:Sprite = null;
         var container:Sprite = null;
         var enumerables:Object = null;
         var endX:Number = NaN;
         var endY:Number = NaN;
         var target:Object = param1;
         var value:* = param2;
         var tween:TweenLite = param3;
         if(!(value.point is Point))
         {
            return false;
         }
         this._target = target as DisplayObject;
         if(value.pointIsLocal == true)
         {
            this._local = value.point.clone();
            this._point = this._target.parent.globalToLocal(this._target.localToGlobal(this._local));
         }
         else
         {
            this._point = value.point.clone();
            this._local = this._target.globalToLocal(this._target.parent.localToGlobal(this._point));
         }
         if(!_classInitted)
         {
            try
            {
               _isFlex = Boolean(getDefinitionByName("mx.managers.SystemManager"));
            }
            catch(e:Error)
            {
               _isFlex = false;
            }
            _classInitted = true;
         }
         if((!isNaN(value.width) || !isNaN(value.height)) && this._target.parent != null)
         {
            m = this._target.transform.matrix;
            point = this._target.parent.globalToLocal(this._target.localToGlobal(new Point(100,100)));
            this._target.width *= 2;
            if(point.x == this._target.parent.globalToLocal(this._target.localToGlobal(new Point(100,100))).x)
            {
               this._proxy = this._target;
               this._target.rotation = 0;
               this._proxySizeData = {};
               if(!isNaN(value.width))
               {
                  addTween(this._proxySizeData,"width",this._target.width / 2,value.width,"width");
               }
               if(!isNaN(value.height))
               {
                  addTween(this._proxySizeData,"height",this._target.height,value.height,"height");
               }
               b = this._target.getBounds(this._target);
               s = new Sprite();
               container = _isFlex ? new (getDefinitionByName("mx.core.UIComponent"))() : new Sprite();
               container.addChild(s);
               container.visible = false;
               this._useAddElement = Boolean(_isFlex && this._proxy.parent.hasOwnProperty("addElement"));
               if(this._useAddElement)
               {
                  Object(this._proxy.parent).addElement(container);
               }
               else
               {
                  this._proxy.parent.addChild(container);
               }
               this._target = s;
               s.graphics.beginFill(255,0.4);
               s.graphics.drawRect(b.x,b.y,b.width,b.height);
               s.graphics.endFill();
               this._proxy.width /= 2;
               s.transform.matrix = this._target.transform.matrix = m;
            }
            else
            {
               this._target.width /= 2;
               this._target.transform.matrix = m;
            }
         }
         for(p in value)
         {
            if(!(p == "point" || p == "pointIsLocal"))
            {
               if(p == "shortRotation")
               {
                  this._shortRotation = new ShortRotationPlugin();
                  this._shortRotation.onInitTween(this._target,value[p],tween);
                  addTween(this._shortRotation,"changeFactor",0,1,"shortRotation");
                  for(sp in value[p])
                  {
                     this.overwriteProps[this.overwriteProps.length] = sp;
                  }
               }
               else if(p == "x" || p == "y")
               {
                  addTween(this._point,p,this._point[p],value[p],p);
               }
               else if(p == "scale")
               {
                  addTween(this._target,"scaleX",this._target.scaleX,value.scale,"scaleX");
                  addTween(this._target,"scaleY",this._target.scaleY,value.scale,"scaleY");
                  this.overwriteProps[this.overwriteProps.length] = "scaleX";
                  this.overwriteProps[this.overwriteProps.length] = "scaleY";
               }
               else if(!((p == "width" || p == "height") && this._proxy != null))
               {
                  addTween(this._target,p,this._target[p],value[p],p);
                  this.overwriteProps[this.overwriteProps.length] = p;
               }
            }
         }
         if(tween != null)
         {
            enumerables = tween.vars;
            if("x" in enumerables || "y" in enumerables)
            {
               if("x" in enumerables)
               {
                  endX = typeof enumerables.x == "number" ? Number(enumerables.x) : this._target.x + Number(enumerables.x);
               }
               if("y" in enumerables)
               {
                  endY = typeof enumerables.y == "number" ? Number(enumerables.y) : this._target.y + Number(enumerables.y);
               }
               tween.killVars({
                  "x":true,
                  "y":true
               },false);
               this.changeFactor = 1;
               if(!isNaN(endX))
               {
                  addTween(this._point,"x",this._point.x,this._point.x + (endX - this._target.x),"x");
               }
               if(!isNaN(endY))
               {
                  addTween(this._point,"y",this._point.y,this._point.y + (endY - this._target.y),"y");
               }
               this.changeFactor = 0;
            }
         }
         return true;
      }
      
      override public function killProps(param1:Object) : void
      {
         if(this._shortRotation != null)
         {
            this._shortRotation.killProps(param1);
            if(this._shortRotation.overwriteProps.length == 0)
            {
               param1.shortRotation = true;
            }
         }
         super.killProps(param1);
      }
      
      override public function set changeFactor(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Point = null;
         var _loc6_:PropTween = null;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         if(this._proxy != null && this._proxy.parent != null)
         {
            if(this._useAddElement)
            {
               Object(this._proxy.parent).addElement(this._target.parent);
            }
            else
            {
               this._proxy.parent.addChild(this._target.parent);
            }
         }
         if(this._target.parent)
         {
            _loc7_ = int(_tweens.length);
            if(this.round)
            {
               while(--_loc7_ > -1)
               {
                  _loc6_ = _tweens[_loc7_];
                  _loc2_ = _loc6_.start + _loc6_.change * param1;
                  _loc6_.target[_loc6_.property] = _loc2_ > 0 ? int(_loc2_ + 0.5) : int(_loc2_ - 0.5);
               }
               _loc5_ = this._target.parent.globalToLocal(this._target.localToGlobal(this._local));
               _loc3_ = this._target.x + this._point.x - _loc5_.x;
               _loc4_ = this._target.y + this._point.y - _loc5_.y;
               this._target.x = _loc3_ > 0 ? int(_loc3_ + 0.5) : int(_loc3_ - 0.5);
               this._target.y = _loc4_ > 0 ? int(_loc4_ + 0.5) : int(_loc4_ - 0.5);
            }
            else
            {
               while(--_loc7_ > -1)
               {
                  _loc6_ = _tweens[_loc7_];
                  _loc6_.target[_loc6_.property] = _loc6_.start + _loc6_.change * param1;
               }
               _loc5_ = this._target.parent.globalToLocal(this._target.localToGlobal(this._local));
               this._target.x += this._point.x - _loc5_.x;
               this._target.y += this._point.y - _loc5_.y;
            }
         }
         _changeFactor = param1;
         if(this._proxy != null && this._proxy.parent != null)
         {
            _loc8_ = this._target.rotation;
            this._proxy.rotation = this._target.rotation = 0;
            if(this._proxySizeData.width != undefined)
            {
               this._proxy.width = this._target.width = this._proxySizeData.width;
            }
            if(this._proxySizeData.height != undefined)
            {
               this._proxy.height = this._target.height = this._proxySizeData.height;
            }
            this._proxy.rotation = this._target.rotation = _loc8_;
            _loc5_ = this._target.parent.globalToLocal(this._target.localToGlobal(this._local));
            _loc3_ = this._target.x + this._point.x - _loc5_.x;
            _loc4_ = this._target.y + this._point.y - _loc5_.y;
            if(this.round)
            {
               this._proxy.x = _loc3_ > 0 ? int(_loc3_ + 0.5) : int(_loc3_ - 0.5);
               this._proxy.y = _loc4_ > 0 ? int(_loc4_ + 0.5) : int(_loc4_ - 0.5);
            }
            else
            {
               this._proxy.x = _loc3_;
               this._proxy.y = _loc4_;
            }
            if(this._useAddElement)
            {
               Object(this._proxy.parent).removeElement(this._target.parent);
            }
            else
            {
               this._proxy.parent.removeChild(this._target.parent);
            }
         }
      }
   }
}

