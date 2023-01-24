output "container_app_urls" {
  value = {
    for app in azapi_resource.aca : app.name =>  jsondecode(azapi_resource.aca[app.name].output).properties.configuration.ingress.fqdn
  }
}

