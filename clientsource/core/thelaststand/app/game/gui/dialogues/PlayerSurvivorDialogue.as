package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.game.data.AttributeClass;
   import thelaststand.app.game.gui.survivor.UIPlayerSkillsTable;
   import thelaststand.app.game.gui.survivor.UISurvivorDetails;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class PlayerSurvivorDialogue extends BaseDialogue
   {
      
      private var _attributes:Dictionary;
      
      private var _lang:Language;
      
      private var _playerData:PlayerData;
      
      private var mc_container:Sprite;
      
      private var mc_attributes:UIPlayerSkillsTable;
      
      private var ui_survivor:UISurvivorDetails;
      
      public function PlayerSurvivorDialogue(param1:Boolean = true)
      {
         var _loc2_:String = null;
         this.mc_container = new Sprite();
         super("player-survivor-dialgoue",this.mc_container);
         _autoSize = false;
         _width = 298;
         _height = 484;
         _buttonSpacing = 10;
         this._lang = Language.getInstance();
         this._playerData = Network.getInstance().playerData;
         this._attributes = new Dictionary(true);
         for each(_loc2_ in AttributeClass.getAttributeClasses())
         {
            this._attributes[_loc2_] = 0;
         }
         this.ui_survivor = new UISurvivorDetails();
         this.ui_survivor.showEditName = false;
         this.ui_survivor.loadoutEnabled = param1;
         this.mc_container.addChild(this.ui_survivor);
         addButton(Language.getInstance().getString("survivor_edit_cancel"),true,{"width":126});
         addButton(Language.getInstance().getString("survivor_edit_save"),false,{
            "width":126,
            "icon":new Bitmap(new BmpIconButtonArrow()),
            "iconBackgroundColor":3183890
         }).clicked.add(this.onSaveClicked);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.mc_container.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.mc_container.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this._lang = null;
         this._playerData = null;
         this.mc_attributes.attributeModified.remove(this.onAttributeModified);
         this.ui_survivor.dispose();
      }
      
      override public function close() : void
      {
         this._playerData.getPlayerSurvivor().setActiveLoadout(null);
         super.close();
      }
      
      private function update() : void
      {
         var _loc1_:uint = this._playerData.levelPoints > 0 ? UISurvivorDetails.MODE_LEVEL : UISurvivorDetails.MODE_VIEW;
         this.ui_survivor.setSurvivor(this._playerData.getPlayerSurvivor(),_loc1_,false);
         this.ui_survivor.levelPoints = this._playerData.levelPoints;
         if(this.mc_attributes != null)
         {
            this.mc_attributes.attributeModified.remove(this.onAttributeModified);
         }
         this.mc_attributes = this.ui_survivor.getPlayerAttributeTable();
         this.mc_attributes.attributeModified.add(this.onAttributeModified);
         this.mc_attributes.points = this._playerData.levelPoints;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._playerData.levelUpPointsChanged.add(this.onLevelUpPointsChanged);
         this.update();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._playerData.levelUpPointsChanged.remove(this.onLevelUpPointsChanged);
      }
      
      private function onLevelUpPointsChanged() : void
      {
         this.update();
      }
      
      private function onAttributeModified(param1:String) : void
      {
         this.ui_survivor.levelPoints = this.mc_attributes.points;
      }
      
      private function onSaveClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var attributes:Object = this.mc_attributes.getModifiedAttriutes();
         this._playerData.saveCustomization(null,attributes,function(param1:Boolean):void
         {
            if(param1)
            {
               if(_playerData.levelPoints <= 0)
               {
                  close();
               }
            }
         });
      }
   }
}

