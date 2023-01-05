# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
##############################################################
#             Plugin settings                                #
##############################################################

required_plugins = [
  {:name => "vagrant-hosts", :version => "2.9.0"},
#  {:name => "vagrant-vbguest", :version => "0.21"},
  {:name => "vagrant-cachier", :version => "1.2.1"}
]

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin?(plugin[:name], plugin[:version]) }
if not plugins_to_install.empty?
  plugins_to_install.each { |plugin_to_install|
    puts "Installing plugin: #{plugin_to_install[:name]}, version #{plugin_to_install[:version]}"
    if system "vagrant plugin install #{plugin_to_install[:name]} --plugin-version \"#{plugin_to_install[:version]}\""
    else
      abort "Installation of one or more plugins has failed. Aborting."
    end
  }
  exec "vagrant #{ARGV.join(' ')}"
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
