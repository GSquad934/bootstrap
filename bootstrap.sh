#!/bin/bash
#
# Description: this script automates the installation of my personal computer
# Compatibility: it works for both macOS and Linux

#=============
# Global Variables
#=============

# Dotfiles location
dfloc="$HOME/projects/dotfiles"
dfrepo="https://github.com/GSquad934/dotfiles.git"

# Custom scripts location
scriptsloc="$HOME/scripts"
scriptsrepo="https://github.com/GSquad934/scripts.git"

# Logging
date="$(date +%Y-%m-%d-%H%M%S)"
logfile="$HOME/bootstrap_log_$date.txt"

# Software lists
homebrew="https://raw.githubusercontent.com/Homebrew/install/master/install"
macos_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_common_apps.txt"
macos_casks="https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_common_casks.txt"
macos_store_common_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_store_common_apps.txt"
macos_store_work_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_store_work_apps.txt"
macos_work_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_work_apps.txt"
macos_work_casks="https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_work_casks.txt"
debian_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/debian_common_apps.txt"
debian_work_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/debian_work_apps.txt"
redhat_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/redhat_common_apps.txt"
redhat_work_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/redhat_work_apps.txt"
arch_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/arch_common_apps.txt"
arch_work_apps="https://raw.githubusercontent.com/GSquad934/bootstrap/master/arch_work_apps.txt"
server_tools="https://raw.githubusercontent.com/GSquad934/bootstrap/master/server_tools.txt"

# Font lists
mononoki_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf"
mononoki_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete.ttf"
mononoki_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete.ttf"
powerline_fonts="https://github.com/powerline/fonts"

# TMUX Plugins
tpm="https://github.com/tmux-plugins/tpm"

#=============
# Install Homebrew on macOS
#=============
if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew > /dev/null 2>&1; then
	echo -e "Installing Homebrew..."
	echo -e
	sudo chown -R "$(whoami)":admin /usr/local
	ruby -e "$(curl -fsSL $homebrew)" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	brew doctor 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	brew update 2>&1 | tee -a "$logfile" > /dev/null 2>&1
fi

#=============
# Install XCode Command Line Tools on macOS
#=============
if [[ "$OSTYPE" == "darwin"* ]] && [[ ! -d /Library/Developer/CommandLineTools ]]; then
	xcode-select --install
	echo -e
fi

#=============
# Install common packages on workstation
#=============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	read -p "Do you want to install common applications? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo -e "Installing common software..."
		if [[ "$OSTYPE" == "darwin"* ]] && command -v brew > /dev/null 2>&1; then
			brew update 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			curl -fsSL "$macos_apps" --output "$HOME"/macos_common_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			curl -fsSL "$macos_casks" --output "$HOME"/macos_common_casks.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			< "$HOME"/macos_common_apps.txt xargs brew install 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			< "$HOME"/macos_common_casks.txt xargs brew cask install 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			rm "$HOME"/macos_common*.txt
		elif [[ "$OSTYPE" == "darwin"* ]] && command -v mas > /dev/null 2>&1; then
			read -p "Do you want to install App Store common applications? (Y/n) " -n 1 -r
			echo -e
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				echo -e "Installing App Store applications..."
				curl -fsSL "$macos_store_common_apps" --output "$HOME"/macos_store_common_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				awk '{print $1}' "$HOME"/macos_store_common_apps.txt | xargs mas install 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				rm "$HOME"/macos_store*.txt
				echo -e "Common App Store applications installed"
			fi
		elif [[ "$OSTYPE" == "linux-gnu" ]]; then
			if command -v apt > /dev/null 2>&1; then
				sudo apt update 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$debian_apps" --output "$HOME"/debian_common_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo apt install -y "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < debian_common_apps.txt)
				rm "$HOME"/debian_common*.txt
			elif command -v apt-get > /dev/null 2>&1; then
				sudo apt-get update 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$debian_apps" --output "$HOME"/debian_common_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo apt-get install -y "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < debian_common_apps.txt)
				rm "$HOME"/debian_common*.txt
			elif command -v yum > /dev/null 2>&1; then
				sudo yum update -y 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$redhat_apps" --output "$HOME"/redhat_common_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo yum install -y "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < redhat_common_apps.txt)
				rm "$HOME"/redhat_common*.txt
			elif command -v pacman > /dev/null 2>&1; then
				sudo pacman -Syyu --noconfirm 2>&1| tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$arch_apps" --output "$HOME"/arch_common_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo pacman -S --noconfirm install "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < arch_common_apps.txt)
				rm "$HOME"/arch_common*.txt
			fi
		fi
		echo -e "Common software installed"
		echo -e
	fi
