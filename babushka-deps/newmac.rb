# TODO
# - Make cask version of Chrome, iTerm, other apps optional - recognize if already installed

CASK_APPS = %w(
  google-chrome
  dropbox
  iterm2
  font-meslo-for-powerline
  clipy
  doxie
  utc-menu-clock
)

dep 'newmac' do
  requires(
    %w(homebrew brew-cask brew-fonts) +
    CASK_APPS.map { |app| "#{app}.brewcask" } +
    %w(
      brew-packages
      dotfiles
      dock.app_config
      finder.app_config
      system_preferences
      clipy.app_config
      fzf_install
    )
  )
end

dep 'brew-cask' do
  met? { `brew tap`.include?('caskroom/cask') }
  meet { `brew update && brew cask` }
end

dep 'brew-fonts' do
  met? { `brew tap`.include?('caskroom/fonts') }
  meet { `brew tap caskroom/fonts` }
end

meta :brewcask do
  accepts_value_for :name

  template {
    requires 'brew-cask'
    met? { `brew cask list`.include?(name) }
    meet { `brew cask install #{name}` }
  }
end

CASK_APPS.each do |app|
  dep "#{app}.brewcask" do
    name app
  end
end

dep 'brew-packages' do
  packages = %w(
    ctags
    fzf
    git
    go
    markdown
    md5deep
    neovim/neovim/neovim
    psgrep
    pstree
    reattach-to-user-namespace
    siege
    the_silver_searcher
    tig
    tmux
    tree
    vim
    z
    zsh
  )
  met? { packages.all? { |pkg| shell("brew list #{pkg}") } }
  meet { packages.all? { |pkg| log_shell("Installing #{pkg}", "brew list #{pkg} || brew install #{pkg}") } }
end

def check_app_config(domain, key, value)
  current = shell('defaults', 'read', domain, key.to_s)
  current = (current == '1') if value.kind_of?(TrueClass) || value.kind_of?(FalseClass)
  current = Float(current) if value.kind_of?(Float)
  log("#{key} current: #{current} expected: #{value.to_s}")
  current.to_s == value.to_s
end

def set_app_configs(domain, config)
  config.each do |key, value|
    value_cmd = case value
                when TrueClass, FalseClass
                  '-bool'
                when Integer
                  '-int'
                when Float
                  '-float'
                end
    value_cmd = [value_cmd, value.to_s].compact
    log_shell("Setting #{domain} #{key} = #{value}", "defaults", "write", domain, key.to_s, *value_cmd)
  end
end

def reload_app(domains, app)
  cmd = Array(domains).map { |domain| "defaults read '#{domain}'" }.join(' && ')
  log_shell("Flushing preferences cache", "#{cmd} && killall -u $USER cfprefsd")
  log_shell("Killing #{app}", "killall #{app}")
  log_shell("Launching #{app}", "open -a #{app}")
end

meta :app_config do
  accepts_value_for :domain
  accepts_value_for :app_name
  accepts_value_for :config
  accepts_value_for :extra

  template {
    met? do
      # TODO: should this check for presence of plist first?
      config.all? do |key, value|
        check_app_config(domain, key, value)
      end
    end
    meet do
      set_app_configs(domain, config)
      log_shell(extra, extra) if extra
      app = app_name || domain.split('.').last
      reload_app(domain, app)
    end
  }
end

dep 'clipy.app_config' do
  requires 'clipy.brewcask'
  domain 'com.clipy-app.Clipy'
  config({
    kCPYPrefShowStatusItemKey: 0,
    kCPYPrefNumberOfItemsPlaceInlineKey: 20,
    kCPYPrefMaxHistorySizeKey: 20,
    addNumericKeyEquivalents: 1,
    menuItemsAreMarkedWithNumbers: 0,
  })
end

dep 'dock.app_config' do
  domain 'com.apple.Dock'
  config({
    autohide: true,
    orientation: 'left',
    # Remove the auto-hiding Dock delay
    'autohide-delay' => 0.0,
    # Fast animation when hiding/showing the Dock
    'autohide-time-modifier' => 0.5,
    # Don't automatically rearrange order of spaces
    'mru-spaces' => false,
  })
end

dep 'finder.app_config' do
  domain 'com.apple.Finder'
  config({
    'ShowStatusBar' => true,
    'NewWindowTarget' => 'PfHm',
    # Disable the warning when changing a file extension
    'FXEnableExtensionChangeWarning' => false,
  })
  # Enable arrange by kind for desktop icons
  extra '/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist'
end

dep 'system_preferences' do
  # app_name 'SystemUIServer'
  config = {
    'com.apple.screencapture' => {
      # Disable shadow in screenshots
      'disable-shadow' => true,
    },
    'NSGlobalDomain' => {
      # Draw menu bar without transparency
      'AppleEnableMenuBarTransparency' => false,
      # Expand save panel by default
      'NSNavPanelExpandedStateForSaveMode' => true,
      # Expand print panel by default
      'PMPrintingExpandedStateForPrint' => true,
      # Disable press-and-hold for keys in favor of key repeat
      'ApplePressAndHoldEnabled' => false,
      # Disable auto-correct
      'NSAutomaticSpellingCorrectionEnabled' => false,
      # Add a context menu item for showing the Web Inspector in web views
      'WebKitDeveloperExtras' => true,
      # Minimize windows by double-clicking titlebar
      'AppleMiniaturizeOnDoubleClick' => true,
    },
    'com.apple.screensaver' => {
      # Require password 5 seconds after sleep or screen saver begins
      'askForPassword' => 1,
      'askForPasswordDelay' => 5,
    },
    'com.apple.menuextra.clock' => {
      # Show date in menu bar clock
      'DateFormat' => "MMM d  H:mm",
    },
    'com.apple.universalaccess' => {
      # Flash screen instead of alert sound
      'flashScreen' => false,
    },
    'Apple Global Domain' => {
      # Enable keyboard navigation of dialogs etc.
      'AppleKeyboardUIMode' => 2,
      # Turn off 2 spaces = period
      'NSAutomaticPeriodSubstitutionEnabled' => 0,
      # 24-hour time
      'AppleICUForce24HourTime' => 1,
      # Set a blazingly fast keyboard repeat rate
      'KeyRepeat' => 1,
      # Set a shorter Delay until key repeat
      'InitialKeyRepeat' => 12,
    },
  }
  met? do
    config.all? do |domain, hash|
      hash.all? do |key, value|
        check_app_config(domain, key, value)
      end
    end
  end
  meet do
    config.each do |domain, hash|
      hash.each do |key, value|
        set_app_configs(domain, hash)
      end
    end
    # Show the ~/Library folder
    `chflags nohidden ~/Library`
    reload_app(config.keys, 'SystemUIServer')
  end
end

dep 'dotfiles' do
  met? { '~/src/dotfiles'.p.dir? }
  meet do
    `mkdir -p ~/src/dotfiles && git clone --recursive git@github.com:ggilder/dotfiles.git ~/src/dotfiles`
    `cd ~/src/dotfiles && rake install`
  end
end

dep 'fzf_install' do
  requires 'fzf_symlinked'
  met? { '~/.fzf.zsh'.p.exist? }
  meet do
    version = shell('ls -1 /usr/local/Cellar/fzf | tail -1')
    `/usr/local/Cellar/fzf/#{version}/install`
  end
end

dep 'fzf_symlinked' do
  met? { '~/.fzf'.p.exist? }
  meet do
    version = shell('ls -1 /usr/local/Cellar/fzf | tail -1')
    shell("ln -s /usr/local/Cellar/fzf/#{version} ~/.fzf")
  end
end
