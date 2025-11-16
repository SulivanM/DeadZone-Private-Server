package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.KeyBind;
   import com.junkbyte.console.core.LogReferences;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.TextEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Dictionary;
   
   public class RollerPanel extends ConsolePanel
   {
      
      public static const NAME:String = "rollerPanel";
      
      private var _settingKey:Boolean;
      
      public function RollerPanel(param1:Console)
      {
         super(param1);
         name = NAME;
         init(60,100,false);
         txtField = makeTF("rollerPrints");
         txtField.multiline = true;
         txtField.autoSize = TextFieldAutoSize.LEFT;
         registerTFRoller(txtField,this.onMenuRollOver,this.linkHandler);
         registerDragger(txtField);
         addChild(txtField);
         addEventListener(Event.ENTER_FRAME,this._onFrame);
         addEventListener(Event.REMOVED_FROM_STAGE,this.removeListeners);
      }
      
      private function removeListeners(param1:Event = null) : void
      {
         removeEventListener(Event.ENTER_FRAME,this._onFrame);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.removeListeners);
         if(stage)
         {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
         }
      }
      
      private function _onFrame(param1:Event) : void
      {
         if(!console.stage)
         {
            this.close();
            return;
         }
         if(this._settingKey)
         {
            txtField.htmlText = "<high><menu>Press a key to set [ <a href=\"event:cancel\"><b>cancel</b></a> ]</menu></high>";
         }
         else
         {
            txtField.htmlText = "<low>" + this.getMapString(false) + "</low>";
            txtField.autoSize = TextFieldAutoSize.LEFT;
            txtField.setSelection(0,0);
         }
         width = txtField.width + 4;
         height = txtField.height;
      }
      
      public function getMapString(param1:Boolean) : String
      {
         var _loc7_:DisplayObject = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc10_:DisplayObjectContainer = null;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:DisplayObject = null;
         var _loc14_:uint = 0;
         var _loc15_:* = null;
         var _loc16_:uint = 0;
         var _loc2_:Stage = console.stage;
         var _loc3_:* = "";
         if(!param1)
         {
            _loc8_ = console.rollerCaptureKey ? console.rollerCaptureKey.key : "unassigned";
            _loc3_ = "<menu> <a href=\"event:close\"><b>X</b></a></menu> Capture key: <menu><a href=\"event:capture\">" + _loc8_ + "</a></menu><br/>";
         }
         var _loc4_:Point = new Point(_loc2_.mouseX,_loc2_.mouseY);
         if(_loc2_.areInaccessibleObjectsUnderPoint(_loc4_))
         {
            _loc3_ += "<p9>Inaccessible objects detected</p9><br/>";
         }
         var _loc5_:Array = _loc2_.getObjectsUnderPoint(_loc4_);
         var _loc6_:Dictionary = new Dictionary(true);
         if(_loc5_.length == 0)
         {
            _loc5_.push(_loc2_);
         }
         for each(_loc7_ in _loc5_)
         {
            _loc9_ = new Array(_loc7_);
            _loc10_ = _loc7_.parent;
            while(_loc10_)
            {
               _loc9_.unshift(_loc10_);
               _loc10_ = _loc10_.parent;
            }
            _loc11_ = _loc9_.length;
            _loc12_ = 0;
            while(_loc12_ < _loc11_)
            {
               _loc13_ = _loc9_[_loc12_];
               if(_loc6_[_loc13_] == undefined)
               {
                  _loc6_[_loc13_] = _loc12_;
                  _loc14_ = _loc12_;
                  while(_loc14_ > 0)
                  {
                     _loc3_ += _loc14_ == 1 ? " ∟" : " -";
                     _loc14_--;
                  }
                  _loc15_ = _loc13_.name;
                  if(param1 && console.config.useObjectLinking)
                  {
                     _loc16_ = console.refs.setLogRef(_loc13_);
                     _loc15_ = "<a href=\'event:cl_" + _loc16_ + "\'>" + _loc15_ + "</a> " + console.refs.makeRefTyped(_loc13_);
                  }
                  else
                  {
                     _loc15_ = _loc15_ + " (" + LogReferences.ShortClassName(_loc13_) + ")";
                  }
                  if(_loc13_ == _loc2_)
                  {
                     _loc16_ = console.refs.setLogRef(_loc2_);
                     if(_loc16_)
                     {
                        _loc3_ += "<p3><a href=\'event:cl_" + _loc16_ + "\'><i>Stage</i></a> ";
                     }
                     else
                     {
                        _loc3_ += "<p3><i>Stage</i> ";
                     }
                     _loc3_ += "[" + _loc2_.mouseX + "," + _loc2_.mouseY + "]</p3><br/>";
                  }
                  else if(_loc12_ == _loc11_ - 1)
                  {
                     _loc3_ += "<p5>" + _loc15_ + "</p5><br/>";
                  }
                  else
                  {
                     _loc3_ += "<p2><i>" + _loc15_ + "</i></p2><br/>";
                  }
               }
               _loc12_++;
            }
         }
         return _loc3_;
      }
      
      override public function close() : void
      {
         this.cancelCaptureKeySet();
         this.removeListeners();
         super.close();
         console.panels.updateMenu();
      }
      
      private function onMenuRollOver(param1:TextEvent) : void
      {
         var _loc3_:KeyBind = null;
         var _loc2_:String = param1.text ? param1.text.replace("event:","") : "";
         if(_loc2_ == "close")
         {
            _loc2_ = "Close";
         }
         else if(_loc2_ == "capture")
         {
            _loc3_ = console.rollerCaptureKey;
            if(_loc3_)
            {
               _loc2_ = "Unassign key ::" + _loc3_.key;
            }
            else
            {
               _loc2_ = "Assign key";
            }
         }
         else if(_loc2_ == "cancel")
         {
            _loc2_ = "Cancel assign key";
         }
         else
         {
            _loc2_ = null;
         }
         console.panels.tooltip(_loc2_,this);
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         TextField(param1.currentTarget).setSelection(0,0);
         if(param1.text == "close")
         {
            this.close();
         }
         else if(param1.text == "capture")
         {
            if(console.rollerCaptureKey)
            {
               console.setRollerCaptureKey(null);
            }
            else
            {
               this._settingKey = true;
               stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
            }
            console.panels.tooltip(null);
         }
         else if(param1.text == "cancel")
         {
            this.cancelCaptureKeySet();
            console.panels.tooltip(null);
         }
         param1.stopPropagation();
      }
      
      private function cancelCaptureKeySet() : void
      {
         this._settingKey = false;
         if(stage)
         {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
         }
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(!param1.charCode)
         {
            return;
         }
         var _loc2_:String = String.fromCharCode(param1.charCode);
         this.cancelCaptureKeySet();
         console.setRollerCaptureKey(_loc2_,param1.shiftKey,param1.ctrlKey,param1.altKey);
         console.panels.tooltip(null);
      }
   }
}

