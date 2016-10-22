# vagrant-newdisk

A Vagrant plugin to add a disks in VirtualBox


## Installation


```shell
vagrant plugin install vagrant-newdisk
```

## Usage

Set the size you want for your disk in your Vagrantfile. For example

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.newdisk.size = 10 * 1024 # size in megabytes
  config.newdisk.path = "/tmp/your-file.vdi"
end
```
## Limitations

At present only one disk can be added to the first controller.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

