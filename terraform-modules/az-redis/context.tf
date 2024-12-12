variable "context" {
  description = "Single object to hold all context variables. Using indivial variables will override settings in this object."
  type        = any
  default = {
    namespace   = null
    project     = null
    environment = null
    name        = null
    tags        = {}
  }
}
variable "name" {
  description = "The name of component the resource belongs to. This is usually the name of the application or service."
  type        = string
  default     = null
}
variable "namespace" {
  description = "Value to use as a namespace for resources. This is usually a short abbreviation of your company name or project name."
  type        = string
  default     = null
  validation {
    condition     = var.namespace == null ? true : can(regex("^[a-z]+$", var.namespace))
    error_message = "The namespace variable must be lowercase letters only."
  }
}
variable "project" {
  description = "When resource are dedictated per customer, this name can be used to identify the customer the resource is for. This is usually a short abbreviation for the customer name."
  type        = string
  default     = null
  validation {
    condition     = var.project == null ? true : can(regex("^[a-z]+$", var.project))
    error_message = "The project variable must be lowercase letters only."
  }
}
variable "environment" {
  description = "A short abbreviation for the environment, e.g. dev, test, prod."
  type        = string
  default     = null
  validation {
    condition     = var.environment == null ? true : can(regex("^[a-z]+$", var.environment))
    error_message = "The environment variable must be lowercase letters only."
  }
}
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}
variable "rg_app_main" {
  description = "The resource group to deploy resources to."
  type = object({
    id       = string
    name     = string
    location = string
  })
  default = null
}
variable "rg_app_sec" {
  description = "The resource group to deploy resources to."
  type = object({
    id       = string
    name     = string
    location = string
  })
  default = null
}
variable "rg_app_net" {
  description = "The resource group to deploy resources to."
  type = object({
    id       = string
    name     = string
    location = string
  })
  default = null
}
module "context" {
  source      = "../context"
  context     = var.context
  name        = var.name
  namespace   = var.namespace
  project     = var.project
  environment = var.environment
  tags        = var.tags
  rg_app_main = var.rg_app_main
  rg_app_sec  = var.rg_app_sec
  rg_app_net  = var.rg_app_net
}
locals {
  tags = merge(module.context.tags, { UniqueModule = "az-redis" })
}