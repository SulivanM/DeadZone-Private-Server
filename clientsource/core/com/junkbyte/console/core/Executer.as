package com.junkbyte.console.core
{
   import com.junkbyte.console.vos.WeakObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getDefinitionByName;
   
   public class Executer extends EventDispatcher
   {
      
      public static const RETURNED:String = "returned";
      
      public static const CLASSES:String = "ExeValue|((com.junkbyte.console.core::)?Executer)";
      
      private static const VALKEY:String = "#";
      
      private var _values:Array;
      
      private var _running:Boolean;
      
      private var _scope:*;
      
      private var _returned:*;
      
      private var _saved:Object;
      
      private var _reserved:Array;
      
      public var autoScope:Boolean;
      
      public function Executer()
      {
         super();
      }
      
      public static function Exec(param1:Object, param2:String, param3:Object = null) : *
      {
         var _loc4_:Executer = new Executer();
         _loc4_.setStored(param3);
         return _loc4_.exec(param1,param2);
      }
      
      public function get returned() : *
      {
         return this._returned;
      }
      
      public function get scope() : *
      {
         return this._scope;
      }
      
      public function setStored(param1:Object) : void
      {
         this._saved = param1;
      }
      
      public function setReserved(param1:Array) : void
      {
         this._reserved = param1;
      }
      
      public function exec(param1:*, param2:String) : *
      {
         var s:* = param1;
         var str:String = param2;
         if(this._running)
         {
            throw new Error("CommandExec.exec() is already runnnig. Does not support loop backs.");
         }
         this._running = true;
         this._scope = s;
         this._values = [];
         if(!this._saved)
         {
            this._saved = new Object();
         }
         if(!this._reserved)
         {
            this._reserved = new Array();
         }
         try
         {
            this._exec(str);
         }
         catch(e:Error)
         {
            reset();
            throw e;
         }
         this.reset();
         return this._returned;
      }
      
      private function reset() : void
      {
         this._saved = null;
         this._reserved = null;
         this._values = null;
         this._running = false;
      }
      
      private function _exec(param1:String) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:* = undefined;
         var _loc2_:RegExp = /''|""|('(.*?)[^\\]')|("(.*?)[^\\]")/;
         var _loc3_:Object = _loc2_.exec(param1);
         while(_loc3_ != null)
         {
            _loc6_ = _loc3_[0];
            _loc7_ = _loc6_.charAt(0);
            _loc8_ = int(_loc6_.indexOf(_loc7_));
            _loc9_ = int(_loc6_.lastIndexOf(_loc7_));
            _loc10_ = _loc6_.substring(_loc8_ + 1,_loc9_).replace(/\\(.)/g,"$1");
            param1 = this.tempValue(param1,new ExeValue(_loc10_),_loc3_.index + _loc8_,_loc3_.index + _loc9_ + 1);
            _loc3_ = _loc2_.exec(param1);
         }
         if(param1.search(/'|"/) >= 0)
         {
            throw new Error("Bad syntax extra quotation marks");
         }
         var _loc4_:Array = param1.split(/\s*;\s*/);
         for each(_loc5_ in _loc4_)
         {
            if(_loc5_.length)
            {
               _loc11_ = this._saved[RETURNED];
               if((_loc11_) && _loc5_ == "/")
               {
                  this._scope = _loc11_;
                  dispatchEvent(new Event(Event.COMPLETE));
               }
               else
               {
                  this.execNest(_loc5_);
               }
            }
         }
      }
      
      private function execNest(param1:String) : *
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:Array = null;
         var _loc11_:String = null;
         var _loc12_:ExeValue = null;
         var _loc13_:* = null;
         param1 = this.ignoreWhite(param1);
         var _loc2_:int = int(param1.lastIndexOf("("));
         while(_loc2_ >= 0)
         {
            _loc3_ = int(param1.indexOf(")",_loc2_));
            if(param1.substring(_loc2_ + 1,_loc3_).search(/\w/) >= 0)
            {
               _loc4_ = _loc2_;
               _loc5_ = _loc2_ + 1;
               while(_loc4_ >= 0 && _loc4_ < _loc5_)
               {
                  _loc4_++;
                  _loc4_ = int(param1.indexOf("(",_loc4_));
                  _loc5_ = int(param1.indexOf(")",_loc5_ + 1));
               }
               _loc6_ = param1.substring(_loc2_ + 1,_loc5_);
               _loc7_ = false;
               _loc8_ = _loc2_ - 1;
               while(true)
               {
                  _loc9_ = param1.charAt(_loc8_);
                  if(Boolean(_loc9_.match(/[^\s]/)) || _loc8_ <= 0)
                  {
                     break;
                  }
                  _loc8_--;
               }
               if(_loc9_.match(/\w/))
               {
                  _loc7_ = true;
               }
               if(_loc7_)
               {
                  _loc10_ = _loc6_.split(",");
                  param1 = this.tempValue(param1,new ExeValue(_loc10_),_loc2_ + 1,_loc5_);
                  for(_loc11_ in _loc10_)
                  {
                     _loc10_[_loc11_] = this.execOperations(this.ignoreWhite(_loc10_[_loc11_])).value;
                  }
               }
               else
               {
                  _loc12_ = new ExeValue(_loc12_);
                  param1 = this.tempValue(param1,_loc12_,_loc2_,_loc5_ + 1);
                  _loc12_.setValue(this.execOperations(this.ignoreWhite(_loc6_)).value);
               }
            }
            _loc2_ = int(param1.lastIndexOf("(",_loc2_ - 1));
         }
         this._returned = this.execOperations(param1).value;
         if(this._returned && this.autoScope)
         {
            _loc13_ = typeof this._returned;
            if(_loc13_ == "object" || _loc13_ == "xml")
            {
               this._scope = this._returned;
            }
         }
         dispatchEvent(new Event(Event.COMPLETE));
         return this._returned;
      }
      
      private function tempValue(param1:String, param2:*, param3:int, param4:int) : String
      {
         param1 = param1.substring(0,param3) + VALKEY + this._values.length + param1.substring(param4);
         this._values.push(param2);
         return param1;
      }
      
      private function execOperations(param1:String) : ExeValue
      {
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:String = null;
         var _loc14_:ExeValue = null;
         var _loc15_:ExeValue = null;
         var _loc2_:RegExp = /\s*(((\|\||\&\&|[+|\-|*|\/|\%|\||\&|\^]|\=\=?|\!\=|\>\>?\>?|\<\<?)\=?)|=|\~|\sis\s|typeof|delete\s)\s*/g;
         var _loc3_:Object = _loc2_.exec(param1);
         var _loc4_:Array = [];
         if(_loc3_ == null)
         {
            _loc4_.push(param1);
         }
         else
         {
            _loc11_ = 0;
            while(_loc3_ != null)
            {
               _loc12_ = int(_loc3_.index);
               _loc13_ = _loc3_[0];
               _loc3_ = _loc2_.exec(param1);
               if(_loc3_ == null)
               {
                  _loc4_.push(param1.substring(_loc11_,_loc12_));
                  _loc4_.push(this.ignoreWhite(_loc13_));
                  _loc4_.push(param1.substring(_loc12_ + _loc13_.length));
               }
               else
               {
                  _loc4_.push(param1.substring(_loc11_,_loc12_));
                  _loc4_.push(this.ignoreWhite(_loc13_));
                  _loc11_ = _loc12_ + _loc13_.length;
               }
            }
         }
         var _loc5_:int = int(_loc4_.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_[_loc6_] = this.execSimple(_loc4_[_loc6_]);
            _loc6_ += 2;
         }
         var _loc9_:RegExp = /((\|\||\&\&|[+|\-|*|\/|\%|\||\&|\^]|\>\>\>?|\<\<)\=)|=/;
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc7_.replace(_loc9_,"") != "")
            {
               _loc8_ = this.operate(_loc4_[_loc6_ - 1],_loc7_,_loc4_[_loc6_ + 1]);
               _loc14_ = ExeValue(_loc4_[_loc6_ - 1]);
               _loc14_.setValue(_loc8_);
               _loc4_.splice(_loc6_,2);
               _loc6_ -= 2;
               _loc5_ -= 2;
            }
            _loc6_ += 2;
         }
         _loc4_.reverse();
         var _loc10_:ExeValue = _loc4_[0];
         _loc6_ = 1;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = _loc4_[_loc6_];
            if(_loc7_.replace(_loc9_,"") == "")
            {
               _loc10_ = _loc4_[_loc6_ - 1];
               _loc15_ = _loc4_[_loc6_ + 1];
               if(_loc7_.length > 1)
               {
                  _loc7_ = _loc7_.substring(0,_loc7_.length - 1);
               }
               _loc8_ = this.operate(_loc15_,_loc7_,_loc10_);
               _loc15_.setValue(_loc8_);
            }
            _loc6_ += 2;
         }
         return _loc10_;
      }
      
      private function execSimple(param1:String) : ExeValue
      {
         var reg:RegExp;
         var result:Object;
         var previndex:int;
         var firstparts:Array = null;
         var newstr:String = null;
         var defclose:int = 0;
         var newobj:* = undefined;
         var classstr:String = null;
         var def:* = undefined;
         var havemore:Boolean = false;
         var index:int = 0;
         var isFun:Boolean = false;
         var basestr:String = null;
         var newv:ExeValue = null;
         var newbase:* = undefined;
         var closeindex:int = 0;
         var paramstr:String = null;
         var params:Array = null;
         var nss:Array = null;
         var ns:Namespace = null;
         var nsv:* = undefined;
         var str:String = param1;
         var v:ExeValue = new ExeValue(this._scope);
         if(str.indexOf("new ") == 0)
         {
            newstr = str;
            defclose = int(str.indexOf(")"));
            if(defclose >= 0)
            {
               newstr = str.substring(0,defclose + 1);
            }
            newobj = this.makeNew(newstr.substring(4));
            str = this.tempValue(str,new ExeValue(newobj),0,newstr.length);
         }
         reg = /\.|\(/g;
         result = reg.exec(str);
         if(result == null || !isNaN(Number(str)))
         {
            return this.execValue(str,this._scope);
         }
         firstparts = String(str.split("(")[0]).split(".");
         if(firstparts.length > 0)
         {
            while(firstparts.length)
            {
               classstr = firstparts.join(".");
               try
               {
                  def = getDefinitionByName(this.ignoreWhite(classstr));
                  havemore = str.length > classstr.length;
                  str = this.tempValue(str,new ExeValue(def),0,classstr.length);
                  if(havemore)
                  {
                     reg.lastIndex = 0;
                     result = reg.exec(str);
                     break;
                  }
                  return this.execValue(str);
               }
               catch(e:Error)
               {
                  firstparts.pop();
               }
            }
         }
         previndex = 0;
         while(true)
         {
            if(result == null)
            {
               return v;
            }
            index = int(result.index);
            isFun = str.charAt(index) == "(";
            basestr = this.ignoreWhite(str.substring(previndex,index));
            newv = previndex == 0 ? this.execValue(basestr,v.value) : new ExeValue(v.value,basestr);
            if(isFun)
            {
               newbase = newv.value;
               closeindex = int(str.indexOf(")",index));
               paramstr = str.substring(index + 1,closeindex);
               paramstr = this.ignoreWhite(paramstr);
               params = [];
               if(paramstr)
               {
                  params = this.execValue(paramstr).value;
               }
               if(!(newbase is Function))
               {
                  try
                  {
                     nss = [AS3];
                     for each(ns in nss)
                     {
                        nsv = v.obj.ns::[basestr];
                        if(nsv is Function)
                        {
                           newbase = nsv;
                           break;
                        }
                     }
                  }
                  catch(e:Error)
                  {
                  }
                  if(!(newbase is Function))
                  {
                     break;
                  }
               }
               v.obj = (newbase as Function).apply(v.value,params);
               v.prop = null;
               index = closeindex + 1;
            }
            else
            {
               v = newv;
            }
            previndex = index + 1;
            reg.lastIndex = index + 1;
            result = reg.exec(str);
            if(result == null)
            {
               if(index + 1 < str.length)
               {
                  reg.lastIndex = str.length;
                  result = {"index":str.length};
               }
            }
         }
         throw new Error(basestr + " is not a function.");
      }
      
      private function execValue(param1:String, param2:* = null) : ExeValue
      {
         var v:ExeValue = null;
         var vv:ExeValue = null;
         var key:String = null;
         var str:String = param1;
         var base:* = param2;
         v = new ExeValue();
         if(str == "true")
         {
            v.obj = true;
         }
         else if(str == "false")
         {
            v.obj = false;
         }
         else if(str == "this")
         {
            v.obj = this._scope;
         }
         else if(str == "null")
         {
            v.obj = null;
         }
         else if(!isNaN(Number(str)))
         {
            v.obj = Number(str);
         }
         else if(str.indexOf(VALKEY) == 0)
         {
            vv = this._values[str.substring(VALKEY.length)];
            v.obj = vv.value;
         }
         else if(str.charAt(0) == "$")
         {
            key = str.substring(1);
            if(this._reserved.indexOf(key) < 0)
            {
               v.obj = this._saved;
               v.prop = key;
            }
            else if(this._saved is WeakObject)
            {
               v.obj = WeakObject(this._saved).get(key);
            }
            else
            {
               v.obj = this._saved[key];
            }
         }
         else
         {
            try
            {
               v.obj = getDefinitionByName(str);
            }
            catch(e:Error)
            {
               v.obj = base;
               v.prop = str;
            }
         }
         return v;
      }
      
      private function operate(param1:ExeValue, param2:String, param3:ExeValue) : *
      {
         switch(param2)
         {
            case "=":
               return param3.value;
            case "+":
               return param1.value + param3.value;
            case "-":
               return param1.value - param3.value;
            case "*":
               return param1.value * param3.value;
            case "/":
               return param1.value / param3.value;
            case "%":
               return param1.value % param3.value;
            case "^":
               return param1.value ^ param3.value;
            case "&":
               return param1.value & param3.value;
            case ">>":
               return param1.value >> param3.value;
            case ">>>":
               return param1.value >>> param3.value;
            case "<<":
               return param1.value << param3.value;
            case "~":
               return ~param3.value;
            case "|":
               return param1.value | param3.value;
            case "!":
               return !param3.value;
            case ">":
               return param1.value > param3.value;
            case ">=":
               return param1.value >= param3.value;
            case "<":
               return param1.value < param3.value;
            case "<=":
               return param1.value <= param3.value;
            case "||":
               return param1.value || param3.value;
            case "&&":
               return param1.value && param3.value;
            case "is":
               return param1.value is param3.value;
            case "typeof":
               return typeof param3.value;
            case "delete":
               return delete param3.obj[param3.prop];
            case "==":
               return param1.value == param3.value;
            case "===":
               return param1.value === param3.value;
            case "!=":
               return param1.value != param3.value;
            case "!==":
               return param1.value !== param3.value;
            default:
               return;
         }
      }
      
      private function makeNew(param1:String) : *
      {
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:int = 0;
         var _loc2_:int = int(param1.indexOf("("));
         var _loc3_:String = _loc2_ > 0 ? param1.substring(0,_loc2_) : param1;
         _loc3_ = this.ignoreWhite(_loc3_);
         var _loc4_:* = this.execValue(_loc3_).value;
         if(_loc2_ > 0)
         {
            _loc5_ = int(param1.indexOf(")",_loc2_));
            _loc6_ = param1.substring(_loc2_ + 1,_loc5_);
            _loc6_ = this.ignoreWhite(_loc6_);
            _loc7_ = [];
            if(_loc6_)
            {
               _loc7_ = this.execValue(_loc6_).value;
            }
            _loc8_ = int(_loc7_.length);
            if(_loc8_ == 0)
            {
               return new _loc4_();
            }
            if(_loc8_ == 1)
            {
               return new _loc4_(_loc7_[0]);
            }
            if(_loc8_ == 2)
            {
               return new _loc4_(_loc7_[0],_loc7_[1]);
            }
            if(_loc8_ == 3)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2]);
            }
            if(_loc8_ == 4)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3]);
            }
            if(_loc8_ == 5)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4]);
            }
            if(_loc8_ == 6)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5]);
            }
            if(_loc8_ == 7)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6]);
            }
            if(_loc8_ == 8)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7]);
            }
            if(_loc8_ == 9)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8]);
            }
            if(_loc8_ == 10)
            {
               return new _loc4_(_loc7_[0],_loc7_[1],_loc7_[2],_loc7_[3],_loc7_[4],_loc7_[5],_loc7_[6],_loc7_[7],_loc7_[8],_loc7_[9]);
            }
            throw new Error("CommandLine can\'t create new class instances with more than 10 arguments.");
         }
         return null;
      }
      
      private function ignoreWhite(param1:String) : String
      {
         param1 = param1.replace(/\s*(.*)/,"$1");
         var _loc2_:int = param1.length - 1;
         while(_loc2_ > 0)
         {
            if(!param1.charAt(_loc2_).match(/\s/))
            {
               break;
            }
            param1 = param1.substring(0,_loc2_);
            _loc2_--;
         }
         return param1;
      }
   }
}

class ExeValue
{
   
   public var obj:*;
   
   public var prop:String;
   
   public function ExeValue(param1:Object = null, param2:String = null)
   {
      super();
      this.obj = param1;
      this.prop = param2;
   }
   
   public function get value() : *
   {
      return this.prop ? this.obj[this.prop] : this.obj;
   }
   
   public function setValue(param1:*) : void
   {
      if(this.prop)
      {
         this.obj[this.prop] = param1;
      }
      else
      {
         this.obj = param1;
      }
   }
}
