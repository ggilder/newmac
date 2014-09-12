dep 'newmac' do
  requires(
    %w(
      homebrew
      brew-cask
      chrome.brewcask
      dropbox.brewcask
      onepassword.brewcask
    )
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

dep 'chrome.brewcask' do
  name 'google-chrome'
end

dep 'dropbox.brewcask' do
  name 'dropbox'
end

dep 'onepassword.brewcask' do
  name 'onepassword'
end
