package com.greensock.plugins
{
   import com.greensock.*;
   import flash.display.*;
   import flash.geom.*;
   
   public class TransformAroundCenterPlugin extends TransformAroundPointPlugin
   {
      
      public static const API:Number = 1;
      
      public function TransformAroundCenterPlugin()
      {
         super();
         this.propName = "transformAroundCenter";
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         var _loc4_:Rectangle = param1.getBounds(param1);
         param2.point = new Point(_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2);
         param2.pointIsLocal = true;
         return super.onInitTween(param1,param2,param3);
      }
   }
}

