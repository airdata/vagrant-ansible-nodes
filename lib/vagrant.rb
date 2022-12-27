# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
###############################################################################
# Plugin settings                                                             #
###############################################################################
required_plugins = %w( vagrant-hosts vagrant-cachier )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

def check_plugins(required_plugins)
  required_plugins.each do |plugin_name|
    unless Vagrant.has_plugin?(plugin_name)
      puts '---------- WARNING ----------'
      puts 'Please install vagrant plugin'
      puts 'with the following command:'
      puts "# vagrant plugin install #{plugin_name}"
      puts '------------ END ------------'
      exit 0
    end
  end
end

def vagrant_config(work_dir)
  @options = {}
  conf_files = Dir.glob("#{work_dir}/conf/*.yaml")
  conf_files.each do |f|
    @options.merge!(YAML.load_file(f))
  end
  @options
end

def generate_ssh_keys(ssh_keys_dir, key_name)
  unless File.file?(File.join(ssh_keys_dir, key_name))
    system("ssh-keygen -f #{File.join(ssh_keys_dir, key_name)} -q -N '' -t rsa -C 'vagrant@control-node'")
    FileUtils.chmod(0600, File.join(ssh_keys_dir, "#{key_name}.pub"))
    FileUtils.chmod(0600, File.join(ssh_keys_dir, "#{key_name}"))
  end
end

def extract_worker_nodes(nodes_array)
  workers = []
  nodes_array.each do |node|
    workers << node['name'] if node['name'] =~ /(\w+)-\d/
  end
  workers
end
