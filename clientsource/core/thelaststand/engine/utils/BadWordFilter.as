package thelaststand.engine.utils
{
   public class BadWordFilter
   {
      
      public static var defaultPatterns:Vector.<BadWordPattern>;
      
      public static const FILTER_TEST:uint = 0;
      
      public static const FILTER_REPLACE:uint = 1;
      
      public static const FILTER_REMOVE:uint = 2;
      
      public var patterns:Vector.<BadWordPattern>;
      
      public var replaceChars:Array = ["*"];
      
      public var replaceUseLength:Boolean = true;
      
      public function BadWordFilter(param1:* = null)
      {
         super();
         if(param1 is XML)
         {
            this.patterns = createPatternList(param1);
         }
         else if(param1 is Vector.<BadWordPattern>)
         {
            this.patterns = param1;
         }
         else
         {
            this.patterns = defaultPatterns;
         }
      }
      
      public static function createPatternList(param1:XML) : Vector.<BadWordPattern>
      {
         var numWords:int;
         var variationList:XMLList;
         var patterns:Vector.<BadWordPattern>;
         var i:int;
         var node:XML = null;
         var word:String = null;
         var numChars:int = 0;
         var important:Boolean = false;
         var pattern:String = null;
         var j:int = 0;
         var p:BadWordPattern = null;
         var char:String = null;
         var variationNode:XML = null;
         var wordList:XML = param1;
         if(!wordList)
         {
            return null;
         }
         numWords = int(wordList.words.word.length());
         variationList = wordList.variations.item;
         patterns = new Vector.<BadWordPattern>(numWords,true);
         i = 0;
         while(i < numWords)
         {
            node = wordList.words.word[i];
            word = node.toString();
            numChars = word.length;
            important = node.@i.toString() == "1";
            pattern = !important ? "([^a-z]|^)(" : "(";
            j = 0;
            while(j < numChars)
            {
               char = word.substr(j,1).toLowerCase();
               variationNode = variationList.(@t.toLowerCase() == char)[0];
               if(char == " ")
               {
                  char = "\\s*";
               }
               if(variationNode)
               {
                  pattern += "(?:" + char + "|" + variationNode.toString() + ")";
               }
               else
               {
                  pattern += char;
               }
               pattern += "+[\\" + (j == numChars - 1 ? "$" : "W") + "]*";
               j++;
            }
            pattern += !important ? ")([^a-z]|$)" : ")";
            p = new BadWordPattern();
            p.regExp = new RegExp(pattern,"ig");
            p.important = important;
            p.length = numChars;
            patterns[i] = p;
            i++;
         }
         return patterns;
      }
      
      public function destroy() : void
      {
         this.patterns = null;
         this.replaceChars = null;
         this.replaceUseLength = false;
      }
      
      public function filter(param1:String, param2:uint = 1) : *
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc9_:BadWordPattern = null;
         if(!this.patterns)
         {
            throw new Error("BadWordFilter: No pattern Vector specified.");
         }
         var _loc3_:String = param1;
         var _loc4_:int = 0;
         var _loc7_:Array = [""];
         var _loc8_:int = int(this.patterns.length);
         while(_loc4_ < _loc8_)
         {
            _loc9_ = this.patterns[_loc4_];
            _loc9_.regExp.lastIndex = 0;
            switch(param2)
            {
               case FILTER_REPLACE:
               case FILTER_REMOVE:
                  _loc6_ = this.stringRepeat(FILTER_REPLACE ? this.replaceChars : _loc7_,this.replaceUseLength ? _loc9_.length : 1);
                  if(!_loc9_.important)
                  {
                     _loc3_ = _loc3_.replace(_loc9_.regExp,"$1" + _loc6_ + "$3");
                  }
                  else
                  {
                     _loc3_ = _loc3_.replace(_loc9_.regExp,_loc6_);
                  }
                  break;
               case FILTER_TEST:
                  if(_loc9_.regExp.test(_loc3_))
                  {
                     return true;
                  }
            }
            _loc4_++;
         }
         return param2 == FILTER_TEST ? false : _loc3_;
      }
      
      private function stringRepeat(param1:Array, param2:int) : String
      {
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc3_ += param1[Math.floor(Math.random() * param1.length)];
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

