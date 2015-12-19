# -*- mode: ruby -*-
# Copyright 2015 Peter Williams.
# Licensed under the MIT License.
#
# This Vagrantfile is used for reproducible builds of Conda packages on Mac OS
# X. VM images of OS X aren't distributable so it's not going to be very
# useful unless you have also set up the appropriate VM infrastructure.

Vagrant.configure(2) do |config|
  config.vm.box = "pkgw-yosemite-dev"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
end
