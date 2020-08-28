require "net/http"
require "json"
require "redis"
require_relative '../../app/controllers/geetest_config'

def gtlog(msg)
    # if IS_DEBUG
      puts "gtlog: #{msg}"
    end
#   end

namespace :geetest_bypass do
    task :get_bypass_status => :environment do
        begin
            redis_key = GeetestConfig::GEETEST_BYPASS_STATUS_KEY
            redis = Redis.new(:host => GeetestConfig::REDIS_HOST, :port => GeetestConfig::REDIS_PORT)
            paramHash = {"gt" => GeetestConfig::GEETEST_ID}
            uri = URI(GeetestConfig::BYPASS_URL)
            uri.query = URI.encode_www_form(paramHash)
            res = Net::HTTP.start(uri.host, uri.port, open_timeout: 5, read_timeout: 5) do |http|
                req = Net::HTTP::Get.new(uri)
                http.request(req)
            end
            res_body = res.is_a?(Net::HTTPSuccess) ? res.body : ""
            if res_body == ""
                bypass_status = "fail"
            else
                res_hash = JSON.parse(res_body)
                status = res_hash["status"]
            end
            if status == "success"
                bypass_status = "success"
            else
                bypass_status = "fail"
            end
            redis.set(redis_key, bypass_status)
        rescue => e
            gtlog(e.message)
        end
    end
end