# Bereitstellung von Cloud-Infrastruktur in Azure

## Aufgabenstellung

## Architektur
![alt text](/images/architecture.jpg)

Die zu provisionierende Architektur besteht aus einem Angular Frontend und einem Python/Flask Backend-Service. Als Datenbank wir ein MongoDB Cluster verwendet die über MongoDB Atlas auf AWS betrieben wird. Der Usecase dieser Architektur sieht wie folgt aus:
Der Priorizierungs service priotizert Daten wie wissenschaftliche Artikel und News, welche in der Mongodb abgelegt sind, anhand der Benutzereingaben (Keywords) im Frontend. Die Artikel welche die höchste Korrelation zu den Keywords besitzen werden dem Benutzer schlussendlich angezeigt. </br>

Das die Service ML-Frontend und ML-Backend werden in Azure als Container Apps betrieben.

## Infrastructure as Code (IaC)
Infrastructure as Code, kurz IaC, ist eine Methode um die Konfiguration von Infrastruktur als Ccode zu verwaltet wird. 
Sie ermöglicht es die Infrastruktur automatisiert bereitzustellen und diese schnell zu Reproduzieren sowie Skalieren.
Der Code kann, wie ein Programmcode, mittes Versionsverwaltungstools wie Git verwaltet werden. Dies erlaubt es Anderungen an der infrastruktur nachzuvollziehen. </br>

In den meisten Provisionierungs Tools is es möglich die Konfigruation deklarativ zu Beschreiben. Was bedeutet, dass nur der gewünschten Endzustand beschrieben werdne muss und die notwendigen Änderungsschritte zum Erreichen dieser das Tool übernimmt. Zusätzlich lässt die deklarative Schreibweise den code lesbar und weniger fehleranfällig werden.

## Container Apps
Azure Container Apps ist ein Dienst der von Microsoft Azure angeboten wird und esermöglicht, Microservices und containerisierte Anwendungen auf einer serverlosen Plattform zu betreiben. Serverless bedeutet dass Services und Funktionen ausgeführt werden können ohne sich um die Infrastruktur kümmern zu müssen. In den dem fall kümmert sich der Cloud Anbieter um das bereitstellen der Infrasturktur und das Konfigurieren der Umgebung. Diese Infrasturktur teilt man mit anderen Benutzern.

Die Container Apps können auch eventgesteuert verwendet und skaliert werden. Azure bietet eine Autoskalierung, welche das Service dynamisch nach Last skaliert und wenn kein Datenverkehr herrscht wird das Service auf O Instanzen herunterskaliert.
Man kann mehrere Versionen des selben Services gleichzeitg betreiben und den Traffic zwischen den Versionen aufteilen, dies ermöglicht ebenfalls green/blue deployments.

Auch wenn die Azure Container Apps grundsätzlich Serverless sind, muss man dennoch Ressourcen wie eine Enviroment und die Log Analytics konfiguriert werden. In dem Enviroment werden die Container betrieben und in den Log Analytics werden die Service Logs der einzelnen Container gesammelt.

Dadurch das die Container Apps serverless sind und auf 0 skalieren können sind sie sehr kostengünstig. Unter zwei Millionen Requests sind die Container Apps grundsätzlich gratis, jedoch überschreitet man diese Anzahl oder benötigt sehr lange execution time per request können diese auch sehr teuer werden. Es gilt die Services sehr effizient zu implementieren und diese nur dann aktive zu Betreiben wenn notwendig.

## Provisionierung in Azure

### Azure Portal
Das erstmalige Provisionieren von Infrasturktur für kleine Architekturn ist unter Verwendung des Azure Portal relative einfach und schnell. Die interaktive Web-UI ermöglicht es auch Personen die nicht Entwickler sind oder Code schreiben können, Infrastruktur zu provisionieren.

Jedoch hat die Verwendung des Azure Portals einige Nachteile im Vergleich zu den Infrastructure as Code ansätzen.
Die Infrastruktur kann nicht versioniert werden und bei Änderungen muss wieder durch etliche Subpages des Protals durchgeklickt werden. Es können zwar ARM-Templates aus der erstellten Infrastruktur generiert werden, jedoch hatten wir beim importieren dieser einige Probleme.
Das manuelle Konfigurieren ist natürlich auch wesentlich fehleranfälliger als durch die Beschreibung durch Code.

Das Erstellen einer Azure Container App sieht im Azure Portal wie folgt aus:

![alt text](/images/az_portal.JPG)
![alt text](/images/az_portal_2.JPG) </br>
Kleiner Fun Fact am Rande man benötigt 80 Klicks und muss sich durch 22 Subpages wühlen um die Resourcegroup sowie die zwei Container Apps zu konfigurieren, vorrausgesetzt man hat dies zuvor schon einmal gemacht und die UI hat sich nicht verändert.

