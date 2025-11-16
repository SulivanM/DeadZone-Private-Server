package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class MemoryMonitor extends ConsoleCore
   {
      
      private var _namesList:Object;
      
      private var _objectsList:Dictionary;
      
      private var _count:uint;
      
      public function MemoryMonitor(param1:Console)
      {
         super(param1);
         this._namesList = new Object();
         this._objectsList = new Dictionary(true);
         console.remoter.registerCallback("gc",this.gc);
      }
      
      public function watch(param1:Object, param2:String) : String
      {
         var _loc3_:String = getQualifiedClassName(param1);
         if(!param2)
         {
            param2 = _loc3_ + "@" + getTimer();
         }
         if(this._objectsList[param1])
         {
            if(this._namesList[this._objectsList[param1]])
            {
               this.unwatch(this._objectsList[param1]);
            }
         }
         if(this._namesList[param2])
         {
            if(this._objectsList[param1] == param2)
            {
               --this._count;
            }
            else
            {
               param2 = param2 + "@" + getTimer() + "_" + Math.floor(Math.random() * 100);
            }
         }
         this._namesList[param2] = true;
         ++this._count;
         this._objectsList[param1] = param2;
         return param2;
      }
      
      public function unwatch(param1:String) : void
      {
         var _loc2_:Object = null;
         for(_loc2_ in this._objectsList)
         {
            if(this._objectsList[_loc2_] == param1)
            {
               delete this._objectsList[_loc2_];
            }
         }
         if(this._namesList[param1])
         {
            delete this._namesList[param1];
            --this._count;
         }
      }
      
      public function update() : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         if(this._count == 0)
         {
            return;
         }
         var _loc1_:Array = new Array();
         var _loc2_:Object = new Object();
         for(_loc3_ in this._objectsList)
         {
            _loc2_[this._objectsList[_loc3_]] = true;
         }
         for(_loc4_ in this._namesList)
         {
            if(!_loc2_[_loc4_])
            {
               _loc1_.push(_loc4_);
               delete this._namesList[_loc4_];
               --this._count;
            }
         }
         if(_loc1_.length)
         {
            report("<b>GARBAGE COLLECTED " + _loc1_.length + " item(s): </b>" + _loc1_.join(", "),-2);
         }
      }
      
      public function get count() : uint
      {
         return this._count;
      }
      
      public function gc() : void
      {
         var ok:Boolean = false;
         var str:String = null;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            try
            {
               remoter.send("gc");
            }
            catch(e:Error)
            {
               report(e,10);
            }
         }
         else
         {
            try
            {
               if(System["gc"] != null)
               {
                  System["gc"]();
                  ok = true;
               }
            }
            catch(e:Error)
            {
            }
            str = "Manual garbage collection " + (ok ? "successful." : "FAILED. You need debugger version of flash player.");
            report(str,ok ? -1 : 10);
         }
      }
   }
}

