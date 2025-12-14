module Mirr
  module DebianLike
    class NotFound < Exception; end

    class MoreThanOne < Exception; end

    def change_custom(text : String)
      change_sources(text, "change_custom")
      puts "Change sources to custom #{text} successfully"
    end

    def change_sources(text : String, event : String)
      file = "/etc/apt/sources.list"
      content = File.read(file)

      new_content = String.new
      content.each_line do |line|
        if line.starts_with?("#")
          new_content += line
        else
          arr = line.split(" ")
          if arr[0].starts_with?("deb")
            arr[1] = text
            new_content += arr.join(" ")
          end
        end
        new_content += "\n"
      end

      backup(file, event)
      File.write(file, new_content)
    end

    def restore_sources
      backup_files = Dir.glob("/etc/apt/sources.list.mirr_backup_*")
      case backup_files.size
      when 1
        backup_file = backup_files[0]
        FileUtils.cp(backup_file, "/etc/apt/sources.list")

        puts "Restore sources list from #{backup_file} successfully"
      when 0
        raise NotFound.new("No backup file found")
      else
        puts("More than one backup files found")
        backup_files.sort!.each_with_index do |file, i|
          puts("  #{i}: #{file}")
        end
        print("Please specify the index of the backup file to restore: ")
        index = gets
        if index
          backup_file = backup_files[index.to_i]
          FileUtils.cp(backup_file, "/etc/apt/sources.list")

          puts "Restore sources list from #{backup_file} successfully"
        else
          raise IndexError.new("Invalid index")
        end
      end
    end

    def backup(file : String, event : String)
      time = Time.local.to_s("%Y%m%d_%H:%M:%S")
      backup_file = file + ".mirr_backup_#{time}_before_#{event}"
      FileUtils.cp(file, backup_file)

      puts "Backup #{file} to #{backup_file} successfully"
    end

    def enable_deb_src
      file = "/etc/apt/sources.list"
      content = File.read(file)
      File.write(file, content.gsub("\n# deb-src ", "\ndeb-src "))

      puts "Enable deb-src successfully"
    end

    def disable_deb_src
      file = "/etc/apt/sources.list"
      content = File.read(file)
      File.write(file, content.gsub("\ndeb-src ", "\n# deb-src "))

      puts "Disable deb-src successfully"
    end
  end
end
