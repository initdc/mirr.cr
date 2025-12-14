require "file_utils"
require "http/client"
require "./comm"
require "./debian_like"

module Mirr
  module Debian
    extend Mirr::Comm
    extend Mirr::DebianLike

    class NotFound < Exception; end

    class MoreThanOne < Exception; end

    class Cli
      @@debian_help = <<-HELP
      Usage: mirr debian <command>

      Example:
        mirr debian change CN

      Command:
        help                     Show this help message
        list                     print all debian mirror locations
        choose                   Asking to choose a server from tcping results
        fastest                  Use the fastest server from tcping results
        change [location]        Change source server to location mirror
        custom <url>             Use custom server with your url
        restore                  Restore sources.list from backup 
        default                  Recover with default sources.list
        enable-src               Enable deb-src
        disable-src              Disable deb-src
      HELP

      def self.run
        case ARGV[1]?
        when "help"
          puts @@debian_help
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
        when "restore"
          Mirr::Debian.restore_sources
        when "default"
          Mirr::Debian.default_conf
        when "enable-src"
          Mirr::Debian.enable_deb_src
        when "disable-src"
          Mirr::Debian.disable_deb_src
        else
          puts "Unknown command"
          puts @@debian_help
        end
      end
    end

    def self.country_servers
      {
        "AR" => [
          "http://debian.unnoba.edu.ar/debian/",
          "http://mirror.sitsa.com.ar/debian/",
        ],
        "AU" => [
          "http://ftp.au.debian.org/debian/",
          "http://mirror.aarnet.edu.au/debian/",
          "http://mirror.amaze.com.au/debian/",
          "http://mirror.gsl.icu/debian/",
          "http://mirror.linux.org.au/debian/",
          "http://mirror.overthewire.com.au/debian/",
          "http://mirror.realcompute.io/debian/",
        ],
        "AT" => [
          "http://ftp.at.debian.org/debian/",
          "http://debian.anexia.at/debian/",
          "http://debian.lagis.at/debian/",
          "http://debian.mur.at/debian/",
          "http://debian.sil.at/debian/",
          "http://mirror.alwyzon.net/debian/",
        ],
        "AZ" => [
          "http://mirror.ourhost.az/debian/",
        ],
        "BD" => [
          "http://mirror.limda.net/debian/",
          "http://mirror.xeonbd.com/debian/",
        ],
        "BY" => [
          "http://mirror.datacenter.by/debian/",
        ],
        "BE" => [
          "http://ftp.be.debian.org/debian/",
          "http://debian-mirror.behostings.net/debian/",
          "http://ftp.belnet.be/debian/",
          "http://mirror.as35701.net/debian/",
          "http://mirror.unix-solutions.be/debian/",
        ],
        "BR" => [
          "http://ftp.br.debian.org/debian/",
          "http://debian.c3sl.ufpr.br/debian/",
          "http://debian.pop-sc.rnp.br/debian/",
          "http://mirror.blue3.com.br/debian/",
          "http://mirrors.ic.unicamp.br/debian/",
          "http://mirror.uepg.br/debian/",
          "http://mirror.ufscar.br/debian/",
        ],
        "BG" => [
          "http://ftp.bg.debian.org/debian/",
          "http://debian.a1.bg/debian/",
          "http://debian.ipacct.com/debian/",
          "http://debian.ludost.net/debian/",
          "http://debian.mnet.bg/debian/",
          "http://debian.telecoms.bg/debian/",
          "http://ftp.uni-sofia.bg/debian/",
          "http://mirrors.netix.net/debian/",
          "http://mirror.telepoint.bg/debian/",
        ],
        "BF" => [
          "http://debian.ipsys.bf/debian/",
        ],
        "CA" => [
          "http://ftp.ca.debian.org/debian/",
          "http://debian.linux.n0c.ca/debian/",
          "http://debian.mirror.globo.tech/debian/",
          "http://debian.mirror.rafal.ca/debian/",
          "http://mirror.cpsc.ucalgary.ca/debian/",
          "http://mirror.csclub.uwaterloo.ca/debian/",
          "http://mirror.dst.ca/debian/",
          "http://mirror.estone.ca/debian/",
          "http://mirror.it.ubc.ca/debian/",
        ],
        "CL" => [
          "http://ftp.cl.debian.org/debian/",
          "http://debian-mirror.puq.apoapsis.cl/debian/",
          "http://mirror.hnd.cl/debian/",
          "http://mirror.insacom.cl/debian/",
        ],
        "CN" => [
          "http://ftp.cn.debian.org/debian/",
          "http://mirror.lzu.edu.cn/debian/",
          "http://mirror.nju.edu.cn/debian/",
          "http://mirror.nyist.edu.cn/debian/",
          "http://mirrors.bfsu.edu.cn/debian/",
          "http://mirrors.hit.edu.cn/debian/",
          "http://mirrors.jlu.edu.cn/debian/",
          "http://mirror.sjtu.edu.cn/debian/",
          "http://mirrors.tuna.tsinghua.edu.cn/debian/",
          "http://mirrors.ustc.edu.cn/debian/",
          "http://mirrors.zju.edu.cn/debian/",
        ],
        "CR" => [
          "http://mirrors.ucr.ac.cr/debian/",
        ],
        "HR" => [
          "http://ftp.hr.debian.org/debian/",
          "http://debian.carnet.hr/debian/",
          "http://debian.iskon.hr/debian/",
        ],
        "CZ" => [
          "http://ftp.cz.debian.org/debian/",
          "http://debian.mirror.web4u.cz/",
          "http://debian.nic.cz/debian/",
          "http://debian.superhosting.cz/debian/",
          "http://ftp.cvut.cz/debian/",
          "http://ftp.debian.cz/debian/",
          "http://ftp.sh.cvut.cz/debian/",
          "http://ftp.zcu.cz/debian/",
          "http://merlin.fit.vutbr.cz/debian/",
          "http://mirror.dkm.cz/debian/",
        ],
        "DK" => [
          "http://ftp.dk.debian.org/debian/",
          "http://mirrors.dotsrc.org/debian/",
          "http://mirrors.rackhosting.com/debian/",
        ],
        "EE" => [
          "http://mirrors.xtom.ee/debian/",
        ],
        "FI" => [
          "http://ftp.fi.debian.org/debian/",
          "http://debian.web.trex.fi/debian/",
          "http://mirror.5i.fi/debian/",
          "http://www.nic.funet.fi/debian/",
        ],
        "FR" => [
          "http://ftp.fr.debian.org/debian/",
          "http://apt.tetaneutral.net/debian/",
          "http://debian.apt-mirror.de/debian/",
          "http://debian.mirrors.ovh.net/debian/",
          "http://debian.obspm.fr/debian/",
          "http://debian.polytech-lille.fr/debian/",
          "http://debian.proxad.net/debian/",
          "http://debian.univ-tlse2.fr/debian/",
          "http://deb-mir1.naitways.net/debian/",
          "http://ftp.ec-m.fr/debian/",
          "http://ftp.lip6.fr/pub/linux/distributions/debian/",
          "http://ftp.rezopole.net/debian/",
          "http://ftp.univ-pau.fr/linux/mirrors/debian/",
          "http://ftp.u-picardie.fr/debian/",
          "http://ftp.u-strasbg.fr/debian/",
          "http://miroir.univ-lorraine.fr/debian/",
          "http://mirror.abaclouda.net/debian/",
          "http://mirror.debian.ikoula.com/debian/",
          "http://mirror.gitoyen.net/debian/",
          "http://mirror.ibcp.fr/debian/",
          "http://mirror.johnnybegood.fr/debian/",
          "http://mirror.plusserver.com/debian/debian/",
        ],
        "GE" => [
          "http://debian.grena.ge/debian/",
        ],
        "DE" => [
          "http://ftp2.de.debian.org/debian/",
          "http://ftp.de.debian.org/debian/",
          "http://debian.charite.de/debian/",
          "http://debian.inf.tu-dresden.de/debian/",
          "http://debian.intergenia.de/debian/",
          "http://debian.mirror.iphh.net/debian/",
          "http://debian.mirror.lrz.de/debian/",
          "http://debian.netcologne.de/debian/",
          "http://debian.tu-bs.de/debian/",
          "http://de.mirrors.clouvider.net/debian/",
          "http://ftp.fau.de/debian/",
          "http://ftp.gwdg.de/debian/",
          "http://ftp.halifax.rwth-aachen.de/debian/",
          "http://ftp.hosteurope.de/mirror/ftp.debian.org/debian/",
          "http://ftp-stud.hs-esslingen.de/debian/",
          "http://ftp.stw-bonn.de/debian/",
          "http://ftp.tu-chemnitz.de/debian/",
          "http://ftp.uni-hannover.de/debian/debian/",
          "http://ftp.uni-kl.de/debian/",
          "http://ftp.uni-mainz.de/debian/",
          "http://ftp.uni-stuttgart.de/debian/",
          "http://ftp.wrz.de/debian/",
          "http://mirror.23m.com/debian/",
          "http://mirror.creoline.net/debian/",
          "http://mirror.de.leaseweb.net/debian/",
          "http://mirror.dogado.de/debian/",
          "http://mirror.eu.oneandone.net/debian/",
          "http://mirror.informatik.tu-freiberg.de/debian/",
          "http://mirror.ipb.de/debian/",
          "http://mirror.netzwerge.de/debian/",
          "http://mirror.plusline.net/debian/",
          "http://mirrors.xtom.de/debian/",
          "http://mirror.united-gameserver.de/debian/",
          "http://mirror.wtnet.de/debian/",
          "http://packages.hs-regensburg.de/debian/",
          "http://pubmirror.plutex.de/debian/",
        ],
        "GR" => [
          "http://debian.otenet.gr/debian/",
        ],
        "HK" => [
          "http://ftp.hk.debian.org/debian/",
          "http://mirror.xtom.com.hk/debian/",
        ],
        "HU" => [
          "http://ftp.bme.hu/debian/",
          "http://repo.jztkft.hu/debian/",
        ],
        "IS" => [
          "http://ftp.is.debian.org/debian/",
        ],
        "IN" => [
          "http://mirror.nitc.ac.in/debian/",
        ],
        "ID" => [
          "http://kartolo.sby.datautama.net.id/debian/",
          "http://kebo.pens.ac.id/debian/",
          "http://mirror.unair.ac.id/debian/",
          "http://mr.heru.id/debian/",
        ],
        "IR" => [
          "http://archive.debian.petiak.ir/debian/",
          "http://mirror.aminidc.com/debian/",
          "http://mirrors.pardisco.co/debian/",
          "http://repo.mirror.famaserver.com/debian/",
        ],
        "IL" => [
          "http://debian.interhost.co.il/debian/",
        ],
        "IT" => [
          "http://ftp.it.debian.org/debian/",
          "http://debian.connesi.it/debian/",
          "http://debian.dynamica.it/debian/",
          "http://debian.mirror.garr.it/debian/",
          "http://ftp.linux.it/debian/",
          "http://giano.com.dist.unige.it/debian/",
          "http://mirror.units.it/debian/",
        ],
        "JP" => [
          "http://ftp.jp.debian.org/debian/",
          "http://debian-mirror.sakura.ne.jp/debian/",
          "http://dennou-k.gfd-dennou.org/debian/",
          "http://ftp.jaist.ac.jp/debian/",
          "http://ftp.nara.wide.ad.jp/debian/",
          "http://ftp.riken.jp/Linux/debian/debian/",
          "http://ftp.yz.yamagata-u.ac.jp/debian/",
          "http://mirrors.xtom.jp/debian/",
        ],
        "KZ" => [
          "http://mirror.hoster.kz/debian/",
          "http://mirror.ps.kz/debian/",
        ],
        "KE" => [
          "http://debian.mirror.ac.ke/debian/",
          "http://debian.mirror.liquidtelecom.com/debian/",
        ],
        "KR" => [
          "http://ftp.lanet.kr/debian/",
          "http://mirror.keiminem.com/debian/",
          "http://mirror.pangkin.com/debian/",
          "http://mirror.siwoo.org/debian/",
          "http://mirror.yuki.net.uk/debian/",
        ],
        "LV" => [
          "http://debian.koyanet.lv/debian/",
          "http://mirror.cloudhosting.lv/debian/",
          "http://mirror.veesp.com/debian/",
        ],
        "LT" => [
          "http://ftp.lt.debian.org/debian/",
          "http://debian.balt.net/debian/",
          "http://debian.mirror.vu.lt/debian/",
          "http://mirror.litnet.lt/debian/",
        ],
        "LU" => [
          "http://debian.mirror.root.lu/debian/",
        ],
        "MK" => [
          "http://mirror.a1.mk/debian/",
          "http://mirror-mk.interspace.com/debian/",
        ],
        "MX" => [
          "http://debian.vranetworks.lat/debian/",
          "http://lidsol.fi-b.unam.mx/debian/",
        ],
        "MA" => [
          "http://mirror.marwan.ma/debian/",
        ],
        "NP" => [
          "http://mirrors.nepalicloud.com/debian/",
        ],
        "NL" => [
          "http://ftp.nl.debian.org/debian/",
          "http://debian.snt.utwente.nl/debian/",
          "http://mirror.ams.macarne.com/debian/",
          "http://mirror.bgp.rodeo/debian/",
          "http://mirror.duocast.net/debian/",
          "http://mirror.nforce.com/debian/",
          "http://mirror.nl.cdn-perfprod.com/debian/",
          "http://mirror.nl.datapacket.com/debian/",
          "http://mirror.nl.leaseweb.net/debian/",
          "http://mirrors.hostiserver.com/debian/",
          "http://mirrors.xtom.nl/debian/",
          "http://mirror.tngnet.com/debian/",
          "http://mirror.vpgrp.io/debian/",
          "http://nl.mirror.flokinet.net/debian/",
          "http://nl.mirrors.clouvider.net/debian/",
        ],
        "NC" => [
          "http://ftp.nc.debian.org/debian/",
          "http://debian.nautile.nc/debian/",
          "http://mirror.lagoon.nc/debian/",
        ],
        "NZ" => [
          "http://ftp.nz.debian.org/debian/",
          "http://mirror.fsmg.org.nz/debian/",
        ],
        "NO" => [
          "http://ftp.no.debian.org/debian/",
          "http://ftp.uio.no/debian/",
        ],
        "PL" => [
          "http://ftp.pl.debian.org/debian/",
          "http://ftp.agh.edu.pl/debian/",
          "http://ftp.icm.edu.pl/pub/Linux/debian/",
          "http://ftp.psnc.pl/debian/",
          "http://ftp.task.gda.pl/debian/",
        ],
        "PT" => [
          "http://ftp.pt.debian.org/debian/",
          "http://debian.uevora.pt/debian/",
          "http://ftp.eq.uc.pt/software/Linux/debian/",
          "http://ftp.rnl.tecnico.ulisboa.pt/pub/debian/",
          "http://mirrors.up.pt/debian/",
        ],
        "PR" => [
          "http://mirrors.upr.edu/debian/",
        ],
        "RE" => [
          "http://debian.mithril.re/debian/",
          "http://depot-debian.univ-reunion.fr/debian/",
        ],
        "RO" => [
          "http://mirror.flo.c-f.ro/debian/",
          "http://mirror.linux.ro/debian/",
          "http://mirrors.hosterion.ro/debian/",
          "http://mirrors.hostico.ro/debian/",
          "http://mirrors.nav.ro/debian/",
          "http://mirrors.nxthost.com/debian/",
          "http://mirrors.pidginhost.com/debian/",
          "http://ro.mirror.flokinet.net/debian/",
        ],
        "RU" => [
          "http://ftp.ru.debian.org/debian/",
          "http://ftp.psn.ru/debian/",
          "http://mirror.corbina.net/debian/",
          "http://mirror.docker.ru/debian/",
          "http://mirror.hyperdedic.ru/debian/",
          "http://mirror.mephi.ru/debian/",
          "http://mirror.neftm.ru/debian/",
          "http://mirrors.powernet.com.ru/debian/",
          "http://mirror.truenetwork.ru/debian/",
          "http://repository.su/debian/",
        ],
        "SA" => [
          "http://mirror.maeen.sa/debian/",
        ],
        "RS" => [
          "http://mirror.pmf.kg.ac.rs/debian/",
        ],
        "SG" => [
          "http://mirror.coganng.com/debian/",
          "http://mirror.djvg.sg/debian/",
          "http://mirror.sg.gs/debian/",
        ],
        "SK" => [
          "http://ftp.sk.debian.org/debian/",
          "http://deb.bbxnet.sk/debian/",
          "http://ftp.antik.sk/debian/",
          "http://ftp.debian.sk/debian/",
        ],
        "SI" => [
          "http://ftp.si.debian.org/debian/",
        ],
        "ZA" => [
          "http://debian.envisagecloud.net.za/debian/",
          "http://debian.saix.net/",
          "http://ftp.is.co.za/debian/",
        ],
        "ES" => [
          "http://ftp.es.debian.org/debian/",
          "http://debian.grn.cat/debian/",
          "http://debian.redimadrid.es/debian/",
          "http://debian.redparra.com/debian/",
          "http://ftp.cica.es/debian/",
          "http://ftp.udc.es/debian/",
          "http://mirror.raiolanetworks.com/debian/",
          "http://repo.ifca.es/debian/",
          "http://softlibre.unizar.es/debian/",
          "http://ulises.hostalia.com/debian/",
        ],
        "SE" => [
          "http://ftp.se.debian.org/debian/",
          "http://debian.lth.se/debian/",
          "http://ftp.acc.umu.se/debian/",
          "http://ftp.ludd.ltu.se/debian/",
          "http://ftpmirror1.infania.net/debian/",
          "http://mirror.braindrainlan.nu/debian/",
          "http://mirrors.glesys.net/debian/",
        ],
        "CH" => [
          "http://ftp.ch.debian.org/debian/",
          "http://debian.ethz.ch/debian/",
          "http://deb.nextgen.ch/debian/",
          "http://linuxsoft.cern.ch/debian/",
          "http://mirror1.infomaniak.com/debian/",
          "http://mirror2.infomaniak.com/debian/",
          "http://mirror.init7.net/debian/",
          "http://mirror.iway.ch/debian/",
          "http://mirror.metanet.ch/debian/",
          "http://mirror.sinavps.ch/debian/",
          "http://pkg.adfinis-on-exoscale.ch/debian/",
        ],
        "TW" => [
          "http://ftp.tw.debian.org/debian/",
          "http://debian.ccns.ncku.edu.tw/debian/",
          "http://debian.csie.ntu.edu.tw/debian/",
          "http://debian.cs.nycu.edu.tw/debian/",
          "http://ftp.tku.edu.tw/debian/",
          "http://mirror.twds.com.tw/debian/",
          "http://opensource.nchc.org.tw/debian/",
          "http://tw1.mirror.blendbyte.net/debian/",
        ],
        "TH" => [
          "http://ftp.debianclub.org/debian/",
          "http://mirror.applebred.net/debian/",
          "http://mirror.kku.ac.th/debian/",
        ],
        "UA" => [
          "http://debian.netforce.hosting/debian/",
          "http://debian.volia.net/debian/",
          "http://mirror.mirohost.net/debian/",
          "http://mirror.ukrnames.com/debian/",
        ],
        "GB" => [
          "http://ftp.uk.debian.org/debian/",
          "http://debian.mirrors.uk2.net/debian/",
          "http://debian.mirror.uk.sargasso.net/debian/",
          "http://free.hands.com/debian/",
          "http://ftp.ticklers.org/debian/",
          "http://mirror.cov.ukservers.com/debian/",
          "http://mirror.lchost.net/debian/",
          "http://mirror.mythic-beasts.com/debian/",
          "http://mirror.ox.ac.uk/debian/",
          "http://mirror.positive-internet.com/debian/",
          "http://mirrors.coreix.net/debian/",
          "http://mirrorservice.org/sites/ftp.debian.org/debian/",
          "http://mirror.vinehost.net/debian/",
          "http://ukdebian.mirror.anlx.net/debian/",
          "http://uk.mirrors.clouvider.net/debian/",
        ],
        "US" => [
          "http://ftp.us.debian.org/debian/",
          "http://atl.mirrors.clouvider.net/debian/",
          "http://debian-archive.trafficmanager.net/debian/",
          "http://debian.cc.lehigh.edu/debian/",
          "http://debian.csail.mit.edu/debian/",
          "http://debian.mirror.constant.com/debian/",
          "http://debian.osuosl.org/debian/",
          "http://debian.uchicago.edu/debian/",
          "http://la.mirrors.clouvider.net/debian/",
          "http://lethe.chinstrap.org/debian/",
          "http://mirror.0x626b.com/debian/",
          "http://mirror.keystealth.org/debian/",
          "http://mirrors.accretive-networks.net/debian/",
          "http://mirrors.bloomu.edu/debian/",
          "http://mirror.siena.edu/debian/",
          "http://mirrors.iu13.net/debian/",
          "http://mirrors.lug.mtu.edu/debian/",
          "http://mirrors.ocf.berkeley.edu/debian/",
          "http://mirrors.vcea.wsu.edu/debian/",
          "http://mirrors.wikimedia.org/debian/",
          "http://mirrors.xtom.com/debian/",
          "http://mirror.us.leaseweb.net/debian/",
          "http://mirror.us.mirhosting.net/debian/",
          "http://mirror.us.oneandone.net/debian/",
          "http://nyc.mirrors.clouvider.net/debian/",
          "http://repo.ialab.dsu.edu/debian/",
        ],
        "UY" => [
          "http://debian.repo.cure.edu.uy/debian/",
        ],
        "VN" => [
          "http://debian.xtdv.net/debian/",
          "http://mirror.bizflycloud.vn/debian/",
        ],
        "CDN" => [
          "http://deb.debian.org/debian",
          "http://cdn-aws.deb.debian.org/debian/",
          "http://cdn-fastly.deb.debian.org/debian/",
          "http://cloudfront.debian.net/debian/",
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

      change_sources(server_url, "change_server_#{country}")
      puts "Change sources to country server #{server_url} successfully"
    end

    def self.default_server
      change_server("CDN")
    end

    def self.debian_codename
      os_release = "/etc/os-release"
      codename_match = File.read(os_release).match(/VERSION_CODENAME=(\w+)/)
      if codename_match
        codename_match[1]
      else
        raise NotFound.new("No codename found in #{os_release}")
      end
    end

    def self.default_conf
      codename = debian_codename
      conf = <<-EOF
      deb http://deb.debian.org/debian #{codename} main
      deb-src http://deb.debian.org/debian #{codename} main
      
      deb http://deb.debian.org/debian-security #{codename}-security main
      deb-src http://deb.debian.org/debian-security #{codename}-security main

      deb http://deb.debian.org/debian #{codename}-updates main
      deb-src http://deb.debian.org/debian #{codename}-updates main\n
      EOF

      File.write("/etc/apt/sources.list", conf)
      puts "Restore sources list to default successfully"
    end
  end
end

# Mirr::Debian.tcping_servers "CN"