### Bicep
### Terraform
Terraform ist ein open-source Provisionierungstool um Infrastruktur auf verschiedenen Cloud Platformen/Anbieter wie AWS, Microsoft Azure oder Google cloud zu provisionieren. Sie verwendet dabei eine eigene Sprache die HashiCorp Configuration Language(HCL). Dies ist von der Syntac sher ähnlich wie Json.

Terraform erlaubt es den Infrastrukturcode deklarativ zu beschreiben. Der Code anschließend mit dem Befehl ```terraform apply``` ausgeführt werden. Dieser Kommand prüft zuerst den aktuellen Zustand der vorhanden Cloud Infrastruktur brechnet sich das Delta zum gewünschtem, im Terrformcode beschrieben Zustand und kommuniziert anschließend mit der Azure API um die notwendigen Änderungen durchzuführen. Der Iststand der aktuellen Infrastruktur, welcher für die Delta-Berechnnung benötigt wird, muss auf dem lokalen System gespeichert sein und ebenfalls in die Versionsverwaltung integriert werden.

#### Terraform Provider
Terraform Provider sind Erweiterungen für Terraform, die es ermöglichen, Ressourcen in verschiedenen Technologie-Stack zu verwalten. Jeder Provider ist für eine bestimmte Technologie oder einen Dienst verantwortlich und stellt die entsprechenden Ressourcen und Aktionen bereit, die von Terraform verwendet werden können. In diesem Fall wurde der Azure Ressource Manager zum provisionieren der Ressourcegroup sowie der Log Analytics verwendet. Zusätzlich musste die Azure API eingebunden werden da Terraform die Container Apps noch nicht native unterstützt.

```terraform
terraform {
  required_version = "1.3.6"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.17.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "~>0.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" { }
```
#### Erstellen einer Resource Group
Eine Resource Group in Azure ist eine logische Gruppe von Azure-Ressourcen, die gemeinsam verwaltet werden. In diesem Beispiel werden die Container Enviroment, die Log Analytics sowie die Container Apps in der "clcProjectTerraform" verwaltet.
```terraform
resource "azurerm_resource_group" "rg" {
  name      = "clcProjectTerraform"
  location  = var.location
  tags      = local.tags
}
```
#### Erstellen von Log Analytics
Azure Log Analytics ist ein Dienst in Azure, mit dem Sie system- und anwendungsbezogene Logs und Metriken sammeln, analysieren und visualisieren können. Es bietet eine einheitliche Plattform für die Überwachung von Azure-Ressourcen, wie beispielsweise die Contaienr Apps.
```terraform
resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-aca-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}
```
#### Erstellen von Container Apps
Es wurde ein Variable erstellt die eine Liste an Container Apps Eigenschaften definiert die im späteren Verlauf zum Provisionieren benutzt wird.
```terraform
variable "container_apps" {
  type = list(object({
    name = string
    image = string
    tag = string
    containerPort = number
    ingress_enabled = bool
    domain = string
    min_replicas = number
    max_replicas = number
    cpu_requests = number
    mem_requests = string
    env = list(object({
      name = string
      value = string
    }))
  }))


  default = [ {
    name = "ml-prioritizer-terra"
    image = "anyidea/ml-prioritizer"
    tag = "master-thesis"
    containerPort = 5000
    ingress_enabled = true
    domain = "CUSTOM_DOMAIN"
    min_replicas = 0
    max_replicas = 1
    cpu_requests = 2.0
    mem_requests = "4.0Gi"
    env = [
      { 
        name = "PROFILE"
        value = "stage"
      },
      {
        name = "MONGODB_URL"
        value = "MONGODB_URL"
      },
      {
        name = "PYTHONUNBUFFERED"
        value = "1"
      }
    ]
  },
  {
    name = "ml-frontend-terra"
    image = "anyidea/ml-frontend"
    tag = "master-thesis"
    containerPort = 80
    ingress_enabled = true
    domain = ""
    min_replicas = 0
    max_replicas = 1
    cpu_requests = 0.25
    mem_requests = "0.5Gi"
    env = [
      { 
        name = "PROFILE"
        value = "stage"
      },
      {
        name = "ML_PRIORITIZER_URL"
        value = "ML_PRIORITIZER_URL"
      }
    ]
  }] 
```
```terraform
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
			        value = "PASSWORD"
            }
        ]
        registries: [
            {
                server = "index.docker.io"
                username = "USERNAME"
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
```
#### Custom Domains und Zertifikate

### Terraform Befehle
az login
init


## Vergleich der Provisionierungsmöglichkeiten

## Abgrenzung zu Ansible
