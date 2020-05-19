# Slimmed-down subset of installs for a work machine

dep 'workmac' do
  requires(
    %w(
      homebrew
      brew-cask
      brew-fonts
      font-meslo-for-powerline.brewcask
      clipy.brewcask
      utc-menu-clock.brewcask
      brew-packages
      dotfiles
      fzf_install
    )
    # to add after fixing problems
    # clipy.app_config
    # dock.app_config
    # finder.app_config
    # system_preferences
  )
end
