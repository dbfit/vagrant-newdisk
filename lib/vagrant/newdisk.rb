begin
  require 'vagrant'
rescue LoadError
  raise 'The vagrant-newdisk plugin must be run within vagrant.'
end


module Vagrant
  module Newdisk
    class Plugin < Vagrant.plugin('2')

      name 'vagrant-newdisk'

      description <<-DESC
      Provides the ability to add new VirtualBox disk at creation time.
      DESC

      config 'newdisk' do
        require_relative 'newdisk/config'
        Config
      end

      action_hook(:newdisk, :machine_action_up) do |hook|
        require_relative 'newdisk/actions'
        hook.before(VagrantPlugins::ProviderVirtualBox::Action::Boot, Action::NewDisk)
      end
    end
  end
end
