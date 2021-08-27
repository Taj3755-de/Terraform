provider "vsphere" {
  # If you use a domain, set your login like this "Domain\\User"
  user           = "administrator@aigilx.local"
  password       = "aDMIN@876"
  vsphere_server = "172.16.10.95"
 
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Aigilx-VMV-DATACENTER002"
}

data "vsphere_datastore" "datastore" {
  name          = "Datastore02"
  datacenter_id = data.vsphere_datacenter.dc.id
}


#If you don't have any resource pools, put "/Resources" after cluster name
data "vsphere_resource_pool" "pool" {
  name          = "Terraform"
 datacenter_id = data.vsphere_datacenter.dc.id
}
  
# Retrieve network information on vsphere
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}
 
# Retrieve template information on vsphere
data "vsphere_virtual_machine" "template" {
  name          = "tool-kafka-73"
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_virtual_machine" "demo" {
  name             = "vm-one"
  num_cpus         = 2
  memory           = 4096
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
 
  wait_for_guest_net_timeout = 0
  # Set network parameters
  network_interface {
    network_id = data.vsphere_network.network.id
  }
 
  # Use a predefined vmware template as main disk
  /*disk {
    label = "vm-one.vmdk"
    size = "30"
  }*/
  
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
  }
}
