package thelaststand.preloader.display
{
   import flash.filters.DropShadowFilter;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class StatusText extends TextField
   {
      
      public static const FontTitle:Class = StatusText_FontTitle;
      
      public function StatusText()
      {
         super();
         defaultTextFormat = new TextFormat("AlternateGothic",22,16777215);
         embedFonts = true;
         autoSize = TextFieldAutoSize.LEFT;
         height = defaultTextFormat.size + 4;
         multiline = wordWrap = selectable = false;
         antiAliasType = AntiAliasType.ADVANCED;
         filters = [new DropShadowFilter(0,0,0,1,6,6,1,1)];
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
   }
}

