# -*- mode: ruby -*-
# Copyright Peter Williams
# Licensed under the MIT License
#
# This Vagrantfile is used for reproducible builds of Conda packages on Mac OS
# X. VM images of OS X aren't distributable so it's not going to be very
# useful unless you also set up the appropriate VM infrastructure. The builder
# I use is OS X 10.15 with full XCode installed.

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure(2) do |config|
  # Non-old macOS's make the root directory read-only, so we have to redirect
  # Vagrant's default shared directory.
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder ".", "/private/var/vagrant",
                          id: "core",
                          :nfs => true,
                          :mount_options => ['nolock,vers=3,udp,noatime,resvport']
  config.vm.box = "catalina-dev"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
end
