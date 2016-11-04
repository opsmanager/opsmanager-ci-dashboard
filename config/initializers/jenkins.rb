module Jenkins
  def self.initialize
    @url_base = "http://opsci.opsmanager.com/"
    @auth_username = ENV["JENKINS_USER"]
    @auth_pwd = ENV["JENKINS_PWD"]
    @accept_pattern = '^opsmanager.*'
    @jobs_list = load_jobs
  end

  def self.get_auth
    [@auth_username, @auth_pwd]
  end

  def self.get_jobs_list
    @jobs_list
  end

  def self.load_jobs
    endpoint = 'api/json'
    jenkins_config = get_url @url_base+endpoint, get_auth
    all_jobs = jenkins_config['jobs']
    if @accept_pattern
      regex = Regexp.new @accept_pattern
      all_jobs = all_jobs.select {|job| job['name'].match regex }
    end
    all_jobs
  end

  def self.get_url(url, auth = nil)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.overify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    request = Net::HTTP::Get.new(uri.request_uri)

    if auth != nil then
      request.basic_auth *auth
    end

    response = http.request(request)
    return JSON.parse(response.body)
  end
end

Jenkins.initialize
