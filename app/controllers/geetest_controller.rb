require 'redis'
require_relative 'geetest_config'
require_relative 'sdk/geetest_lib'

class GeetestController < ApplicationController

  protect_from_forgery except: ["second_validate"] # 跳过CSRF校验

  def get_bypass_cache
    bypass_cache = "fail"
    redis_key = GeetestConfig::GEETEST_BYPASS_STATUS_KEY
    redis = Redis.new(:host => GeetestConfig::REDIS_HOST, :port => GeetestConfig::REDIS_PORT)
    redis_bypass_cache = redis.get(redis_key)
    if redis_bypass_cache == "success"
      bypass_cache = "success"
    end
    return bypass_cache
  end

  # 验证初始化接口，GET请求
  def first_register
    # 必传参数
    #     digestmod 此版本sdk可支持md5、sha256、hmac-sha256，md5之外的算法需特殊配置的账号，联系极验客服
    # 自定义参数,可选择添加
    #     user_id 客户端用户的唯一标识，确定用户的唯一性；作用于提供进阶数据分析服务，可在register和validate接口传入，不传入也不影响验证服务的使用；若担心用户信息风险，可作预处理(如哈希处理)再提供到极验
    #     client_type 客户端类型，web：电脑上的浏览器；h5：手机上的浏览器，包括移动应用内完全内置的web_view；native：通过原生sdk植入app应用的方式；unknown：未知
    #     ip_address 客户端请求sdk服务器的ip地址
    gt_lib = GeetestLib.new(GeetestConfig::GEETEST_ID, GeetestConfig::GEETEST_KEY)
    digestmod = "md5"
    user_id = "test"
    paramHash = {"digestmod" => digestmod, "user_id" => user_id, "client_type" => "web", "ip_address" => "127.0.0.1"}
    bypass_cache = get_bypass_cache()
    if bypass_cache == "success"
      result = gt_lib.register(digestmod, paramHash)
    else
      result = gt_lib.localregister()
    end
    # 注意，不要更改返回的结构和值类型
    render :json => result.getData
  end

  # 二次验证接口，POST请求
  def second_validate
    gt_lib = GeetestLib.new(GeetestConfig::GEETEST_ID, GeetestConfig::GEETEST_KEY)
    challenge = params[GeetestLib::GEETEST_CHALLENGE]
    validate = params[GeetestLib::GEETEST_VALIDATE]
    seccode = params[GeetestLib::GEETEST_SECCODE]
    bypass_cache = get_bypass_cache()
    if bypass_cache == "success"
      result = gt_lib.successValidate(challenge, validate, seccode)
    else
      result = gt_lib.failValidate(challenge, validate, seccode)
    end
    # 注意，不要更改返回的结构和值类型
    if result.getStatus == 1
      response = {"result" => "success", "version" => GeetestLib::VERSION}
    else
      response = {"result" => "fail", "version" => GeetestLib::VERSION, "msg" => result.getMsg}
    end
    render :json => response
  end

end
