# -*- mode: ruby -*-
# Copyright 2015 Peter Williams.
# Licensed under the MIT License.
#
# This Vagrantfile is used for reproducible builds of Conda packages on Mac OS
# X. VM images of OS X aren't distributable so it's not going to be very
# useful unless you also set up the appropriate VM infrastructure. The builder
# I use is OS X 10.12 with the Xcode command line tools v. 8.0 preinstalled
# and a basic Homebrew install. There's a "vagrant" user account configured as
# per https://docs.vagrantup.com/v2/boxes/base.html . The current folder is
# shared as /vagrant/ on the VM.

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure(2) do |config|
  config.vm.box = "sierra-dev"
  config.vm.provision :shell, path: "vagrant/bootstrap.sh"
end
