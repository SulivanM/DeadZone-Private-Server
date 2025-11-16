package thelaststand.app.game.data
{
   public class AttireOverlay
   {
      
      public var type:String;
      
      public var texture:String;
      
      public function AttireOverlay(param1:String, param2:String)
      {
         super();
         this.type = param1;
         this.texture = param2;
      }
      
      public function clone() : AttireOverlay
      {
         return new AttireOverlay(this.type,this.texture);
      }
   }
}

