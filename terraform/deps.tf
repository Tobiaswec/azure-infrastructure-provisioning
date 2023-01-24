resource "azurerm_resource_group" "rg" {
  name      = "clcProjectTerraform"
  location  = var.location
  tags      = local.tags
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-aca-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azapi_resource" "aca" {
  for_each  = { for ca in var.container_apps: ca.name => ca}
  type      = "Microsoft.App/containerApps@2022-03-01"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = each.value.name
  
  body = jsonencode({
    properties: {
      managedEnvironmentId = azapi_resource.aca_env.id
      configuration = {
        secrets = [
            {
              name = "reg-pswd-8614df11-a390"
			        value = "dwtXDOmhdDeDYMQlL2E4seFK00CH"
            }
        ]
        registries: [
            {
                server = "index.docker.io"
                username = "anyidea"
                passwordSecretRef = "reg-pswd-8614df11-a390"
            }
        ]
        ingress = {
          external = each.value.ingress_enabled
          targetPort = each.value.ingress_enabled?each.value.containerPort: null
          customDomains = each.value.domain == "" ? null : [
            {
              bindingType = "SniEnabled"
              certificateId = azapi_resource.certificate.id
              name = each.value.domain
            }
          ] 
        }
      }
      template = {
        containers = [
          {
            name = "main"
            image = "${each.value.image}:${each.value.tag}"
            resources = {
              cpu = each.value.cpu_requests
              memory = each.value.mem_requests
            }
            env = each.value.env
          }         
        ]
        scale = {
          minReplicas = each.value.min_replicas
          maxReplicas = each.value.max_replicas
        }
      }
    }
  })
  tags = local.tags
  response_export_values = ["properties.configuration.ingress.fqdn"]
}

resource "azapi_resource" "certificate" {
  type = "Microsoft.App/managedEnvironments/certificates@2022-03-01"
  name = "anyidea.ai"
  location = var.location
  parent_id = azapi_resource.aca_env.id
  body = jsonencode({
    properties = {
      value = filebase64("origin.pem")
    }
  })
}