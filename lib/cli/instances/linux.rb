# -*- coding: utf-8 -*-

require_relative 'base'

module DucttapeCLI
    
  class Linux < Base
    
    @type = 'linux'
    
    desc "add <name> <ip> <username> <password>","Add a new instance"
    def add(name, ip, username, password)
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = YAML.load_file('config.yml')
      if(config[name])
        puts "ERROR : instance with name '#{name}' already exists" 
        return
      end

      data = Struct::Data.new(ip, username, password)
      instance = Struct::Instance.new(@type, data)
      config[name] = instance
      File.open('config.yml','w') do |h| 
        h.write config.to_yaml      
      end
      puts config.inspect
      interface = Ducttape::Interfaces::Linux.new
      interface.setName(name)
      interface.setIpAddress(ip)
      interface.setUsername(username)
      interface.setPassword(password)
      p interface
    end
    
    desc "update <name>", "Update an instance"
    options :type => :string
    options :ip => :string
    options :username => :string
    options :password => :string
    def update(name)
      Struct.new("Data", :ip, :username, :password)
      Struct.new("Instance", :type, :data)
      config = YAML.load_file('config.yml')
      if(!config[name])
        puts "ERROR : instance with name '#{name}' doest not exist" 
        return
      end
      if (options[:ip])
        config[name]["data"]["ip"] = options[:ip]
      end
      if (options[:username])
        config[name]["data"]["username"] = options[:username]
      end
      if (options[:password])
        config[name]["data"]["password"] = options[:password]
      end
      File.open('config.yml','w') do |h| 
        h.write config.to_yaml      
      end
      puts config.inspect
    end
    
    
  end
end