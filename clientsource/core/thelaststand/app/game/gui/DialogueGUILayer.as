package thelaststand.app.game.gui
{
   import flash.display.Sprite;
   import org.osflash.signals.Signal;
   import thelaststand.common.gui.ModalOverlay;
   import thelaststand.common.gui.dialogues.Dialogue;
   
   public class DialogueGUILayer extends Sprite implements IGUILayer
   {
      
      private var _gui:GameGUI;
      
      private var _dialogues:Vector.<Dialogue>;
      
      private var _width:int;
      
      private var _height:int;
      
      private var mc_modal:ModalOverlay;
      
      public function DialogueGUILayer()
      {
         super();
         mouseEnabled = false;
         mouseChildren = true;
         tabEnabled = false;
         this.mc_modal = new ModalOverlay();
         this._dialogues = new Vector.<Dialogue>();
      }
      
      public function addDialogue(param1:Dialogue) : void
      {
         if(this._dialogues.indexOf(param1) > -1)
         {
            return;
         }
         this._dialogues.push(param1);
         addChild(param1.sprite);
         this.alignDialogue(param1);
         if(param1.modal)
         {
            addChild(this.mc_modal);
            this.updateZIndicies();
         }
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._dialogues = null;
         this._gui = null;
         this.mc_modal.dispose();
         this.mc_modal = null;
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         var _loc3_:Dialogue = null;
         this._width = param1;
         this._height = param2;
         this.mc_modal.y = -this.y;
         for each(_loc3_ in this._dialogues)
         {
            this.alignDialogue(_loc3_);
         }
      }
      
      public function removeDialogue(param1:Dialogue) : void
      {
         if(param1.sprite.parent == this)
         {
            removeChild(param1.sprite);
         }
         var _loc2_:int = int(this._dialogues.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._dialogues.splice(_loc2_,1);
         }
         var _loc3_:int = 0;
         for each(param1 in this._dialogues)
         {
            if(param1.modal)
            {
               _loc3_++;
            }
         }
         if(_loc3_ == 0)
         {
            if(this.mc_modal.parent != null)
            {
               this.mc_modal.parent.removeChild(this.mc_modal);
            }
            return;
         }
         this.updateZIndicies();
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
      }
      
      public function get transitionedOut() : Signal
      {
         return null;
      }
      
      private function alignDialogue(param1:Dialogue) : void
      {
         switch(param1.align)
         {
            case Dialogue.ALIGN_TOP_RIGHT:
               param1.sprite.x = int(this._width - param1.width - 10 + param1.offset.x);
               param1.sprite.y = int(10 + param1.offset.y);
               break;
            case Dialogue.ALIGN_CENTER:
            default:
               param1.sprite.x = int((this._width - param1.width) * 0.5) + int(param1.offset.x);
               param1.sprite.y = int((this._height - param1.height) * 0.5) + int(param1.offset.y);
         }
      }
      
      private function updateZIndicies() : void
      {
         var _loc4_:Dialogue = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._dialogues.length)
         {
            _loc4_ = this._dialogues[_loc3_];
            if(_loc4_.sprite.parent == this)
            {
               if(_loc4_.modal)
               {
                  _loc2_++;
               }
               setChildIndex(_loc4_.sprite,_loc1_++);
            }
            _loc3_++;
         }
         if(this.mc_modal.parent == this)
         {
            setChildIndex(this.mc_modal,Math.max(0,_loc2_ - 1));
         }
      }
      
      public function get numDialogues() : int
      {
         return this._dialogues.length;
      }
      
      public function get useFullWindow() : Boolean
      {
         return false;
      }
      
      public function get gui() : GameGUI
      {
         return this._gui;
      }
      
      public function set gui(param1:GameGUI) : void
      {
         this._gui = param1;
      }
   }
}

