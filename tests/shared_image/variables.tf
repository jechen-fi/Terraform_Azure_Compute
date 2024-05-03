variable "gallery_name" {
  default = "a00000_shrdimggallery_ctd"
}

variable "img_name" {
 default = "a00000vmimage"
} 

variable "shrd_img_name" {
  default = "a00000_shrdimg_ctd"
} 

variable "resource_group_name" {
  description = "Resource group name that holds VM, VM NIC, and related resources"
  default = "a00000-namespace-ctd"
}

variable "hyper_v_generation" {
  default = "V2"
}

variable "regional_replica_count" {
  default = "4"
}

variable "os_type" {
  default = "Linux"
} 

variable "identifier" {
  default =  {
    publisher = "PublisherName"
    offer     = "OfferName"
    sku       = "ExampleSku"
  }
}

variable "shrd_img_version" {
  default = "0.0.1"
} 
