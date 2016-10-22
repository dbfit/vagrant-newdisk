module Vagrant
  module Newdisk
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :size
      attr_accessor :path

      def initialize
        @size = UNSET_VALUE
        @path = UNSET_VALUE
      end

      def finalize!
        return if @size == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        return { 'Newdisk configuration' => errors }
      end
    end
  end
end

