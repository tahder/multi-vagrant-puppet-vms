#!/bin/sh

set -e

# Load up the release information
. /etc/lsb-release

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Install Puppet Master
    wget https://apt.puppetlabs.com/puppet-release-${DISTRIB_CODENAME}.deb && \
    sudo dpkg -i puppet-release-${DISTRIB_CODENAME}.deb && \
    sudo apt-get update -yq && sudo apt-get upgrade -yq && \
    sudo apt-get install -yq puppetmaster

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.56.5    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.56.10   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.56.20   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    sudo puppet module install puppetlabs-ntp
    sudo puppet module install garethr-docker
    sudo puppet module install puppetlabs-git
    sudo puppet module install puppetlabs-vcsrepo
    sudo puppet module install garystafford-fig

    # symlink manifest from Vagrant synced folder location
    sudo mkdir /etc/puppet/manifests
    ln -s /tmp/vagrant/site.pp /etc/puppet/manifests/site.pp
fi
