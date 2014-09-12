dep 'newmac' do
  requires(
    %w(
      homebrew
      brew-cask
    )
  )
end

dep 'brew-cask' do
  met? { `brew tap`.include?('caskroom/cask') }
  meet { `brew install caskroom/cask/brew-cask` }
end
