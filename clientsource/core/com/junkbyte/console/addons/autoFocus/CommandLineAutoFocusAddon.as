package com.junkbyte.console.addons.autoFocus
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.view.ConsolePanel;
   import com.junkbyte.console.view.MainPanel;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class CommandLineAutoFocusAddon
   {
      
      public function CommandLineAutoFocusAddon()
      {
         super();
      }
      
      public static function registerToConsole(param1:Console = null) : void
      {
         if(param1 == null)
         {
            param1 = Cc.instance;
         }
         if(param1 == null)
         {
            return;
         }
         param1.panels.mainPanel.addEventListener(ConsolePanel.VISIBLITY_CHANGED,onPanelVisibilityChanged);
      }
      
      private static function onPanelVisibilityChanged(param1:Event) : void
      {
         var _loc4_:uint = 0;
         var _loc2_:MainPanel = param1.currentTarget as MainPanel;
         if(_loc2_.visible == false)
         {
            return;
         }
         var _loc3_:TextField = _loc2_.getChildByName("commandField") as TextField;
         if(Boolean(_loc3_) && Boolean(_loc3_.stage))
         {
            _loc3_.stage.focus = _loc3_;
            _loc4_ = uint(_loc3_.text.length);
            _loc3_.setSelection(_loc4_,_loc4_);
         }
      }
   }
}

