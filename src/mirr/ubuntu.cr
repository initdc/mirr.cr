require "file_utils"
require "http/client"

module Mirr
  module Ubuntu
    class NotFound < Exception; end

    class MoreThanOne < Exception; end

    def self.countries : Array(String)
      %w[
        AD.txt
        AE.txt
        AF.txt
        AG.txt
        AI.txt
        AL.txt
        AM.txt
        AN.txt
        AO.txt
        AQ.txt
        AR.txt
        AS.txt
        AT.txt
        AU.txt
        AW.txt
        AX.txt
        AZ.txt
        BA.txt
        BB.txt
        BD.txt
        BE.txt
        BF.txt
        BG.txt
        BH.txt
        BI.txt
        BJ.txt
        BL.txt
        BM.txt
        BN.txt
        BO.txt
        BQ.txt
        BR.txt
        BS.txt
        BT.txt
        BV.txt
        BW.txt
        BY.txt
        BZ.txt
        CA.txt
        CC.txt
        CD.txt
        CF.txt
        CG.txt
        CH.txt
        CI.txt
        CK.txt
        CL.txt
        CM.txt
        CN.txt
        CO.txt
        CR.txt
        CS.txt
        CU.txt
        CV.txt
        CW.txt
        CX.txt
        CY.txt
        CZ.txt
        DE.txt
        DJ.txt
        DK.txt
        DM.txt
        DO.txt
        DZ.txt
        EC.txt
        EE.txt
        EG.txt
        EH.txt
        ER.txt
        ES.txt
        ET.txt
        FI.txt
        FJ.txt
        FK.txt
        FM.txt
        FO.txt
        FR.txt
        GA.txt
        GB.txt
        GD.txt
        GE.txt
        GF.txt
        GG.txt
        GH.txt
        GI.txt
        GL.txt
        GM.txt
        GN.txt
        GP.txt
        GQ.txt
        GR.txt
        GS.txt
        GT.txt
        GU.txt
        GW.txt
        GY.txt
        HK.txt
        HM.txt
        HN.txt
        HR.txt
        HT.txt
        HU.txt
        ID.txt
        IE.txt
        IL.txt
        IM.txt
        IN.txt
        IO.txt
        IQ.txt
        IR.txt
        IS.txt
        IT.txt
        JE.txt
        JM.txt
        JO.txt
        JP.txt
        KE.txt
        KG.txt
        KH.txt
        KI.txt
        KM.txt
        KN.txt
        KP.txt
        KR.txt
        KW.txt
        KY.txt
        KZ.txt
        LA.txt
        LB.txt
        LC.txt
        LI.txt
        LK.txt
        LR.txt
        LS.txt
        LT.txt
        LU.txt
        LV.txt
        LY.txt
        MA.txt
        MC.txt
        MD.txt
        ME.txt
        MF.txt
        MG.txt
        MH.txt
        MK.txt
        ML.txt
        MM.txt
        MN.txt
        MO.txt
        MP.txt
        MQ.txt
        MR.txt
        MS.txt
        MT.txt
        MU.txt
        MV.txt
        MW.txt
        MX.txt
        MY.txt
        MZ.txt
        NA.txt
        NC.txt
        NE.txt
        NF.txt
        NG.txt
        NI.txt
        NL.txt
        NO.txt
        NP.txt
        NR.txt
        NU.txt
        NZ.txt
        OM.txt
        PA.txt
        PE.txt
        PF.txt
        PG.txt
        PH.txt
        PK.txt
        PL.txt
        PM.txt
        PN.txt
        PR.txt
        PS.txt
        PT.txt
        PW.txt
        PY.txt
        QA.txt
        RE.txt
        RO.txt
        RS.txt
        RU.txt
        RW.txt
        SA.txt
        SB.txt
        SC.txt
        SD.txt
        SE.txt
        SG.txt
        SH.txt
        SI.txt
        SJ.txt
        SK.txt
        SL.txt
        SM.txt
        SN.txt
        SO.txt
        SR.txt
        SS.txt
        ST.txt
        SV.txt
        SX.txt
        SY.txt
        SZ.txt
        TC.txt
        TD.txt
        TF.txt
        TG.txt
        TH.txt
        TJ.txt
        TK.txt
        TL.txt
        TM.txt
        TN.txt
        TO.txt
        TR.txt
        TT.txt
        TV.txt
        TW.txt
        TZ.txt
        UA.txt
        UG.txt
        UM.txt
        US.txt
        UY.txt
        UZ.txt
        VA.txt
        VC.txt
        VE.txt
        VG.txt
        VI.txt
        VN.txt
        VU.txt
        WF.txt
        WS.txt
        XK.txt
        YE.txt
        YT.txt
        ZA.txt
        ZM.txt
        ZW.txt
        mirrors.txt
      ]
    end

    def self.select_country(pattern : String) : String
      arr = countries.select(&.includes?(pattern))

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

    def self.print_countries(items : Array(String) = countries)
      items.each_with_index do |item, i|
        print "#{item.chomp(".txt")}  "
        if (i + 1) % 20 == 0
          puts
        end
      end
      puts
    end

    def self.print_list(items : Array(String))
      items.each do |item|
        puts "  - " + item
      end
    end

    def self.mirror_protocol(pattern : String)
      country = select_country(pattern)
      mirr_url = "mirror://mirrors.ubuntu.com/#{country}"

      country_code = country.chomp(".txt")
      if country == "mirrors"
        country_code = "default"
      end

      change_sources(mirr_url, "change_mirror_#{country_code}")
      puts "Change sources to mirror protocol #{mirr_url} successfully"
    end

    def self.get_servers(url : String) : Array(String)
      lines = [] of String

      response = HTTP::Client.get(url)
      if response.status_code == 200
        response.body.each_line do |line|
          lines << line
        end
      end
      return lines
    end

    def self.print_country_servers(pattern : String)
      country = select_country(pattern)
      url = "http://mirrors.ubuntu.com/#{country}"
      puts "Country servers list: #{url}"

      servers = get_servers(url)
      print_list(servers)
    end

    def self.tcping_servers(pattern : String)
      country = select_country(pattern)
      url = "http://mirrors.ubuntu.com/#{country}"
      servers = get_servers(url)

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

    def self.tcping(url)
      response : HTTP::Client::Response

      code = 0
      elapsed_time = Time.measure do
        response = HTTP::Client.get(url)
        code = response.status_code
      end
      if code == 200
        elapsed_time.total_milliseconds
      else
        9999.99
      end
    end

    def self.change_server(pattern : String)
      country = select_country(pattern)
      server = country.chomp(".txt").downcase
      server_url = "http://#{server}.archive.ubuntu.com/ubuntu/"

      if country == "mirrors.txt"
        server = "default"
        server_url = "http://archive.ubuntu.com/ubuntu/"
      end

      change_sources(server_url, "change_server_#{server}")
      puts "Change sources to country server #{server_url} successfully"
    end

    def self.default_server
      change_server("mirrors")
    end

    def self.ubuntu_codename
      os_release = "/etc/os-release"
      codename_match = File.read(os_release).match(/UBUNTU_CODENAME=(\w+)/)
      if codename_match
        codename_match[1]
      else
        raise NotFound.new("No codename found in #{os_release}")
      end
    end

    def self.default_conf
      codename = ubuntu_codename
      conf = <<-EOF
      # See http://help.ubuntu.com/community/UpgradeNotes for how to upgrade to
      # newer versions of the distribution.
      deb http://archive.ubuntu.com/ubuntu/ #{codename} main restricted
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename} main restricted

      ## Major bug fix updates produced after the final release of the
      ## distribution.
      deb http://archive.ubuntu.com/ubuntu/ #{codename}-updates main restricted
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-updates main restricted

      ## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
      ## team. Also, please note that software in universe WILL NOT receive any
      ## review or updates from the Ubuntu security team.
      deb http://archive.ubuntu.com/ubuntu/ #{codename} universe
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename} universe
      deb http://archive.ubuntu.com/ubuntu/ #{codename}-updates universe
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-updates universe

      ## N.B. software from this repository is ENTIRELY UNSUPPORTED by the Ubuntu
      ## team, and may not be under a free licence. Please satisfy yourself as to
      ## your rights to use the software. Also, please note that software in
      ## multiverse WILL NOT receive any review or updates from the Ubuntu
      ## security team.
      deb http://archive.ubuntu.com/ubuntu/ #{codename} multiverse
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename} multiverse
      deb http://archive.ubuntu.com/ubuntu/ #{codename}-updates multiverse
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-updates multiverse

      ## N.B. software from this repository may not have been tested as
      ## extensively as that contained in the main release, although it includes
      ## newer versions of some applications which may provide useful features.
      ## Also, please note that software in backports WILL NOT receive any review
      ## or updates from the Ubuntu security team.
      deb http://archive.ubuntu.com/ubuntu/ #{codename}-backports main restricted universe multiverse
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-backports main restricted universe multiverse

      deb http://archive.ubuntu.com/ubuntu/ #{codename}-security main restricted
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-security main restricted
      deb http://archive.ubuntu.com/ubuntu/ #{codename}-security universe
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-security universe
      deb http://archive.ubuntu.com/ubuntu/ #{codename}-security multiverse
      deb-src http://archive.ubuntu.com/ubuntu/ #{codename}-security multiverse\n
      EOF

      File.write("/etc/apt/sources.list", conf)
      puts "Restore sources list to default successfully"
    end

    def self.change_custom(text : String)
      change_sources(text, "change_custom")
      puts "Change sources to custom #{text} successfully"
    end

    def self.change_sources(text : String, event : String)
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

    def self.restore_sources
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

    def self.backup(file : String, event : String)
      time = Time.local.to_s("%Y%m%d_%H:%M:%S")
      backup_file = file + ".mirr_backup_#{time}_before_#{event}"
      FileUtils.cp(file, backup_file)

      puts "Backup #{file} to #{backup_file} successfully"
    end

    def self.enable_deb_src
      file = "/etc/apt/sources.list"
      content = File.read(file)
      File.write(file, content.gsub("\n# deb-src ", "\ndeb-src "))

      puts "Enable deb-src successfully"
    end

    def self.disable_deb_src
      file = "/etc/apt/sources.list"
      content = File.read(file)
      File.write(file, content.gsub("\ndeb-src ", "\n# deb-src "))

      puts "Disable deb-src successfully"
    end
  end
end

# Mirr::Ubuntu.print_countries
# Mirr::Ubuntu.change_server "CN"
# Mirr::Ubuntu.enable_deb_src
# Mirr::Ubuntu.default_server
# Mirr::Ubuntu.default_conf
# Mirr::Ubuntu.change_custom "http://mirrors.aliyun.com/ubuntu/"
# Mirr::Ubuntu.choose_server "AD"
