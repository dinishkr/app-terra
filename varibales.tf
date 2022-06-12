variable "vm_name" {
   type = list(string)
   default = [ "app2","app1"] 
}

variable "environment" {
    type = string
    default = "prod" 
}

variable "cloud" {
    type = string
    default = "azure"
  
}
