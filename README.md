# The Last Stand: Dead Zone - Private Server

Welcome to the private server project for *The Last Stand: Dead Zone*. This project is designed to allow fans to relive this iconic game in a private setting.

## About the Game

*The Last Stand: Dead Zone* is a game developed by Chris "Con" Condon, founder of Con Artist Games. It blends RPG, action, and strategy elements within a post-apocalyptic zombie universe. This game remains a beloved title for fans of the genre and the series.

## Purpose of the Project

This project aims to recreate a faithful gaming experience of the original game for private and personal use only. We hold immense respect for the work of Chris "Con" Condon and his team, and we encourage players to support the developers by exploring their other creations.

## Acknowledgments

We extend our heartfelt thanks to Chris "Con" Condon and Con Artist Games for their exceptional work on *The Last Stand: Dead Zone* and the other games in the series. Their dedication and creativity have left a lasting impact on fans worldwide.

## Disclaimer

This project is strictly for private and non-commercial use. We have no intention of infringing on the rights of the original creators. If you love this game, please support the developers by exploring their other works and following them on their official platforms.

For more about Con Artist Games and their current projects, visit their official pages.

---

## TODO: Development Roadmap

### 1. Research and Documentation
- Collect and analyze game resources (e.g., assets, mechanics, and structure).
- Document key elements necessary to recreate the game experience.

### 2. Server Development
- Build a basic server structure to host game data with python.
- Develop APIs to mimic the original game's server communication.
- Test server stability and performance.

### 3. Game Client Reconstruction
- Recreate the game's user interface and mechanics using reverse-engineering.
- Implement game logic and interactions.

### 4. Multiplayer Features
- Enable player registration and login functionalities.
- Develop a system for syncing game data between server and client.

### 5. Testing and Debugging
- Conduct extensive testing to ensure the game is bug-free.
- Fix compatibility issues and optimize for various devices.

### 6. Finalization
- Ensure the game is as faithful as possible to the original.
- Provide detailed instructions for personal use and setup.

---

## Installation Steps

1. **Install XAMPP or a Web Server**:  
   First, you need to install XAMPP or any other web server of your choice. This will serve as the environment to run the web client of the game.

2. **Move the Files to the Server**:  
   After installing XAMPP, place all the files located in (typically `htdocs` in XAMPP).

3. **Access the Web Page**:  
   You can access the game page via your browser. However, please note that the server socket/API part of the game is **not yet functional** at this point.

4. **Run the Python Server**:  
   To get the server working, you need to download and install Python. After installing Python, navigate to the `server` folder located within the `building` folder using the command prompt (CMD) or terminal. Then, run the following command to start the server:

   ```bash
   python app.py

*Note: This project is fan-made and non-commercial. All rights to *The Last Stand: Dead Zone* belong to Con Artist Games.*

### Example: Using VSCode Live Server as Web Server

#### Running the Web Server

1. Download & Install [Visual Studio Code](https://code.visualstudio.com/).
2. Install the [Live Server extension](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer).
3. Download this repository (Code > Download ZIP) and extract it on a folder.
4. On your browser, install Ruffle extension ([Firefox](https://addons.mozilla.org/en-US/firefox/addon/ruffle_rs/), [Chrome](https://chromewebstore.google.com/detail/ruffle-flash-emulator/donbcfbmhbcapadipfkeojnmajbakjdc?hl=en)). Make sure to enable running flash content using Ruffle. This step can be skipped if your browser supports flash (e.g., [Basilisk](https://archive.org/details/basilisk-portable-with-flash_202502)).
5. On VSCode, File > Open Folder, then select the extracted folder.
6. Right click on index.html, then select "Open with Live Server".

#### Running the Socket Server

1. Download & Install [Python](https://www.python.org/downloads/). During the installation, make sure that pip is also installed and `python.exe` as well as pip are added to the PATH environment variable.
2. Open command line on VSCode (default shortcut `Ctrl+\`\`) and run the server by typing:
   
	```bash
   python server_socket/app.py

#### Running the API Server

1. Download & Install [Python](https://www.python.org/downloads/). During the installation, make sure that `python.exe` is added to PATH and pip is also installed.
2. Open command line on administrator mode. Install Flask by typing:
   
	```bash
    pip install flask

4. Open command line on VSCode (make a second terminal if you are running this with the socket server). Run the server by typing:
   
	```bash
   python server_api/app.py

> [!NOTE]
> Currently, the game is still stuck on the loading screen as the server part isn't working yet. Therefore, running the socket and API server is not necessary to follow.

