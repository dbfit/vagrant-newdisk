module Vagrant
  module Newdisk
    class Action

      class NewDisk
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @config = @machine.config.newdisk
          @enabled = true
          @ui = env[:ui]
          if @machine.provider.to_s !~ /VirtualBox/
            @enabled = false
            env[:ui].error "The vagrant-newdisk plugin only supports VirtualBox at present."
          end
        end

        def call(env)
          # Create the disk before boot
          if @enabled and @config.is_set?
            path = @config.path
            size = @config.size
            env[:ui].info "call newdisk: size = #{size}, path = #{path}"

            if File.exist? path
              env[:ui].info "skip newdisk - already exists: #{path}"
            else
              new_disk(env, path, size)
              env[:ui].success "done newdisk: size = #{size}, path = #{path}"
            end
          end

          # Allow middleware chain to continue so VM is booted
          @app.call(env)
        end

        private

        def new_disk(env, path, size)
          driver = @machine.provider.driver
          create_disk(driver, path, size)
          attach_disk(driver, path)
        end

        def attach_disk(driver, path)
          disk = find_place_for_new_disk(driver)
          @ui.info "Attaching new disk: #{path} at #{disk}"
          driver.execute('storageattach', @machine.id, '--storagectl', disk[:controller],
                         '--port', disk[:port].to_s, '--device', disk[:device].to_s, '--type', 'hdd',
                         '--medium', path)
        end

        def find_place_for_new_disk(driver)
          disks = get_disks(driver)
          @ui.info "existing disks = #{disks.to_s}"
          controller = disks.first[:controller]
          disks = disks.select { |disk| disk[:controller] == controller }
          port = disks.map { |disk| disk[:port] }.max
          disks = disks.select { |disk| disk[:port] == port }
          max_device = disks.map { |disk| disk[:device] }.max

          {:controller => controller, :port => port.to_i, :device => max_device.to_i + 1}
        end

        def get_disks(driver)
          vminfo = get_vminfo(driver)
          disks = []
          disk_keys = vminfo.keys.select { |k| k =~ /-ImageUUID-/ }
          disk_keys.each do |key|
            uuid = vminfo[key]
            disk_name = key.gsub(/-ImageUUID-/,'-')
            parts = disk_name.split('-')
            disks << {
              controller: parts[0],
              port: parts[1].to_i,
              device: parts[2].to_i
            }
          end
          disks
        end

        def get_vminfo(driver)
          vminfo = {}
          driver.execute('showvminfo', @machine.id, '--machinereadable', retryable: true).
            split("\n").each do |line|
            parts = line.partition('=')
            key = unquoted(parts.first)
            value = unquoted(parts.last)
            vminfo[key] = value
          end
          vminfo
        end

        def create_disk(driver, path, size)
          driver.execute('createhd', '--filename', path, '--size', size.to_s)
        end

        def unquoted(s)
          s.gsub(/\A"(.*)"\Z/,'\1')
        end
      end

    end
  end
end
