require_relative 'base_cloud_stack'

class CloudStack < BaseCloudStack

  #
  # Network
  #
  def deleteNetwork(*params)
    return get_job_result(super)
  end

  #
  # Virtual Machine
  #

  def destroyVirtualMachine(*params)
    return get_job_result(super)
  end

  def startVirtualMachine(*params)
    return get_job_result(super)
  end

  def stopVirtualMachine(*params)
    return get_job_result(super)
  end

  def migrateVirtualMachine(*params)
    return get_job_result(super)
  end

  #
  # Volume
  #

  #たぶん必要ない
  #def deleteVolume(*params)
  #  response = super
  #  return get_job_result(response)
  #
  #end

  #
  # Template
  #

  def deleteTemplate (*params)
    return get_job_result(super)
  end

  #
  # Snapshot
  #

  def deleteSnapshot (*params)
    return get_job_result(super)
  end

  #
  # Iso
  #

  def deleteIso(*params)
    return get_job_result(super)
  end

  #
  # SystemVM
  #
  def migrateSystemVm(*params)
    return get_job_result(super)
  end

  #
  # AffinityGroups
  #

  def deleteAffinityGroup(*params)
    return get_job_result(super)
  end

  #
  # PublicIpAddresses
  #

  def disassociateIpAddress(account="false")
    return get_job_result(super)
  end

  def get_job_result(response)
    if response.has_key?('jobid')
      job_result = polling_asyncjob(response['jobid']);

      return job_result
    end

    return response['errortext']

  end

  private :get_job_result

  def polling_asyncjob(jobid)
    begin
      result = queryAsyncJobResult(jobid: jobid)

      print 'jobstatus : '+result['jobstatus'].to_s + ' '
      print 'accountid : '+result['accountid'] + ' '
      print 'cmd : '+result['cmd'] + ' '
      print 'jobid : '+result['jobid'] + ' '
      puts ''
      sleep 3

    end while result['jobstatus'] == 0

    return result

  end

end
