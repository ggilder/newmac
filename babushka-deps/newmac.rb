CASK_APPS = %w(
  google-chrome
  dropbox
  onepassword
  iterm2

)

dep 'newmac' do
  requires(
    %w(homebrew brew-cask) + CASK_APPS.map { |app| "#{app}.brewcask" }
  )
end

dep 'brew-cask' do
  met? { `brew tap`.include?('caskroom/cask') }
  meet { `brew install caskroom/cask/brew-cask` }
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
