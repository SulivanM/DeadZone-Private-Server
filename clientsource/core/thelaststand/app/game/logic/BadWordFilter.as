package thelaststand.app.game.logic
{
   import flash.utils.Dictionary;
   
   public class BadWordFilter
   {
      
      private var lettersNumbers:RegExp = /(\d|\w)/ig;
      
      private var linkTag:RegExp = /<\/a>/ig;
      
      private var linkReplacementTag:RegExp = /<\/templink>/ig;
      
      private var expressions:Vector.<RegExp> = new Vector.<RegExp>();
      
      private var FUConRegExp:RegExp = /[fƒ]+(([uv]+[ck]*)|([ck]+))\s+[you]*\s*c+[o0]+n+/ig;
      
      private var FUResponses:Array = ["I\'m a huge fan of my little pony. I even dress up on weekends","I love con and his team, especially sev","Can one of you devs please delete my account? I don\'t want to play anymore","Free weapons to the first 50 blind trade requests - Go!"];
      
      public function BadWordFilter()
      {
         super();
         this.GenerateRegularExpressions(true,["fuck","cunt","niger","nigger","fagot","faggot","niggr","assrape"]);
         this.GenerateRegularExpressions(false,["raped","raping","niga","fck","fcking","fckhead","fark","farking","farkhead","fuk","fuking","fukhead","pussy","rape","rapist","slut","chink","homo","fag","fags","asshole","arsehole","cock","niggs"]);
      }
      
      public function cleanString(param1:String) : String
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc5_:RegExp = null;
         if(param1.search(this.FUConRegExp) > -1 && Math.random() < 0.1)
         {
            return this.FUResponses[Math.floor(Math.random() * this.FUResponses.length)];
         }
         param1 = param1.replace(this.linkTag,"</templink>");
         var _loc4_:int = 0;
         while(_loc4_ < this.expressions.length)
         {
            _loc5_ = this.expressions[_loc4_];
            _loc5_.lastIndex = 0;
            while(true)
            {
               _loc2_ = _loc5_.exec(param1);
               if(_loc2_ == null)
               {
                  break;
               }
               --_loc5_.lastIndex;
               _loc3_ = String(_loc2_[0]).replace(this.lettersNumbers,"♥");
               param1 = param1.replace(_loc2_[0],_loc3_);
            }
            _loc4_++;
         }
         return param1.replace(this.linkReplacementTag,"</a>");
      }
      
      private function GenerateRegularExpressions(param1:Boolean, param2:Array) : void
      {
         var _loc5_:String = null;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc3_:Dictionary = new Dictionary();
         _loc3_["i"] = "i1l!\\|\\\\";
         _loc3_["a"] = "a@4";
         _loc3_["e"] = "e3";
         _loc3_["o"] = "o0";
         _loc3_["g"] = "g6";
         _loc3_["u"] = "uv";
         _loc3_["f"] = "fƒ";
         _loc3_["s"] = "s5\\$";
         param2 = param2.sort(this.byLength);
         var _loc4_:int = 0;
         while(_loc4_ < param2.length)
         {
            _loc5_ = param2[_loc4_];
            _loc6_ = "";
            if(!param1)
            {
               _loc6_ += "(^|\\s+)\\W*";
            }
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               if(_loc7_ > 0)
               {
                  _loc6_ += "(\\W|_)*";
               }
               _loc6_ += _loc5_.charAt(_loc7_) + "+";
               _loc7_++;
            }
            if(!param1)
            {
               _loc6_ += "(\\W|_)*s*\\W*($|\\s+)";
            }
            _loc6_ = _loc6_.replace(/\\s/ig,"\\__");
            for(_loc8_ in _loc3_)
            {
               _loc6_ = _loc6_.replace(new RegExp(_loc8_,"ig"),"[" + _loc3_[_loc8_] + "]");
            }
            _loc6_ = _loc6_.replace(/\\__/ig,"\\s");
            this.expressions.push(new RegExp(_loc6_,"ig"));
            _loc4_++;
         }
      }
      
      private function byLength(param1:String, param2:String) : int
      {
         if(param1.length > param2.length)
         {
            return -1;
         }
         if(param1.length < param2.length)
         {
            return 1;
         }
         return 0;
      }
   }
}

