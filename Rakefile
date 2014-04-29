require 'rubygems'
require 'bundler/setup' # Releasy requires require that your application uses bundler.
Bundler.require :development # Only require Releasy, since we don't need to load Gosu/Chingu at this point.
require 'releasy'

#<<<
Releasy::Project.new do
  name "No Hawking"
  version "1.0.1"
  verbose # Can be removed if you don't want to see all build messages.

  executable "lib/game.rb"
  files ["lib/*.rb", "celestialbodies/*.png", "actors/*.png", "effects/*.png", "ui/*.png"]
  add_link "http://www.github.com/jellymann/no-hawking", "Github Page"
  exclude_encoding # Applications that don't use advanced encoding (e.g. Japanese characters) can save build size with this.

  # Create a variety of releases, for all platforms.
  add_build :osx_app do
    url "com.jellymann.nohawking"
    wrapper "wrappers/gosu-mac-wrapper-0.7.47.tar.gz" # Assuming this is where you downloaded this file.
    add_package :dmg
  end

  add_build :source do
    add_package :"7z"
  end

  # If building on a Windows machine, :windows_folder and/or :windows_installer are recommended.
  add_build :windows_folder do
    executable_type :windows # Assuming you don't want it to run with a console window.
    add_package :exe # Windows self-extracting archive.
  end

  add_build :windows_installer do
    start_menu_group "Jellymann Games"
    executable_type :windows # Assuming you don't want it to run with a console window.

  end

  # If unable to build on a Windows machine, :windows_wrapped is the only choice.
  add_build :windows_wrapped do
    wrapper "wrappers/ruby-1.9.3-p545-i386-mingw32.7z" # Assuming this is where you downloaded this file.
    executable_type :windows # Assuming you don't want it to run with a console window.
    exclude_tcl_tk # Assuming application doesn't use Tcl/Tk, then it can save a lot of size by using this.
    add_package :zip
  end

  add_deploy :local # Only deploy locally.
end
#>>>
