package thelaststand.app.game.gui.arena
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class ArenaLaunchDialogue extends BaseDialogue
   {
      
      private var _arenaName:String;
      
      private var mc_container:Sprite;
      
      private var mc_level:Sprite;
      
      private var txt_desc:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var bmp_levelOK:Bitmap;
      
      private var bmp_background:Bitmap;
      
      private var bmp_tape_tl:Bitmap;
      
      private var bmp_tape_tr:Bitmap;
      
      private var bmp_tape_bl:Bitmap;
      
      private var bmp_tape_br:Bitmap;
      
      private var ui_image:UIImage;
      
      public function ArenaLaunchDialogue(param1:String)
      {
         var bgPadding:int;
         var xml:XML;
         var btnLaunch:PushButton = null;
         var levelMin:int = 0;
         var levelMax:int = 0;
         var playerLevel:int = 0;
         var inLevelRange:Boolean = false;
         var tapeOffset:int = 0;
         var name:String = param1;
         this.mc_container = new Sprite();
         super("arena-launch",this.mc_container,true);
         this._arenaName = name;
         _autoSize = false;
         addTitle(Language.getInstance().getString("arena." + this._arenaName + ".launch_title"),BaseDialogue.TITLE_COLOR_GREY,-1,new BmpBountySkull());
         btnLaunch = PushButton(addButton(Language.getInstance().getString("arena." + this._arenaName + ".launch_btn"),true,{"width":180}));
         btnLaunch.clicked.addOnce(this.onClickLaunch);
         bgPadding = 13;
         this.ui_image = new UIImage(385,205);
         this.ui_image.x = bgPadding;
         this.ui_image.y = bgPadding - 4;
         this.ui_image.uri = "images/arenas/" + this._arenaName + "_launch.jpg";
         this.mc_container.addChild(this.ui_image);
         this.bmp_background = new Bitmap(new BmpRaidMissionBg());
         this.bmp_background.scale9Grid = new Rectangle(14,14,this.bmp_background.width - 28,this.bmp_background.height - 28);
         this.bmp_background.width = int(this.ui_image.width + bgPadding * 2);
         this.bmp_background.height = int(this.ui_image.height + bgPadding * 2 - 8);
         this.mc_container.addChildAt(this.bmp_background,0);
         this.txt_desc = new BodyTextField({
            "color":15527148,
            "size":14,
            "multiline":true
         });
         this.txt_desc.htmlText = Language.getInstance().getString("arena." + this._arenaName + ".launch_desc");
         this.txt_desc.width = int(this.ui_image.width - 8);
         this.txt_desc.x = int(this.ui_image.x + 4);
         this.txt_desc.y = int(this.ui_image.y + this.ui_image.height + 26);
         this.mc_container.addChild(this.txt_desc);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this.bmp_background.width - 12,this.txt_desc.height + 12,this.bmp_background.x + 6,this.txt_desc.y - 6);
         _width = int(this.ui_image.width + _padding * 2 + bgPadding * 2);
         _height = int(this.txt_desc.y + this.txt_desc.height + 12 + _padding * 2 + 40);
         xml = ResourceManager.getInstance().getResource("xml/arenas.xml").content.arena.(@id == _arenaName)[0];
         levelMin = int(xml.level_min);
         levelMax = int(int(xml.level_max) || int(Config.constant.MAX_SURVIVOR_LEVEL));
         playerLevel = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         inLevelRange = playerLevel >= levelMin;
         btnLaunch.enabled = inLevelRange;
         this.mc_level = new Sprite();
         this.mc_level.graphics.beginFill(inLevelRange ? 3358494 : 3672843);
         this.mc_level.graphics.drawRect(0,0,28,28);
         this.mc_level.graphics.endFill();
         this.mc_level.x = 0;
         this.mc_level.y = int(_height - _padding * 2 - this.mc_level.height - 4);
         this.mc_container.addChild(this.mc_level);
         this.bmp_levelOK = new Bitmap(inLevelRange ? new BmpIconTradeTickGreen() : new BmpIconTradeCrossRed());
         this.bmp_levelOK.x = int((28 - this.bmp_levelOK.width) * 0.5);
         this.bmp_levelOK.y = int((28 - this.bmp_levelOK.height) * 0.5);
         this.mc_level.addChild(this.bmp_levelOK);
         this.txt_level = new BodyTextField({
            "color":(inLevelRange ? 9623879 : 15088186),
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_level.text = Language.getInstance().getString("level",levelMin + 1 + "-" + (levelMax + 1));
         this.txt_level.x = 32;
         this.txt_level.y = int((28 - this.txt_level.height) * 0.5);
         this.mc_level.addChild(this.txt_level);
         tapeOffset = -1;
         this.bmp_tape_tl = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_tl.x = this.bmp_background.x - tapeOffset;
         this.bmp_tape_tl.y = this.bmp_background.y - tapeOffset;
         this.mc_container.addChild(this.bmp_tape_tl);
         this.bmp_tape_tr = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_tr.scaleX = -1;
         this.bmp_tape_tr.x = this.bmp_background.x + this.bmp_background.width + tapeOffset;
         this.bmp_tape_tr.y = this.bmp_background.y - tapeOffset;
         this.mc_container.addChild(this.bmp_tape_tr);
         this.bmp_tape_bl = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_bl.scaleY = -1;
         this.bmp_tape_bl.x = this.bmp_background.x - tapeOffset;
         this.bmp_tape_bl.y = this.bmp_background.y + this.bmp_background.height + tapeOffset;
         this.mc_container.addChild(this.bmp_tape_bl);
         this.bmp_tape_br = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_br.scaleX = -1;
         this.bmp_tape_br.scaleY = -1;
         this.bmp_tape_br.x = this.bmp_background.x + this.bmp_background.width + tapeOffset;
         this.bmp_tape_br.y = this.bmp_background.y + this.bmp_background.height + tapeOffset;
         this.mc_container.addChild(this.bmp_tape_br);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_desc.dispose();
         this.txt_level.dispose();
         this.bmp_levelOK.bitmapData.dispose();
         this.bmp_background.bitmapData.dispose();
         this.bmp_tape_tl.bitmapData.dispose();
         this.bmp_tape_tr.bitmapData.dispose();
         this.bmp_tape_bl.bitmapData.dispose();
         this.bmp_tape_br.bitmapData.dispose();
      }
      
      private function onClickLaunch(param1:MouseEvent) : void
      {
         var _loc2_:ArenaDialogue = new ArenaDialogue(this._arenaName);
         _loc2_.open();
      }
   }
}

