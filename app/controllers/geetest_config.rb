class GeetestConfig
  GEETEST_ID = "c9c4facd1a6feeb80802222cbb74ca8e".freeze
  GEETEST_KEY = "e4e298788aa8c768397639deb9b249a9".freeze
  REDIS_HOST = "127.0.0.1".freeze  # 对bypass状态进行缓存的redis服务host
  REDIS_PORT = "6379".freeze  # 对bypass状态进行缓存的redis服务port
  BYPASS_URL = "http://bypass.geetest.com/v1/bypass_status.php".freeze  # 向geetest发送获取bypass状态请求的url
	GEETEST_BYPASS_STATUS_KEY = "gt_server_bypass_status".freeze  # bypass状态存入redis时使用的key值
end
