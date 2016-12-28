require_relative 'cloud_stack'

class CloudStackClient < CloudStack

  def listAllResource
    listResource(listNetworks, "network")
    listResource(listVirtualMachines, "virtualmachine")
    listResource(listVolumes, "volume")
    listResource(listTemplates(templatefilter: "self"), "template")
    listResource(listAccounts, "account")
    listResource(listSnapshots, "snapshot")
    listResource(listUsers, "user")
    listResource(listIsos(isofilter: "self"), "iso")
    listResource(listRouters, "router")
    listResource(listAffinityGroups, "affinitygroup")
    listResource(listPublicIpAddresses, "publicipaddress")
    listResource(listHosts, "host")
    listResource(listSystemVms, "systemvm")
    listResource(listRouters, "router")

  end

  def listResource(json, name)
    puts "============ "+name+" =============================================================="

    if (json.size != 0) then
      json[name].each do |i|
        puts "id:#{i['id']}  name: #{i['name']}   state: #{i['state']}"
      end
    end

    puts ""
  end

  #
  # Network
  #
  def deleteAllNetwork(account="false")
    networks = listNetworks(account: account, listall: "true")
    if (networks.has_key?('network'))
      networks['network'].each do |network|
        unless network['name'] == "Shared Network"
          puts deleteNetwork(id: network['id'])
        end
      end
    end

  end

  #
  # VirtualMachine
  #
  def liveMigrateVM(vmid, hostid)
    message = migrateVirtualMachine(virtualmachineid: vmid, hostid: hostid)
    return message
  end

  def coldMigrateVM(vmid, hostid)
    stop_result = stopVirtualMachine(id: vmid)
    if (stop_result['jobstatus'] == 1)
      start_result = startVirtualMachine(id: vmid, hostid: hostid)
      if (start_result['jobstatus'] == 1)
        return {'status' => 'success','message' => 'コールド成功','result' => start_result}

      else
        return {'status' => 'fail','message' => '起動失敗','result' => start_result}
      end
    else
      return {'status' => 'fail','message'=>'停止失敗','result' => stop_result }
    end
  end

  def destroyAllVirtualMachine(account="false")
    virtualmachines = listVirtualMachines(account: account, type: "DATADISK", listall: "true")
    if (virtualmachines.has_key?('virtualmachine'))
      virtualmachines['virtualmachine'].each do |virtualmachine|
        puts destroyVirtualMachine(id: virtualmachine['id'], expunge: "true")
      end
    end
  end

  #
  # Volume
  #
  def deleteAllDataVolume(account="false")
    volumes = listVolumes(account: account, type: "DATADISK", listall: "true")
    if (volumes.has_key?('volume'))
      volumes['volume'].each do |volume|
        unless volume.has_key?('attached')
          puts deleteVolume(id: volume['id'])
        end
      end
    end
  end

  #
  # Template
  #
  def deleteAllTemplate(account="false")
    templates = listTemplates(account: account, templatefilter: "self", listall: "true")
    if (templates.has_key?('template'))
      templates['template'].each do |template|
        puts deleteTemplate(id: template['id'])
      end
    end
  end

  #
  # Snapshot
  #

  def deleteAllSnapshot(account="false")
    snapshots = listSnapshots(account: account, listall: "true")
    if (snapshots.has_key?('snapshot'))
      snapshots['snapshot'].each do |snapshot|
        puts deleteSnapshot(id: snapshot['id'])
      end
    end
  end

  #
  # ISO
  #

  def deleteAllIso(account="false")
    isos = listIsos(account: account, isofilter: "self", listall: "true")
    if (isos.has_key?('iso'))
      isos['iso'].each do |iso|
        puts deleteIso(id: iso['id'])
      end
    end
  end

  #
  # Router
  #
  def liveMigrateRouter()

  end

  #
  # SystemVM
  #
  def liveMigrateSVM(vmid, hostid)
    message = migrateSystemVm(virtualmachineid: vmid, hostid: hostid)
    return  message
  end


  #
  # AffinityGroup
  #

  def deleteAllAffinityGroup(account="false")
    affinitygroups = listAffinityGroups(account: account, listall: "true")
    if (affinitygroups.has_key?('affinitygroup'))
      affinitygroups['affinitygroup'].each do |affinitygroup|
        puts deleteAffinityGroup(id: affinitygroup['id'])
      end
    end
  end

  #
  # PublicIpAddresses
  #
  def disassociateAllIpAddress(account="false")
    ipaddresses = listPublicIpAddresses(account: account, issourcenat: "false", listall: "true")
    if (ipaddresses.has_key?('publicipaddress'))
      ipaddresses['publicipaddress'].each do |ipaddress|
        puts disassociateIpAddress(id: ipaddress['id'])
      end
    end
  end

end