fi

#=============
# Install work packages on workstation
#=============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo -e "Installing work software..."
		if [[ "$OSTYPE" == "darwin"* ]] && command -v brew > /dev/null 2>&1; then
			curl -fsSL "$macos_work_apps" --output "$HOME"/macos_work_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			curl -fsSL "$macos_work_casks" --output "$HOME"/macos_work_casks.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			< macos_work_apps.txt xargs brew install 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			< macos_work_casks.txt xargs brew cask install 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			rm "$HOME"/macos_work*.txt
		elif [[ "$OSTYPE" == "darwin"* ]] && command -v mas > /dev/null 2>&1; then
			read -p "Do you want to install App Store work applications? (Y/n) " -n 1 -r
			echo -e
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				echo -e "Installing App Store applications..."
				curl -fsSL "$macos_store_work_apps" --output "$HOME"/macos_store_work_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				awk '{print $1}' "$HOME"/macos_store_work_apps.txt | xargs mas install 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				rm "$HOME"/macos_store*.txt
				echo -e "Work App Store applications installed"
			fi
		elif [[ "$OSTYPE" == "linux-gnu" ]]; then
			if command -v apt > /dev/null 2>&1; then
				sudo apt update 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$debian_work_apps" --output "$HOME"/debian_work_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo apt install -y "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < debian_work_apps.txt)
				rm "$HOME"/debian_work*.txt
			elif command -v apt-get > /dev/null 2>&1; then
				sudo apt-get update 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$debian_work_apps" --output "$HOME"/debian_work_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo apt-get install -y "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < debian_work_apps.txt)
				rm "$HOME"/debian_work*.txt
			elif command -v yum > /dev/null 2>&1; then
				sudo yum update -y 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$redhat_work_apps" --output "$HOME"/redhat_work_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo yum install -y "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < redhat_work_apps.txt)
				rm "$HOME"/redhat_work*.txt
			elif command -v pacman > /dev/null 2>&1; then
				sudo pacman -Syyu --noconfirm 2>&1| tee -a "$logfile" > /dev/null 2>&1
				curl -fsSL "$arch_work_apps" --output "$HOME"/arch_work_apps.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				while IFS= read -r line
				do
					sudo pacman -S --noconfirm install "$line" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
				done < <(grep -v '^ *#' < arch_work_apps.txt)
				rm "$HOME"/arch_work*.txt
			fi
		fi
		echo -e "Work software installed"
		echo -e
	fi
fi

