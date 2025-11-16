package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import flash.events.TextEvent;
   import flash.text.TextFieldAutoSize;
   
   public class ChannelsPanel extends ConsolePanel
   {
      
      public static const NAME:String = "channelsPanel";
      
      public function ChannelsPanel(param1:Console)
      {
         super(param1);
         name = NAME;
         init(10,10,false);
         txtField = makeTF("channelsField");
         txtField.wordWrap = true;
         txtField.width = 160;
         txtField.multiline = true;
         txtField.autoSize = TextFieldAutoSize.LEFT;
         registerTFRoller(txtField,this.onMenuRollOver,this.linkHandler);
         registerDragger(txtField);
         addChild(txtField);
      }
      
      public function update() : void
      {
         txtField.wordWrap = false;
         txtField.width = 80;
         var _loc1_:String = "<high><menu> <b><a href=\"event:close\">X</a></b></menu> " + console.panels.mainPanel.getChannelsLink();
         txtField.htmlText = _loc1_ + "</high>";
         if(txtField.width > 160)
         {
            txtField.wordWrap = true;
            txtField.width = 160;
         }
         width = txtField.width + 4;
         height = txtField.height;
      }
      
      private function onMenuRollOver(param1:TextEvent) : void
      {
         console.panels.mainPanel.onMenuRollOver(param1,this);
      }
      
      protected function linkHandler(param1:TextEvent) : void
      {
         txtField.setSelection(0,0);
         if(param1.text == "close")
         {
            console.panels.channelsPanel = false;
         }
         else if(param1.text.substring(0,8) == "channel_")
         {
            console.panels.mainPanel.onChannelPressed(param1.text.substring(8));
         }
         txtField.setSelection(0,0);
         param1.stopPropagation();
      }
   }
}

