require "./mirr/comm"
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
            time = Mirr::Comm.tcping(url)
            puts sprintf("%7.3fms - %s", time, url)
          end
        else
          puts "Please enter a url"
        end
      when "ubuntu"
        Mirr::Ubuntu::Cli.run
      else
        puts "Unknown command"
        puts @@main_help
      end
    end
  end
end

Mirr::Cli.run
