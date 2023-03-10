# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'lib/vagrant'

work_dir = File.dirname(File.expand_path(__FILE__))
ssh_keys_dir = "#{work_dir}/ssh"
shell_provisioning_dir = "#{work_dir}/provisioning/shell"
ansible_provisioning_dir = "#{work_dir}/provisioning/ansible"
vagrant_guest_home = "/home/vagrant"
destination_dir = "#{vagrant_guest_home}/.ssh"
opts = vagrant_config(work_dir)
check_plugins(opts['plugins'])
generate_ssh_keys(ssh_keys_dir, 'id_rsa')
pub_key = File.read(File.join(ssh_keys_dir, 'id_rsa.pub'))
nodes_array = opts['provider']['virtualbox']['nodes']
worker_nodes = extract_worker_nodes(nodes_array)

Vagrant.configure("2") do |config|
  # Plugin settings #
  config.cache.auto_detect = opts['cache']['auto_detect']
  config.cache.enable :yum
  config.ssh.insert_key = false
  config.vm.box_download_insecure = true

  #VirtualBox settings#
  nodes_array.each do |node|
    config.vm.define node['name'] do |cfg|
      cfg.vm.provider :virtualbox do |pr|
        pr.memory = node['mem']
        pr.cpus = opts['provider']['virtualbox']['vm']['cpu']
      end
    end
  end

  #VM definitions #
  nodes_array.each do |node|
    config.vm.define node['name'] do |cfg|
      cfg.vm.box = opts['provider']['virtualbox']['vm']['box']
      cfg.vm.hostname = node['hostname']
      cfg.vbguest.installer_hooks[:before_install] = ["yum install -y epel-release libX11 libXt libXext.x86_64 libXrender.x86_64 libXtst.x86_64 libXmu", "sleep 1"]
      cfg.vbguest.installer_options = { allow_kernel_upgrade: true }
      cfg.vbguest.auto_update = node['guest_auto_update']

      # Configure A Private Network IP and Ports
      cfg.vm.network opts['provider']['virtualbox']['vm']['net'].to_sym, ip: node['ip']
      cfg.vm.provision opts['provisioner'][0]['type'].to_sym, sync_hosts: opts['provisioner'][0]['sync_hosts']
      if node.fetch('external_access').fetch('enabled')
        cfg.vm.network :forwarded_port, host: node['host_port'], guest: node['guest_port']
      end
      # Install ansible and docker on the control host
      if node['name'] == 'control-node'
        cfg.vm.provision "file", source: "#{ansible_provisioning_dir}/install.yml", destination: "/tmp/install.yml"
        cfg.vm.provision opts['provisioner'][1]['type'].to_sym do |s|
          s.path = "#{shell_provisioning_dir}/control_node.sh"
          s.args = worker_nodes
        end
        # Run post install script on control node
        cfg.vm.provision opts['provisioner'][2]['type'].to_sym, source: ssh_keys_dir, destination: destination_dir
        cfg.vm.provision opts['provisioner'][1]['type'].to_sym do |s|
          s.path = "#{shell_provisioning_dir}/post_install.sh"
          s.args = worker_nodes
        end
      else
        # SSH key distribution on the workers
        cfg.vm.provision opts['provisioner'][1]['type'].to_sym do |s|
          s.path = "#{shell_provisioning_dir}/key_distribution.sh"
          s.args = [ pub_key ]
        end
      end
    end
  end
end
