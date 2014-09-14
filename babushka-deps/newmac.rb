CASK_APPS = %w(
  google-chrome
  dropbox
  onepassword
  iterm2
  font-meslo-lg-for-powerline
  clipmenu
  transmit
)

dep 'newmac' do
  requires(
    %w(homebrew brew-cask brew-fonts) + CASK_APPS.map { |app| "#{app}.brewcask" }
  )
end

dep 'brew-cask' do
  met? { `brew tap`.include?('caskroom/cask') }
  meet { `brew install caskroom/cask/brew-cask` }
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

meta :app_config do
  accepts_value_for :domain
  accepts_value_for :config

  template {
    met? do
      # TODO: should this check for presence of plist first?
      config.all? do |key, value|
        current = shell('defaults', 'read', domain, key.to_s)
        log("#{key} current: #{current} expected: #{value.to_s}")
        current == value.to_s
      end
    end
    meet do
      config.each do |key, value|
        log_shell("Setting #{domain} #{key} = #{value}", "defaults", "write", domain, key.to_s, value.to_s)
      end
      app_name = domain.split('.').last
      log_shell("Restarting #{app_name}", "killall #{app_name} && open -a #{app_name}")
    end
  }
end

dep 'clipmenu.app_config' do
  requires 'clipmenu.brewcask'
  domain 'com.naotaka.ClipMenu'
  config({
    showStatusItem: 0,
    addNumericKeyEquivalents: 1,
    menuItemsAreMarkedWithNumbers: 0,
    numberOfItemsPlaceInline: 20,
  })
end
