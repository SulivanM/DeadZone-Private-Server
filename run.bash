#!/bin/bash

echo "===================================="
echo "🧟‍ The Last Deadzone Revive Setup 🧟‍"
echo "===================================="
echo ""

# -- Check for Python --
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: Python 3 is not installed or not in PATH."
    exit 1
fi

# -- Check for venv module --
if ! python3 -m venv --help &> /dev/null; then
    echo "❌ ERROR: 'venv' module not found."

    read -r -p "Do you want to install it now? [Y/n]: " install_venv
    install_venv=${install_venv:-Y}

    if [[ "$install_venv" =~ ^[Yy]$ ]]; then
        if command -v apt &> /dev/null; then
            echo "📦 Installing python3-venv with apt..."
            sudo apt update && sudo apt install -y python3-venv
        elif command -v pacman &> /dev/null; then
            echo "📦 Installing python3-venv with pacman..."
            sudo pacman -Sy --noconfirm python-virtualenv
        else
            echo "❌ Unsupported package manager. Please install venv manually."
            exit 1
        fi
    else
        echo "⚠️ Cannot proceed without venv. Exiting."
        exit 1
    fi
fi

# -- Create Virtual Environment --
if [[ ! -d ".venv" ]]; then
    echo ""
    echo "📦 Creating virtual environment..."
    python3 -m venv .venv
else
    echo "✅ Virtual environment already exists."
fi

# -- Activate Virtual Environment --
echo "⚙️ Activating virtual environment..."
source .venv/bin/activate

# -- Upgrade pip --
echo "⬆️ Updating pip..."
python -m pip install --upgrade pip

# -- Install Dependencies --
for server in api_server socket_server file_server; do
    if [[ -f "$server/requirements.txt" ]]; then
        echo "📦 Installing dependencies for $server..."
        python -m pip install -r "$server/requirements.txt"
    else
        echo "⚠️ No requirements.txt found in $server/"
    fi
done

# -- Terminal Launcher Function --
launch_in_terminal() {
    local title="$1"
    local command="$2"

    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal --tab --title="$title" -- bash -c "$command; exec bash"
    elif command -v konsole &> /dev/null; then
        konsole --new-tab -p tabtitle="$title" -e bash -c "$command; exec bash"
    elif command -v xfce4-terminal &> /dev/null; then
        xfce4-terminal --title="$title" --hold -e "bash -c '$command; exec bash'"
    elif command -v xterm &> /dev/null; then
        xterm -T "$title" -e "$command"
    else
        echo "❌ No supported terminal emulator found to launch: $title"
    fi
}

# -- Launch Servers --
echo "🚀 Launching servers..."
launch_in_terminal "File Server" "cd file_server && source ../.venv/bin/activate && python main.py"
launch_in_terminal "API Server" "cd api_server && source ../.venv/bin/activate && python main.py"
launch_in_terminal "Socket Server" "cd socket_server && source ../.venv/bin/activate && python main.py"
