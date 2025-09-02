# The Last Stand: Dead Zone - Private Server

Welcome to the private server project for *The Last Stand: Dead Zone*. This project allows fans to relive this iconic game in a private setting.

---

## 📖 About the Game

*The Last Stand: Dead Zone* is a game developed by Chris "Con" Condon, the founder of Con Artist Games. It blends RPG, action, and strategy elements in a post-apocalyptic world overrun by zombies. This game remains a cherished title among fans of the genre and the series.

---

## 🎯 Project Goal

The goal of this project is to recreate an authentic gameplay experience for private, personal use only. We have immense respect for the work of Chris "Con" Condon and his team, and we encourage players to support the developers by exploring their other creations.

---

## 🙏 Acknowledgments

We extend our sincere thanks to Chris "Con" Condon and Con Artist Games for their exceptional work on *The Last Stand: Dead Zone* and other games in the series. Their dedication and creativity have made a lasting impact on fans worldwide.

---

## ☕ Support the Project  

If you appreciate our work on *The Last Stand: Dead Zone - Private Server* and want to support further development, you can now do so via **Buy Me a Coffee**! Your contributions help keep this project alive and improve its quality.  

🔗 **Support us here:** [buymeacoffee.com/sulivanm](https://buymeacoffee.com/sulivanm)  

Thank you for your support! ❤️  

---

## ⚠️ Disclaimer

This project is strictly for private and non-commercial use. We have no intention of infringing upon the rights of the original creators. If you enjoy this game, please support the developers by exploring their other works and following them on their official platforms.

For more information about Con Artist Games and their current projects, visit their official pages.

---

## 📝 TODO: Development Roadmap

1. ~Research and Documentation~
2. ~Game Client Reconstruction~
3. Server Development <------ HERE
4. Multiplayer Features  
5. Testing and Debugging  
6. Finalization  

---

## 🛠️ Setup & Launch Guide

### Tools

- [Basilisk web browser](https://www.basilisk-browser.org/) ([Portable version with Flash pre-installed](https://www.mediafire.com/file/tmecqq7ke0uhqm7/Basilisk_with_Flash_%2528debug%2529.zip/file))
- [JPEXS Free Flash Decompiler](https://github.com/jindrapetrik/jpexs-decompiler)
- [Adobe Flash Player with debug enabled](https://archive.org/details/flashplayer32.0.0.465_win_debug_npapi_patched)

### Prerequisites
- Python installed and added to your system PATH.  
- Internet connection for dependency installation.
- `127.0.0.1 ddeadzonegame.com` configured in `hosts` file. Some of the urls are hardcoded into the game.

### Quick Setup & Launch

1. Place the provided `run.bat` script in the root folder of the project (next to `index.html`).

2. Double-click `run.bat` or run it via Command Prompt.  
   This script will:  
   - Update `pip`  
   - Install dependencies from all `requirements.txt` files inside the directories  
   - Launch `api_server/main.py`, `socket_server/main.py`, `file_server/main.py` and `workaround.py` in separate windows  

3. Open your browser and go to:  
   `http://127.0.0.1:8000/`  

---

### Additional Notes
- Ensure firewall rules allow access to port 8000 and the socket server ports if applicable.  
- This project assumes basic knowledge of running Python scripts and web servers.  
- For testing the web server in a more advanced environment, you may use tools like XAMPP or other HTTP servers.
- We have public documentation about the game at [DeadZone Documentation](https://dead-zone-documentation.vercel.app/) (the [GitHub](https://github.com/glennhenry/DeadZone-Documentation)). Please share your research on the game's source code to help new contributors.
- For more assistance, join our [Discord community](https://discord.gg/Q5dTKrPmfq).
