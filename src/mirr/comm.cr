module Mirr
  module Comm
    extend self

    def print_list(items : Array(String))
      items.each do |item|
        puts "  - " + item
      end
    end

    def tcping(url)
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
  end
end
