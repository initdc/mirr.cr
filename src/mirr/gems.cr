require "file_utils"
require "http/client"
require "./comm"
require "./debian_like"

module Mirr
  module Debian
    extend Mirr::Comm

    class NotFound < Exception; end

    class MoreThanOne < Exception; end

    class Cli
      @@gems_help = <<-HELP
      Usage: mirr gems <command>

      Example:
        mirr gems change CN

      Command:
        help                     Show this help message
        list                     print all RubyGems mirror locations
        choose                   Asking to choose a server from tcping results
        fastest                  Use the fastest server from tcping results
        change [location]        Change source server to location mirror
        custom <url>             Use custom server with your url
        default                  Recover with default config
      HELP

      def self.run
        case ARGV[1]?
        when "help"
          puts @@gems_help
        when "list"
          Mirr::Debian.print_countries
        when "choose"
          location = ARGV[2]?
          if location
            Mirr::Debian.choose_server(location)
          else
            puts "Please enter a location"
          end
        when "fastest"
          location = ARGV[2]?
          if location
            Mirr::Debian.fastest_server(location)
          else
            puts "Please enter a location"
          end
        when "change"
          location = ARGV[2]?
          if location
            Mirr::Debian.change_server(location)
          else
            puts "Please enter a location"
          end
        when "custom"
          location = ARGV[2]?
          if location
            Mirr::Debian.change_custom(location)
          else
            puts "Please enter a location"
          end
        when "default"
          Mirr::Debian.default_conf
        else
          puts "Unknown command"
          puts @@gems_help
        end
      end
    end

    def self.country_servers
      {
        "CN" => [
          "https://mirrors.aliyun.com/rubygems/",
          "https://mirrors.cloud.tencent.com/rubygems/",
          "https://repo.huaweicloud.com/repository/rubygems/",
          "https://mirrors.tuna.tsinghua.edu.cn/rubygems/",
          "https://mirrors.ustc.edu.cn/rubygems/",
          "https://mirrors.bfsu.edu.cn/rubygems/",
          "https://mirror.nju.edu.cn/rubygems/",
          "https://mirrors.neusoft.edu.cn/rubygems",
          "https://mirror.nyist.edu.cn/rubygems",
        ],
      }
    end

    def self.select_country(pattern : String) : String
      arr = country_servers.keys.select(&.includes?(pattern))

      case arr.size
      when 1
        arr[0]
      when 0
        raise NotFound.new("No country matched pattern: #{pattern}")
      else
        print_countries(arr)
        raise MoreThanOne.new("Too many countries matched pattern: #{pattern}")
      end
    end

    def self.print_countries(items : Array(String) = country_servers.keys)
      items.each_with_index do |item, i|
        print "#{item}  "
        if (i + 1) % 20 == 0
          puts
        end
      end
      puts
    end

    def self.print_country_servers(pattern : String)
      country = select_country(pattern)
      servers = country_servers[country]
      print_list(servers)
    end

    def self.tcping_servers(pattern : String)
      country = select_country(pattern)
      servers = country_servers[country]

      results = servers.map do |server|
        puts "tcping #{server}"
        time = tcping(server)
        printf "\x1b[1A\x1b[K"

        {server: server, time: time}
      end

      results.sort_by! { |result| result[:time] }
      results.each_with_index do |result, i|
        puts sprintf("%3d | %7.2fms | %s", i, result[:time], result[:server])
      end
      return results
    end

    def self.fastest_server(pattern : String)
      server = tcping_servers(pattern)[0][:server]
      change_sources(server, "change_fastest")
      puts "Change sources to fastest #{server} successfully"
    end

    def self.choose_server(pattern : String)
      results = tcping_servers(pattern)

      print "Choose server: "
      input = gets
      if input
        server = results[input.to_i][:server]
        change_sources(server, "choose_server")
        puts "Choose sources to #{server} successfully"
      else
        puts "No server selected"
      end
    end

    def self.change_server(pattern : String)
      country = select_country(pattern)
      server_url = country_servers[country][0]
      system("gem sources --clear-all")
      system("gem sources --add #{server_url}")

      puts "Change sources to country server #{server_url} successfully"
    end

    def self.change_custom(url : String)
      system("gem sources --add #{url}")

      puts "Change sources to custom #{url} successfully"
    end

    def self.default_conf
      system("gem sources --clear-all")
      system("gem sources --add https://rubygems.org/")

      puts "Restore config to default successfully"
    end
  end
end

# Mirr::Debian.tcping_servers "CN"
