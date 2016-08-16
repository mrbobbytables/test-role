require 'deep_merge'
require 'serverspec'
require 'net/ssh'
require 'yaml'
require 'yarjuf'

def merge_vars(vars, hash, behaviour)
  if hash.is_a?(Hash)
    if behaviour.casecmp('merge')
      vars.deep_merge!(hash)
    else
      vars.merge!(hash)
    end
  end
  vars
end

set :backend, :ssh

options = Net::SSH::Config.for(host)
options[:host_name] = ENV['KITCHEN_HOSTNAME']
options[:user]      = ENV['KITCHEN_USERNAME']
options[:port]      = ENV['KITCHEN_PORT']
options[:keys]      = ENV['KITCHEN_SSH_KEY']
options[:paranoid]  = false

set :host,        options[:host_name]
set :request_pty, true
set :ssh_options, options
set :env, LANG: 'C', LC_ALL: 'C'

RSpec.configure do |c|
  c.failure_exit_code = ENV['RSPEC_FAILURE_EXIT_CODE'] || 1
  if ENV['RSPEC_FORMATTER']
    if ENV['RSPEC_FORMATTER'].casecmp('junit').zero?
      c.output_stream = File.open("#{ENV['KITCHEN_INSTANCE']}.junit.xml", 'w')
      c.add_formatter('JUnit')
    else
      c.add_formatter(ENV['RSPEC_FORMATTER'])
    end
  end
end

if ENV['PLAYBOOK']
  playbook = YAML.load_file(ENV['PLAYBOOK'].to_str)
  role_defaults = YAML.load_file('defaults/main.yml')
  role_vars = YAML.load_file('vars/main.yml')
  hash_behaviour = ENV['HASH_BEHAVIOUR'] || 'replace'
  vars = {}
  vars = merge_vars(vars, role_defaults, hash_behaviour)
  playbook.each do |play|
    play.key?('vars') && (vars = merge_vars(vars, play['vars'], hash_behaviour))
  end
  vars = merge_vars(vars, role_vars, hash_behaviour)
  set_property vars
end
