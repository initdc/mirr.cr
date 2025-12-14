require "./mirr/ubuntu"

module Mirr
  VERSION = "0.1.0"

  class Cli
    @@main_help = <<-HELP
    Usage: mirr <subcommand>
    Subcommand:
      help                     Show this help message
      version                  Show version
      tcping <url>             tcping url
      ubuntu                   Ubuntu mirrors
    HELP

    @@ubuntu_help = <<-HELP
    Usage: mirr ubuntu <command>

    Example:
      mirr ubuntu change CN

    Command:
      help                     Show this help message
      list                     print all ubuntu mirror locations
      choose                   Asking to choose a server from tcping results
      fastest                  Use the fastest server from tcping results
      change [location]        Change source server to location mirror
      mirror [location]        Use mirror:// protocol with your location
      custom <url>             Use custom server with your url
      restore                  Restore sources.list from backup 
      default                  Recover with default sources.list
      enable-src               Enable deb-src
      disable-src              Disable deb-src
    HELP

    def self.run
      case ARGV[0]?
      when "help"
        puts @@main_help
      when "version"
        puts Mirr::VERSION
      when "tcping"
        url = ARGV[1]?
        if url
          4.times do
            time = Mirr::Ubuntu.tcping(url)
            puts sprintf("%7.3fms - %s", time, url)
          end
        else
          puts "Please enter a url"
        end
      when "ubuntu"
        case ARGV[1]?
        when "help"
          puts @@ubuntu_help
        when "list"
          Mirr::Ubuntu.print_countries
        when "choose"
          location = ARGV[2]?
          if location
            Mirr::Ubuntu.choose_server(location)
          else
            puts "Please enter a location"
          end
        when "fastest"
          location = ARGV[2]?
          if location
            Mirr::Ubuntu.fastest_server(location)
          else
            puts "Please enter a location"
          end
        when "change"
          location = ARGV[2]?
          if location
            Mirr::Ubuntu.change_server(location)
          else
            puts "Please enter a location"
          end
        when "mirror"
          location = ARGV[2]?
          if location
            Mirr::Ubuntu.mirror_protocol(location)
          else
            puts "Please enter a location"
          end
        when "custom"
          location = ARGV[2]?
          if location
            Mirr::Ubuntu.change_custom(location)
          else
            puts "Please enter a location"
          end
        when "restore"
          Mirr::Ubuntu.restore_sources
        when "default"
          Mirr::Ubuntu.default_conf
        when "enable-src"
          Mirr::Ubuntu.enable_deb_src
        when "disable-src"
          Mirr::Ubuntu.disable_deb_src
        else
          puts "Unknown command"
          puts @@ubuntu_help
        end
      else
        puts "Unknown command"
        puts @@main_help
      end
    end
  end
end

Mirr::Cli.run
