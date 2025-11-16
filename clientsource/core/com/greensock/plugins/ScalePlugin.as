package com.greensock.plugins
{
   import com.greensock.*;
   
   public class ScalePlugin extends TweenPlugin
   {
      
      public static const API:Number = 1;
      
      protected var _target:Object;
      
      protected var _startX:Number;
      
      protected var _changeX:Number;
      
      protected var _startY:Number;
      
      protected var _changeY:Number;
      
      public function ScalePlugin()
      {
         super();
         this.propName = "scale";
         this.overwriteProps = ["scaleX","scaleY","width","height"];
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(!param1.hasOwnProperty("scaleX"))
         {
            return false;
         }
         this._target = param1;
         this._startX = this._target.scaleX;
         this._startY = this._target.scaleY;
         if(typeof param2 == "number")
         {
            this._changeX = param2 - this._startX;
            this._changeY = param2 - this._startY;
         }
         else
         {
            this._changeX = this._changeY = Number(param2);
         }
         return true;
      }
      
      override public function killProps(param1:Object) : void
      {
         var _loc2_:int = int(this.overwriteProps.length);
         while(_loc2_--)
         {
            if(this.overwriteProps[_loc2_] in param1)
            {
               this.overwriteProps = [];
               return;
            }
         }
      }
      
      override public function set changeFactor(param1:Number) : void
      {
         this._target.scaleX = this._startX + param1 * this._changeX;
         this._target.scaleY = this._startY + param1 * this._changeY;
      }
   }
}

