terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    vagrant = {
      source  = "bmatcuk/vagrant"
      version = "~> 4.0.0"
    }
  }
}
provider "vagrant" {
}
provider "coder" {

}

data "coder_parameter" "vagrant_box" {
  name         = "vagrant_box"
  display_name = "Vagrant Box"
  default      = "hashicorp/precise64"
  type         = "string"
  mutable      = false
}
data "coder_parameter" "vagrant_vcpu" {
  name         = "vagrant_vcpu"
  display_name = "Vagrant CPU"
  default      = 2
  type         = "number"
  mutable      = false
}
data "coder_parameter" "vagrant_mem" {
  name         = "vagrant_mem"
  display_name = "Vagrant Memory (in MB)"
  default      = 2048
  type         = "number"
  mutable      = false
}
data "coder_parameter" "vagrant_provider" {
  name         = "vagrant_provider"
  display_name = "Vagrant Provider"
  default      = "vmware_desktop"
  mutable      = false
  option {
    name  = "VirtualBox"
    value = "virtualbox"
  }
  option {
    name  = "VMware"
    value = "vmware_desktop"
  }

}
data "coder_provisioner" "me" {
}

data "coder_workspace" "me" {
}

resource "coder_agent" "main" {
  arch = data.coder_provisioner.me.arch
  os   = "linux"
  dir  = "/vagrant"
}

resource "vagrant_vm" "main_vm" {
  vagrantfile_dir = "."
  env = {
    "VAGRANT_BOX"        = data.coder_parameter.vagrant_box.value
    "VAGRANT_CPUS"       = data.coder_parameter.vagrant_vcpu.value
    "VAGRANT_MEMORY"     = data.coder_parameter.vagrant_mem.value
    "VAGRANT_PROVIDER"   = data.coder_parameter.vagrant_provider.value
    "CODER_AGENT_SCRIPT" = coder_agent.main.init_script
    "CODER_AGENT_TOKEN"  = coder_agent.main.token

  }
  get_ports = true
}