#============
# Install fonts on workstation
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	read -p "Do you want to install custom fonts? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo -e "Installing custom fonts..."
		if [[ "$OSTYPE" == "darwin"* ]]; then
			mkdir "$HOME"/fonts && cd "$HOME/fonts" || exit
			wget -c --content-disposition "$mononoki_regular" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			wget -c --content-disposition "$mononoki_bold" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			wget -c --content-disposition "$mononoki_italic" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			wget -c --content-disposition "$jetbrainsmono_regular" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			wget -c --content-disposition "$jetbrainsmono_bold" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			wget -c --content-disposition "$jetbrainsmono_italic" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			mv "$HOME"/fonts/*.ttf "$HOME"/Library/Fonts/ 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			echo -e
			git clone "$powerline_fonts" "$HOME"/fonts 2>&1 | tee -a "$logfile" > /dev/null 2>&1 && "$HOME"/fonts/install.sh
			rm -Rf "$HOME"/fonts > /dev/null 2>&1
		fi
		echo -e "Custom fonts installed"
		echo -e
	fi
fi

#============
# Install TMUX Plugin Manager
#============
if command -v tmux > /dev/null 2>&1; then
	if [[ -d "$HOME"/.tmux/plugins/tpm ]]; then
		read -p "TMUX Plugin Manager (TPM) is already installed. Do you want to reinstall it? (Y/n) " -n 1 -r
		echo -e
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Reinstalling TMUX Plugin Manager..."
			rm -Rf "$HOME"/.tmux/plugins/tpm
			git clone "$tpm" "$HOME"/.tmux/plugins/tpm 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			echo -e "TMUX Plugin Manager installed"
			echo -e "In TMUX, press <PREFIX> + I to install plugins"
			echo -e
		fi
	else
		read -p "Do you want to handle TMUX plugins? (Y/n) " -n 1 -r
		echo -e
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing TMUX Plugin Manager..."
			git clone "$tpm" "$HOME"/.tmux/plugins/tpm 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			echo -e "TMUX Plugin Manager installed"
			echo -e "In TMUX, press <PREFIX> + I to install plugins"
			echo -e
		fi
	fi
fi

#============
# macOS Workstation - Configuration
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
	read -p "Do you want to setup System Preferences? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then

		# Close any open System Preferences panes, to prevent them from overriding
		# settings we’re about to change
		osascript -e 'tell application "System Preferences" to quit'

		# Ask for the administrator password upfront
		echo -e "Setting up system preferences..."
		sudo -v

		# Allow running applications from anywhere
		sudo spctl --master-disable

		# Disable software quarantine that displays 'Are you sure you want to run...'
		if [[ $(ls -lhdO "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 | awk '{print$5}') != schg ]]; then
			echo -e "" > "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
			sudo chflags schg "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 > /dev/null 2>&1
		fi

		# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
		while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

		# Disable automatic spelling correction
		defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

		# Disable automatic capitalization
		defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

		# Adjust smart quotes
		defaults write NSGlobalDomain NSUserQuotesArray -array '"\""' '"\""' '"'\''"' '"'\''"'

		# Enable Dark mode
		defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

		# Set a blazingly fast keyboard repeat rate
		defaults write NSGlobalDomain KeyRepeat -int 1
		defaults write NSGlobalDomain InitialKeyRepeat -int 10

		# Build the 'locate' database
		sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		sudo /usr/libexec/locate.updatedb 2>&1 | tee -a "$logfile" > /dev/null 2>&1

		echo -e "System preferences configured"
		echo -e
	fi
fi

#============
# Linux Workstation - Configuration
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == "linux-gnu" ]]; then
	read -p "Do you want to configure preferences? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then

		# Ask for the administrator password upfront
		echo -e "Starting configuration process..."
		sudo -v

		# Build the 'locate' database
		sudo updatedb

		echo -e "Preferences configured"
		echo -e
	fi
fi

#==============
# Dotfiles Installation
#==============

# Clone the GitHub repository with all wanted dotfiles
read -p "Do you want to install the dotfiles? (Y/n) " -n 1 -r
echo -e
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
	if [[ ! -d "$dfloc" ]]; then
		echo -e "Retrieving dotfiles..."
		mkdir -pv "$dfloc"
		git clone --recurse-submodules "$dfrepo" "$dfloc" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		git -C "$dfloc" submodule foreach --recursive git checkout master 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	else
		git -C "$dfloc" pull 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi

	if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ ! -d "$scriptsloc" ]]; then
		echo -e "Installing custom scripts..."
		mkdir "$scriptsloc"
		git clone --recurse-submodules "$scriptsrepo" "$scriptsloc" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		git -C "$scriptsloc" submodule foreach --recursive git checkout master 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	elif [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ -d "$scriptsloc" ]]; then
		read -p "[CUSTOM SCRIPTS DETECTED] Do you want to (re)install the scripts? (Y/n) " -n 1 -r
		echo -e
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing custom scripts..."
			rm -Rf "$scriptsloc" && mkdir "$scriptsloc"
			git clone --recurse-submodules "$scriptsrepo" "$scriptsloc" 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			git -C "$scriptsloc" submodule foreach --recursive git checkout master 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		fi
	fi

	# Remove and backup all original dotfiles
	read -p "Do you want to backup your current dotfiles? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		bkpdf=1
		echo -e "Backup your current dotfiles to $HOME/.old-dotfiles..."
		if [[ ! -d "$HOME"/.old-dotfiles ]]; then
			mkdir "$HOME"/.old-dotfiles > /dev/null 2>&1
		else
			rm -Rf "$HOME"/.old-dotfiles > /dev/null 2>&1
			mkdir "$HOME"/.old-dotfiles > /dev/null 2>&1
		fi
		mv "$HOME"/.bash_profile "$HOME"/.old-dotfiles/bash_profile > /dev/null 2>&1
		mv "$HOME"/.bashrc "$HOME"/.old-dotfiles/bashrc > /dev/null 2>&1
		mv "$HOME"/.gitconfig "$HOME"/.old-dotfiles/gitconfig > /dev/null 2>&1
		mv "$HOME"/.iterm2 "$HOME"/.old-dotfiles/iterm2 > /dev/null 2>&1
		mv "$HOME"/.msmtprc "$HOME"/.old-dotfiles/msmtprc > /dev/null 2>&1 || mv "$HOME"/.config/msmtp "$HOME"/.old-dotfiles/msmtp > /dev/null 2>&1
		mv "$HOME"/.p10k.zsh "$HOME"/.old-dotfiles/p10k.zsh > /dev/null 2>&1
		mv "$HOME"/.tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1
		mv "$HOME"/.vim "$HOME"/.old-dotfiles/vim > /dev/null 2>&1
		mv "$HOME"/.vimrc "$HOME"/.old-dotfiles/vimrc > /dev/null 2>&1
		mv "$HOME"/.zshrc "$HOME"/.old-dotfiles/zshrc > /dev/null 2>&1
		mv "$HOME"/.zprofile "$HOME"/.old-dotfiles/zprofile > /dev/null 2>&1
		mv "$HOME"/.config/nvim/init.vim "$HOME"/.old-dotfiles/init.vim > /dev/null 2>&1
		mv "$HOME"/.config/nvim "$HOME"/.old-dotfiles/nvim > /dev/null 2>&1
		mv "$HOME"/.config/wget "$HOME"/.old-dotfiles/wget > /dev/null 2>&1
		mv "$HOME"/.config/vifm "$HOME"/.old-dotfiles/vifm > /dev/null 2>&1
		mv "$HOME"/.config/alacritty "$HOME"/.old-dotfiles/alacritty > /dev/null 2>&1
		mv "$HOME"/.qutebrowser "$HOME"/.old-dotfiles/qutebrowser > /dev/null 2>&1
	else
		rm -rf "$HOME"/.bash_profile
		rm -rf "$HOME"/.bashrc
		rm -rf "$HOME"/.gitconfig
		rm -rf "$HOME"/.iterm2
		rm -rf "$HOME"/.msmtprc ; rm -Rf "$HOME"/.config/msmtp
		rm -rf "$HOME"/.p10k.zsh
		rm -rf "$HOME"/.tmux.conf
		rm -rf "$HOME"/.vim
		rm -rf "$HOME"/.vimrc
		rm -rf "$HOME"/.zshrc
		rm -rf "$HOME"/.zprofile
		rm -rf "$HOME"/.config/nvim/init.vim
		rm -rf "$HOME"/.config/nvim
		rm -rf "$HOME"/.config/wget
		rm -rf "$HOME"/.config/vifm
		rm -rf "$HOME"/.config/alacritty
		rm -rf "$HOME"/.qutebrowser
	fi
	if [[ -f "$HOME"/.config/weechat/sec.conf ]]; then
		echo -e "A Weechat private configuration has been detected (sec.conf)."
		read -p "Do you want to reset the private Weechat configuration (sec.conf)? (Y/n) " -n 1 -r
		echo -e
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			if [[ -n "$bkpdf" ]]; then
				mv "$HOME"/.config/weechat "$HOME"/.old-dotfiles/weechat > /dev/null 2>&1
			else
				rm -Rf "$HOME"/.config/weechat
			fi
		else
			if [[ -n "$bkpdf" ]]; then
				mv "$HOME"/.config/weechat "$HOME"/.old-dotfiles/weechat > /dev/null 2>&1
				mkdir "$HOME"/.config/weechat
				mv "$HOME"/.old-dotfiles/weechat/sec.conf "$HOME"/.config/weechat/sec.conf
			else
				mv "$HOME"/.config/weechat/sec.conf "$HOME"/sec.conf
				rm -Rf "$HOME"/.config/weechat
				mkdir "$HOME"/.config/weechat
				mv "$HOME"/sec.conf "$HOME"/.config/weechat/sec.conf
			fi
		fi
	fi

	# Create symlinks in the home folder
	echo -e "Installing new dotfiles..."
	if [[ ! -d "$HOME"/.config ]]; then mkdir "$HOME"/.config; fi
	ln -s "$dfloc"/gitconfig "$HOME"/.gitconfig 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$dfloc"/shellconfig/p10k.zsh "$HOME"/.p10k.zsh 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$dfloc"/vim "$HOME"/.vim 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$dfloc"/vim/vimrc "$HOME"/.vimrc 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$dfloc"/shellconfig/bashrc "$HOME"/.bashrc 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	touch "$HOME"/.bash_profile && echo -e "source $HOME/.bashrc" > "$HOME"/.bash_profile
	ln -s "$dfloc"/shellconfig/zshrc "$HOME"/.zshrc 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$HOME"/.vim "$HOME"/.config/nvim 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$HOME"/.vim/vimrc "$HOME"/.config/nvim/init.vim 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	ln -s "$dfloc"/config/wget "$HOME"/.config/wget 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	if command -v weechat > /dev/null 2>&1; then
		if [[ ! -d "$HOME"/.config/weechat ]]; then
			mkdir "$HOME"/.config/weechat
		fi
		ln -s "$dfloc"/config/weechat/irc.conf "$HOME"/.config/weechat/irc.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/perl "$HOME"/.config/weechat/perl 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/python "$HOME"/.config/weechat/python 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/trigger.conf "$HOME"/.config/weechat/trigger.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/weechat.conf "$HOME"/.config/weechat/weechat.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/xfer.conf "$HOME"/.config/weechat/xfer.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/buflist.conf "$HOME"/.config/weechat/buflist.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/colorize_nicks.conf "$HOME"/.config/weechat/colorize_nicks.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/fset.conf "$HOME"/.config/weechat/fset.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/weechat/iset.conf "$HOME"/.config/weechat/iset.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi
	if command -v vifm > /dev/null 2>&1; then
		if [[ ! -d "$HOME"/.config/vifm ]]; then
			mkdir "$HOME"/.config/vifm
		fi
		ln -s "$dfloc"/config/vifm/colors "$HOME"/.config/vifm/colors 2>&1 | tee -a "$logfile" > /dev/null 2>&1
		ln -s "$dfloc"/config/vifm/vifmrc "$HOME"/.config/vifm/vifmrc 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi
	if command -v msmtp > /dev/null 2>&1; then
		ln -s "$dfloc"/config/msmtp "$HOME"/.config/msmtp 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi
	if command -v alacritty > /dev/null 2>&1 || [[ -d /Applications/Alacritty.app ]]; then
		ln -s "$dfloc"/config/alacritty "$HOME"/.config/alacritty 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi
	if [[ -d /Applications/iTerm.app ]]; then
		ln -s "$dfloc"/iterm2 "$HOME"/.iterm2 > /dev/null 2>&1
	fi
	if command -v qutebrowser > /dev/null 2>&1 || [[ -d /Applications/qutebrowser.app ]]; then
		ln -s "$dfloc"/config/qutebrowser "$HOME"/.qutebrowser 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi

	# If this is a SSH connection, install the server config of TMUX
	if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
		ln -s "$dfloc"/tmux/tmux29-server.conf "$HOME"/.tmux.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	else
		ln -s "$dfloc"/tmux/tmux-workstation.conf "$HOME"/.tmux.conf 2>&1 | tee -a "$logfile" > /dev/null 2>&1
	fi
	echo -e "New dotfiles installed"
	echo -e
fi

#==============
# macOS - Amethyst Configuration
#==============
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] && [[ "$OSTYPE" == "darwin"* ]] && [[ -d /Applications/Amethyst.app ]]; then
	read -p "Do you want to install Amethyst's configuration? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo -e "Setting up Amethyst..."
		# Set windows to always stay in floating mode
		defaults write com.amethyst.Amethyst.plist floating '(
		        {
    	    id = "com.apple.systempreferences";
    	    "window-titles" =         (
    	    );
    	},
		        {
    	    id = "com.skitch.skitch";
    	    "window-titles" =         (
    	    );
    	},
		        {
    	    id = "com.microsoft.autoupdate2";
    	    "window-titles" =         (
    	    );
    	},
		        {
    	    id = "com.apple.Stickies";
    	    "window-titles" =         (
    	    );
    	},
    	    {
    	    id = "com.tapbots.Tweetbot3Mac";
    	    "window-titles" =         (
    	    );
    	}
		)'
		defaults write com.amethyst.Amethyst.plist floating-is-blacklist 1

		# Follow window when moved to different workspace
		defaults write com.amethyst.Amethyst.plist follow-space-thrown-windows 1

		# Configure layouts
		defaults write com.amethyst.Amethyst.plist layouts '(
			tall, wide, floating, fullscreen
		)'

		# Restore layouts when application starts
		defaults write com.amethyst.Amethyst.plist restore-layouts-on-launch 1

		# Set window margins
		defaults write com.amethyst.Amethyst.plist window-margins 1
		defaults write com.amethyst.Amethyst.plist window-margin-size 6

		# Do not display layout names
		defaults write com.amethyst.Amethyst.plist enables-layout-hud 0
		defaults write com.amethyst.Amethyst.plist enables-layout-hud-on-space-change 0

		# Disable automatic update check as it is done by Homebrew
		defaults write com.amethyst.Amethyst.plist SUEnableAutomaticChecks 0

		# Delete the plist cache
		defaults read com.amethyst.Amethyst.plist > /dev/null 2>&1

		echo -e "Amethyst configured"
		echo -e
	fi
fi


#===============================================================================
#
#             NOTES: this next section will apply with any remote
#                 connections. It is meant for Linux servers
#
#===============================================================================
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] && [[ "$OSTYPE" == 'linux-gnu' ]]; then

#=============
# Install server packages
#=============
	read -p "[SERVER SESSION DETECTED] Do you want to install useful tools? (Y/n) " -n 1 -r
	echo -e
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo -e "Installing useful server tools..."
		if command -v apt > /dev/null 2>&1; then
			sudo apt update 2>&1 | tee -a "$logfile"
			curl -fsSL "$server_tools" --output "$HOME"/server_tools.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			while IFS= read -r line
			do
				sudo apt install -y "$line" 2>&1 | tee -a "$logfile"
			done < <(grep -v '^ *#' < server_tools.txt)
			rm "$HOME"/server_tools.txt
		elif command -v apt-get > /dev/null 2>&1; then
			sudo apt-get update 2>&1 | tee -a "$logfile"
			curl -fsSL "$server_tools" --output "$HOME"/server_tools.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			while IFS= read -r line
			do
				sudo apt-get install -y "$line" 2>&1 | tee -a "$logfile"
			done < <(grep -v '^ *#' < server_tools.txt)
			rm "$HOME"/server_tools.txt
		elif command -v yum > /dev/null 2>&1; then
			sudo yum update -y 2>&1 | tee -a "$logfile"
			curl -fsSL "$server_tools" --output "$HOME"/server_tools.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			while IFS= read -r line
			do
				sudo yum install -y "$line" 2>&1 | tee -a "$logfile"
			done < <(grep -v '^ *#' < server_tools.txt)
			rm "$HOME"/server_tools.txt
		elif command -v pacman > /dev/null 2>&1; then
			sudo pacman -Syyu --noconfirm 2>&1 | tee -a "$logfile"
			curl -fsSL "$server_tools" --output "$HOME"/server_tools.txt 2>&1 | tee -a "$logfile" > /dev/null 2>&1
			while IFS= read -r line
			do
				sudo pacman -S --noconfirm "$line" 2>&1 | tee -a "$logfile"
			done < <(grep -v '^ *#' < server_tools.txt)
			rm "$HOME"/server_tools.txt
		fi
		echo -e "Useful server tools installed"
		echo -e
	fi
fi

#==============
# DONE
#==============
echo -e
echo -e
echo -e "======= ALL DONE ======="
echo -e
echo -e "If anything has been modified, please reboot the computer for all the settings to be applied (not applicable to servers)."
echo -e "A log file called \"$logfile\" contains the details of all operations. Check if for errors."