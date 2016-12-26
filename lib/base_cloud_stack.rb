require 'uri'
require 'openssl'
require 'base64'
require 'cgi'
require 'cgi/session'
require 'net/http'
require 'json'
require 'time'

class BaseCloudStack

  def initialize(url, apiKey: nil, secretKey: nil, username: nil, password: nil, domain: nil, jsessionid: nil, sessionkey: nil)
    @url = url

    unless (apiKey.nil? && secretKey.nil?)
      @apiKey = apiKey
      @secretKey = secretKey
    end

    unless (username.nil? && password.nil?)
      jsessionid, sessionkey, message = login(username: username, password: password)
    end

    unless (username.nil? && password.nil? && domain.nil?)
      jsessionid, sessionkey, message = login(username: username, password: password, domain: domain)
    end

    unless (jsessionid.nil? && sessionkey.nil?)
      @jsessionid = jsessionid
      @sessionkey = sessionkey
    end

  end

  def get_console_path(vmid)
    params = Hash.new
    params[:cmd] = 'access'
    params[:vm] = vmid
    params[:apikey] = @apiKey
    data = sort_params params
    #先頭の&を削除
    data.slice!(0)
    path = URI.parse(@url+'/client/console?'+encode_base64(data))

    return path
  end

  def get_request(params)
    params[:response] = 'json'

    #apikey , secretkeyでrequestする場合
    unless (@apiKey.nil? && @secretKey.nil?)
      params[:apikey] = @apiKey
      data = sort_params params
      data.slice!(0) #先頭の&を削除
      path = URI.parse('/client/api?'+encode_base64(data))
      uri = URI.parse @url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true if uri.port == 443
      request = Net::HTTP::Get.new "#{path}"
      response = http.request request
      result = JSON.parse(response.body)
      puts result
      return result
    end

    #loginしてrequestする場合
    unless (@sessionkey.nil?)
      params[:sessionKey] = @sessionkey
      data = sort_params params
      data.slice!(0) #先頭の&を削除
      path = URI.parse('/client/api?'+data)
      uri = URI.parse @url
      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true if uri.port == 443
      request = Net::HTTP::Get.new "#{path}"
      request['Cookie'] = @jsessionid+';'+@sessionkey
      response = http.request request
      result = JSON.parse(response.body)
      puts result
      return result
    end

    raise 'Cannot request api'

  end

  private :get_request

  def post_request(params)
    params[:response] = 'json'
    path = URI.parse(@url+"/client/api?")
    json = Net::HTTP.post_form(path, params)
    result = JSON.parse(json.body)
    puts result
    return result
  end

  private :post_request


  def encode_base64(data)
    base64_data = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), @secretKey, URI.escape(data).downcase)).strip
    return data + "&signature="+ CGI.escape(base64_data)
  end

  private :encode_base64

  def sort_params(params)
    data = ''
    params = Hash[params.sort]
    params.each do |key, value|
      data += '&'+ key.to_s + '=' + value
    end
    return data
  end

  private :sort_params

  #paramsは配列の中にhashを受け取る

  def to_hash_from_array(params)

    hash = Hash.new

    if params.instance_of?(Hash) then
      params.each do |key, value|
        hash[key] = value
      end
    else
      params.each do |param|
        hash = hash.merge(param)
      end
    end

    return hash
  end

  private :to_hash_from_array

  #
  #　Load Balancer
  #
  def listLoadBalancerRules

  end


  #
  # Network
  #

  def listNetworks(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listNetworks'
    result = get_request params
    return result['listnetworksresponse']
  end

  def deleteNetwork(*params)
    params = to_hash_from_array (params)
    params[:command] = 'deleteNetwork'
    result = get_request params
    return result['deletenetworkresponse']
  end

  #
  # Virtual Machine
  #

  def deployVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'deployVirtualMachine'
    result = get_request params
    return result['deploymachinesresponse']
  end

  def expungeVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'expungeVirtualMachine'
    result = get_request params
    return result['expungemachinesresponse']
  end

  def destroyVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'destroyVirtualMachine'
    result = get_request params
    return result['destroyvirtualmachineresponse']
  end

  def getVMPassword(*params)
    params = to_hash_from_array (params)
    params[:command] = 'getVMPassword'
    result = get_request params
    return result['getvmpasswordresponse']
  end

  def listVirtualMachines(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listVirtualMachines'
    result = get_request params
    return result['listvirtualmachinesresponse']

  end

  def migrateVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'migrateVirtualMachine'
    result = get_request params
    return result['migratevirtualmachineresponse']
  end

  def migrateVirtualMachineWithVolume(*params)
    params = to_hash_from_array (params)
    params[:command] = 'migrateVirtualMachineWithVolume'
    return result['migratevirtualmachinewithvolumeresponse']
  end

  def rebootVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'rebootVirtualMachine'
    result = get_request params
    return get_request params
  end

  def resetPasswordForVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'resetPasswordForVirtualMachine'
    result = get_request params
    return result['resetpasswordforvirtualmachineresponse']
  end

  def startVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'startVirtualMachine'
    result = get_request params
    return result['startvirtualmachineresponse']
  end

  def stopVirtualMachine(*params)
    params = to_hash_from_array (params)
    params[:command] = 'stopVirtualMachine'
    result = get_request params
    return result['stopvirtualmachineresponse']
  end

  #
  # Host
  #
  def listHosts(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listHosts'
    result = get_request params
    result['listhostsresponse']
  end

  #
  # Volume
  #
  def deleteVolume(*params)
    params = to_hash_from_array (params)
    params[:command] = 'deleteVolume'
    result = get_request params
    return result['deletevolumeresponse']
  end

  def attachVolume(*params)
    params = to_hash_from_array (params)
    params[:command] = 'attachVolume'
    result = get_request params
    return result['attachvolumeresponse']
  end

  def detachVolume(*params)
    params = to_hash_from_array (params)
    params[:command] = 'detachVolume'
    result = get_request params
    return result['detachvolumeresponse']
  end

  def listVolumes(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listVolumes'
    result = get_request params
    return result['listvolumesresponse']
  end

  def migrateVolume(*params)
    params = to_hash_from_array (params)
    params[:command] = 'migrateVolume'
    result = get_request params
    return result['migratevolumeresponse']
  end

  #
  # Template
  #
  def deleteTemplate(*params)
    params = to_hash_from_array (params)
    params[:command] = 'deleteTemplate'
    result = get_request params
    return result['deletetemplateresponse']
  end

  def listTemplates(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listTemplates'
    result = get_request params
    return result['listtemplatesresponse']
  end

  #
  # Account
  #

  def disableAccount(*params)
    params = to_hash_from_array (params)
    params[:command] = 'disableAccount'
    result = get_request params
    return result['disableaccountresponse']
  end

  def listAccounts(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listAccounts'
    result = get_request params
    return result['listaccountsresponse']
  end

  #
  # Zones
  #

  def listZones(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listZones'
    result = get_request params
    return result['listzonesresponse']
  end

  #
  # Snapshot
  #

  def deleteSnapshot (*params)
    params = to_hash_from_array (params)
    params[:command] = 'deleteSnapshot'
    result = get_request params
    return result['deletesnapshotresponse']
  end

  def listSnapshots(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listSnapshots'
    result = get_request params
    return result['listsnapshotsresponse']
  end

  #
  # User
  #
  def listUsers(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listUsers'
    result = get_request params
    return result['listusersresponse']
  end

  #
  # ISO
  #

  def deleteIso(*params)
    params = to_hash_from_array (params)
    params[:command] = 'deleteIso'
    result = get_request params
    return result['deleteisosresponse']
  end

  def listIsos(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listIsos'
    result = get_request params
    return result['listisosresponse']
  end

  #
  # Router
  #
  def listRouters(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listRouters'
    result = get_request params
    return result['listroutersresponse']
  end

  #
  # Pool
  #
  def listPools(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listPools'
    result = get_request params
    return result['listpoolsresponse']
  end

  def listStoragePools(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listStoragePools'
    result = get_request params
    return result['liststoragepoolsresponse']
  end

  #
  # Clusters
  #
  def listClusters(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listClusters'
    result = get_request params
    return result['listclustersresponse']
  end

  #
  # SystemVM
  #
  def migrateSystemVm(*params)
    params = to_hash_from_array (params)
    params[:command] = 'migrateSystemVm'
    result = get_request params
    return result['migratesystemvmresponse']
  end

  def listSystemVms(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listSystemVms'
    result = get_request params
    return result['listsystemvmsresponse']
  end

  #
  # Authentication
  #
  def login(*params)
    params = to_hash_from_array (params)
    params[:command] = 'login'
    params[:response] = 'json'

    path = URI.parse(@url+"/client/api?")
    json = Net::HTTP.post_form(path, params)

    jsessionid=nil
    sessionkey=nil

    json.get_fields('Set-Cookie').each { |str|
      k, v = str[0...str.index(';')].split('=')
      if k.eql?("JSESSIONID")
        jsessionid = k+"="+v
      end

      if k.eql?("sessionkey")
        sessionkey = k+"="+v
      end

    }

    result = JSON.parse(json.body)

    return jsessionid, sessionkey, result['loginresponse']
  end

  def logout(*params)
    params = to_hash_from_array (params)
    params[:command] = 'logout'
    result = get_request params
    return result['logoutresponse']
  end

  #
  # SecurityGroup
  #
  def listSecurityGroups(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listSecurityGroups'
    result = get_request params
    return result['listsecuritygroupsresponse']
  end

  #
  # Pod
  #
  def listPods(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listPods'
    result = get_request params
    return result['listpodsresponse']
  end


  #
  # AffinityGroups
  #

  def deleteAffinityGroup(*params)
    params = to_hash_from_array (params)
    params[:command] = 'deleteAffinityGroup'
    result = get_request params
    return result['deleteaffinitygroupresponse']
  end

  def listAffinityGroups(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listAffinityGroups'
    result = get_request params
    return result['listaffinitygroupsresponse']
  end

  #
  # PublicIpAddresses
  #

  def disassociateIpAddress(*params)
    params = to_hash_from_array (params)
    params[:command] = 'disassociateIpAddress'
    result = get_request params
    return result['disassociateipaddressresponse']
  end

  def listPublicIpAddresses(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listPublicIpAddresses'
    result = get_request params
    return result['listpublicipaddressesresponse']
  end

  #
  # AsyncJobs
  #

  def listAsyncJobs(*params)
    params = to_hash_from_array (params)
    params[:command] = 'listAsyncJobs'
    result = get_request params
    return result['listasyncjobsresponse']
  end

  def queryAsyncJobResult(*params)
    params = to_hash_from_array (params)
    params[:command] = 'queryAsyncJobResult'
    result = get_request params
    return result['queryasyncjobresultresponse']
  end

end
