package com.junkbyte.console
{
   import flash.text.StyleSheet;
   
   public class ConsoleStyle
   {
      
      public var menuFont:String = "Arial";
      
      public var menuFontSize:int = 12;
      
      public var traceFont:String = "Verdana";
      
      public var traceFontSize:int = 11;
      
      public var backgroundColor:uint;
      
      public var backgroundAlpha:Number = 0.9;
      
      public var controlColor:uint = 10027008;
      
      public var controlSize:uint = 5;
      
      public var commandLineColor:uint = 1092096;
      
      public var highColor:uint = 16777215;
      
      public var lowColor:uint = 12632256;
      
      public var logHeaderColor:uint = 12632256;
      
      public var menuColor:uint = 16746496;
      
      public var menuHighlightColor:uint = 14505216;
      
      public var channelsColor:uint = 16777215;
      
      public var channelColor:uint = 39372;
      
      public var priority0:uint = 3831610;
      
      public var priority1:uint = 4495684;
      
      public var priority2:uint = 7846775;
      
      public var priority3:uint = 10539168;
      
      public var priority4:uint = 14085846;
      
      public var priority5:uint = 15329769;
      
      public var priority6:uint = 16768477;
      
      public var priority7:uint = 16755370;
      
      public var priority8:uint = 16742263;
      
      public var priority9:uint = 16720418;
      
      public var priority10:uint = 16720418;
      
      public var priorityC1:uint = 39372;
      
      public var priorityC2:uint = 16746496;
      
      public var topMenu:Boolean = true;
      
      public var showCommandLineScope:Boolean = true;
      
      public var maxChannelsInMenu:int = 7;
      
      public var panelSnapping:int = 3;
      
      public var roundBorder:int = 10;
      
      private var _css:StyleSheet;
      
      public function ConsoleStyle()
      {
         super();
         this._css = new StyleSheet();
      }
      
      public function whiteBase() : void
      {
         this.backgroundColor = 16777215;
         this.controlColor = 16724787;
         this.commandLineColor = 6736896;
         this.highColor = 0;
         this.lowColor = 3355443;
         this.logHeaderColor = 4473924;
         this.menuColor = 13373696;
         this.menuHighlightColor = 8917248;
         this.channelsColor = 0;
         this.channelColor = 26282;
         this.priority0 = 4497476;
         this.priority1 = 3379251;
         this.priority2 = 2258722;
         this.priority3 = 1135889;
         this.priority4 = 13056;
         this.priority5 = 0;
         this.priority6 = 6684672;
         this.priority7 = 10027008;
         this.priority8 = 12255232;
         this.priority9 = 14483456;
         this.priority10 = 14483456;
         this.priorityC1 = 39372;
         this.priorityC2 = 16737792;
      }
      
      public function big() : void
      {
         this.traceFontSize = 13;
         this.menuFontSize = 14;
      }
      
      public function updateStyleSheet() : void
      {
         this._css.setStyle("high",{
            "color":this.hesh(this.highColor),
            "fontFamily":this.menuFont,
            "fontSize":this.menuFontSize,
            "display":"inline"
         });
         this._css.setStyle("low",{
            "color":this.hesh(this.lowColor),
            "fontFamily":this.menuFont,
            "fontSize":this.menuFontSize - 2,
            "display":"inline"
         });
         this._css.setStyle("menu",{
            "color":this.hesh(this.menuColor),
            "display":"inline"
         });
         this._css.setStyle("menuHi",{
            "color":this.hesh(this.menuHighlightColor),
            "display":"inline"
         });
         this._css.setStyle("chs",{
            "color":this.hesh(this.channelsColor),
            "fontSize":this.menuFontSize,
            "leading":"2",
            "display":"inline"
         });
         this._css.setStyle("ch",{
            "color":this.hesh(this.channelColor),
            "display":"inline"
         });
         this._css.setStyle("tt",{
            "color":this.hesh(this.menuColor),
            "fontFamily":this.menuFont,
            "fontSize":this.menuFontSize,
            "textAlign":"center"
         });
         this._css.setStyle("r",{
            "textAlign":"right",
            "display":"inline"
         });
         this._css.setStyle("p",{
            "fontFamily":this.traceFont,
            "fontSize":this.traceFontSize
         });
         this._css.setStyle("p0",{
            "color":this.hesh(this.priority0),
            "display":"inline"
         });
         this._css.setStyle("p1",{
            "color":this.hesh(this.priority1),
            "display":"inline"
         });
         this._css.setStyle("p2",{
            "color":this.hesh(this.priority2),
            "display":"inline"
         });
         this._css.setStyle("p3",{
            "color":this.hesh(this.priority3),
            "display":"inline"
         });
         this._css.setStyle("p4",{
            "color":this.hesh(this.priority4),
            "display":"inline"
         });
         this._css.setStyle("p5",{
            "color":this.hesh(this.priority5),
            "display":"inline"
         });
         this._css.setStyle("p6",{
            "color":this.hesh(this.priority6),
            "display":"inline"
         });
         this._css.setStyle("p7",{
            "color":this.hesh(this.priority7),
            "display":"inline"
         });
         this._css.setStyle("p8",{
            "color":this.hesh(this.priority8),
            "display":"inline"
         });
         this._css.setStyle("p9",{
            "color":this.hesh(this.priority9),
            "display":"inline"
         });
         this._css.setStyle("p10",{
            "color":this.hesh(this.priority10),
            "fontWeight":"bold",
            "display":"inline"
         });
         this._css.setStyle("p-1",{
            "color":this.hesh(this.priorityC1),
            "display":"inline"
         });
         this._css.setStyle("p-2",{
            "color":this.hesh(this.priorityC2),
            "display":"inline"
         });
         this._css.setStyle("logs",{
            "color":this.hesh(this.logHeaderColor),
            "display":"inline"
         });
      }
      
      public function get styleSheet() : StyleSheet
      {
         return this._css;
      }
      
      private function hesh(param1:Number) : String
      {
         return "#" + param1.toString(16);
      }
   }
}

