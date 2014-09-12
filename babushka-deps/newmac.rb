CASK_APPS = %w(
  google-chrome
  dropbox
  onepassword
  iterm2
  font-meslo-lg-for-powerline
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
