# Bereitstellung von Cloud-Infrastruktur in Azure

## Aufgabenstellung
Wir versuchen mit der für uns neue Technologie Terraform, Infrastruktur auf Microsoft Azure zu provisionieren und diese ebenfalls zu deployen. Es werden dabei 2 Microservices auf verschiedenen Containern deployed, die miteinander kommunizieren. Zusätzlich sollen die Microservices auf eine Datenbank zugreifen, die über MongoDB Atlas auf Amazon Web Services gehostet wird. Für die Microservices wird verglichen, wie sich die Provisionierung mit Terraform zu der von Bicep bzw. der über das Azure-Portal-UI unterscheidet, dabei sollen die jeweiligen Vor- und Nachteile hervorgehoben werden. Mit Terraform kann man zwar auch deployen, aber die eigentliche Stärke liegt im Provisionieren der Infrastruktur. Wir untersuchen zusätzlich, wie sich das Deployen mit Terraform im theoretischen Vergleich zu anderen gängigen Deployment-Technologien wie Ansible schlägt.

Der Source-Code für die zwei Services wurde, wie mit Professor Kurschl ausgemacht, nicht in die Abgabe hochgeladen, da es sich dabei um Firmeneigentum der Firma AnyIdea handelt. Diese Services sind Teil der Masterarbeit von Tobias Wecht.

## Architektur
![alt text](/images/architecture.jpg)

Die zu provisionierende Architektur besteht aus einem Angular Frontend und einem Python/Flask Backend-Service. Als Datenbank wir ein MongoDB Cluster verwenden, die über MongoDB Atlas auf AWS betrieben wird. Die Service ML-Frontend und ML-Backend werden in Azure als Container Apps betrieben.

### MongoDB Atlas
![alt text](/images/mongodb.jpg)
Die MongoDb wir als Cluster mit drei Shards auf AWS betrieben. Dieses Cluster wird Shared betrieben, also RAM und CPU wird sich mit anderen Benutzern geteilt. Da wir auch unter 512MB Speicher und keine Backups benutzen sind wir hier noch im free Tier, es gibt jedoch folgenden kostenpflichtige Optionen:

<ul>
  <li>Dedicated: Eigener Server für Produktionsanwendungen mit anspruchsvollen Workload-Anforderungen</li>
	<ul>
	  <li>Multi-Cloud, Multi-Region und erweiterte Datenverteilung</li>
	  <li>Uptime SLA: 99.995%</li>
	</ul>  
  <li>Serverless: Für serverlose Anwendungen mit geringem oder variablem Datenverkehr</li>
	<ul>
	  <li>RAM und CPU lässt sich nahtlos an die Arbeitslast anpassen</li>
	  <li>Noch in Entwicklung: Multi-Cloud, Multi-Region und erweiterte Datenverteilung</li>
	</ul>  
</ul>  

Weitere Informationen: https://www.mongodb.com/pricing

Unter Verwendung von MongoDB Atlas muss keine Infrastruktur provisioniert oder Cluster konfiguriert werden. Der Anbieter übernimmt das in diesem Fall, vor allem da wir den Shared Ansatz verwenden.

### Anwendungsfall
![alt text](/images/ml_frontend.jpg)
Der Anwendungsfall dieser Architektur sieht wie folgt aus:
Der Priorisierung Service priorisiert Daten wie wissenschaftliche Artikel und News, welche in der MongoDB abgelegt sind, anhand der Benutzereingaben (Keywords) im Frontend. Die Artikel welche die höchste Korrelation zu den Keywords besitzen werden dem Benutzer schlussendlich angezeigt. </br>

## Infrastructure as Code (IaC)
Infrastructure as Code, kurz IaC, ist eine Methode um die Konfiguration von Infrastruktur als Code zu verwaltet wird. 
Sie ermöglicht es die Infrastruktur automatisiert bereitzustellen und diese schnell zu reproduzieren sowie Skalieren.
Der Code kann, wie ein Programmcode, mittels Versionsverwaltungstools wie GIT verwaltet werden. Dies erlaubt es Änderungen an der Infrastruktur nachzuvollziehen. </br>

In den meisten Provisionierungstools ist es möglich die Konfiguration deklarativ zu Beschreiben. Das bedeutet, dass nur der gewünschte Endzustand beschrieben werden muss und die notwendigen Änderungsschritte zum Erreichen dieser das Tool übernimmt. Zusätzlich lässt die deklarative Schreibweise den code lesbar und weniger fehleranfällig werden.

In folgender Abbildung sind die von uns identifizierten Phasen einer Infrastruktur-Erstellung abgebildet. Ziel sollte es sein möglichst alle dieser Phasen mit IaC-Tools zu automatisieren

![alt text](/images/pipeline.jpg)

## Container Apps
Azure Container Apps ist ein Dienst, der von Microsoft Azure angeboten wird und es ermöglicht, Microservices und containerisierte Anwendungen auf einer serverlosen Plattform zu betreiben. Serverless bedeutet, dass Services und Funktionen ausgeführt werden können ohne sich um die Infrastruktur kümmern zu müssen. In den dem fall kümmert sich der Cloud Anbieter um das Bereitstellen der Infrastruktur und das Konfigurieren der Umgebung. Diese Infrastruktur teilt man mit anderen Benutzern.

Die Container Apps können auch eventgesteuert verwendet und skaliert werden. Azure bietet eine Autoskalierung, welche das Service dynamisch nach Last skaliert und wenn kein Datenverkehr herrscht, wird das Service auf O Instanzen herunterskaliert.
Man kann mehrere Versionen des selben Services gleichzeitig betreiben und den Traffic zwischen den Versionen aufteilen, dies ermöglicht ebenfalls green/blue deployments.

Auch wenn die Azure Container Apps grundsätzlich Serverless sind, muss man dennoch Ressourcen wie eine Environment und die Log Analytics konfiguriert werden. In dem Environment werden die Container betrieben und in den Log Analytics werden die Service Logs der einzelnen Container gesammelt.

Dadurch das die Container Apps serverless sind und auf 0 skalieren können sind sie sehr kostengünstig. Unter zwei Millionen Requests sind die Container Apps grundsätzlich gratis, jedoch überschreitet man diese Anzahl oder benötigt sehr lange execution time per request können diese auch sehr teuer werden. Es gilt die Services sehr effizient zu implementieren und diese nur dann aktive zu Betreiben wenn notwendig.

## Provisionierung in Azure

### Azure Portal
Das erstmalige Provisionieren von Infrastruktur für kleine Architekturen ist unter Verwendung des Azure Portal relative einfach und schnell. Die interaktive Web-UI ermöglicht es auch Personen die nicht Entwickler sind oder Code schreiben können, Infrastruktur zu provisionieren.

Jedoch hat die Verwendung des Azure Portals einige Nachteile im Vergleich zu den Infrastructure as Code Ansatz.
Die Infrastruktur kann nicht versioniert werden und bei Änderungen muss wieder durch etliche Sub Pages des Portals durchgeklickt werden. Es können zwar ARM-Templates aus der erstellten Infrastruktur generiert werden, jedoch hatten wir beim Importieren dieser einige Probleme.
Das manuelle Konfigurieren ist natürlich auch wesentlich fehleranfälliger als durch die Beschreibung durch Code.

Das Erstellen einer Azure Container App sieht im Azure Portal wie folgt aus:

![alt text](/images/az_portal.JPG)
![alt text](/images/az_portal_2.JPG) </br>
Kleiner Fun Fact am Rande man benötigt 80 Klicks und muss sich durch 22 Sub Pages wühlen um die Resourcegroup sowie die zwei Container Apps zu konfigurieren, vorausgesetzt man hat dies zuvor schon einmal gemacht und die UI hat sich nicht verändert.

### Bicep
Bicep bietet als Domänenspezifische Sprache von Azure alle Möglichkeiten die auch ARM-Templates bieten, da es sich dabei nur um eine Abstrahierung mit leichter zu lesender Syntax handelt. Durch die Modularisierbarkeit bleibt Code auch für viele Container sehr übersichtlich.

Zuerst muss eine Managed Environment erstellt werden :
```bicep
resource env 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: lawClientId
        sharedKey: lawClientSecret
      }
    }
  }
}

```


Anschließend ein Operational Insights Service an den die Container Apps die Logs schicken:


```Bicep
resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}
```





Nun können die Azure Container Apps erzeugt werden:

```Bicep
resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: name
  location: location
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    .
    .
    .  //configuration cutted out
    .
    
    template: {
      containers: [
        {
          image: containerImage
          name: name
          env: envVars
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}

```

Die seperaten Bicep-Files können nun in einer ```main.bicep``` zu Modulen gemacht und parametriert werden. Hier am Beispiel des Frontend Containers:
```bicep

module containerApp_Ml_Frontend 'containerapp.bicep' = {
  name: 'container-app-ml-frontend'
  params: {
    name: 'container-app-ml-frontend'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: 'anyidea/ml-frontend:master-thesis'
    containerPort: 80 
    registry: 'index.docker.io'
    registryUsername: registryUsername
    registryPassword: registryPassword 
    envVars: [{name:'PROFILE',value: 'stage'},{name:'ML_PRIORITIZER_URL',value: containerApp_Ml_Prioritizer.outputs.fqdn}]
  }
}

```
### Terraform
Terraform ist ein open-source Provisionierungstool um Infrastruktur auf verschiedenen Cloud Plattformen/Anbieter wie AWS, Microsoft Azure oder Google Cloud zu provisionieren. Sie verwendet dabei eine eigene Sprache die HashiCorp Configuration Language(HCL). Dies ist von der Syntax sehr ähnlich wie JSON.

Terraform erlaubt es den Infrastrukturcode deklarativ zu beschreiben. Der Code anschließend mit dem Befehl ```terraform apply``` ausgeführt werden. Dieser Kommand prüft zuerst den aktuellen Zustand der vorhanden Cloud Infrastruktur berechnet sich das Delta zum gewünschtem, im Terraformcode beschrieben Zustand und kommuniziert anschließend mit der Azure API, um die notwendigen Änderungen durchzuführen. Der Iststand der aktuellen Infrastruktur, welcher für die Delta-Berechnung benötigt wird, ist auf dem lokalen System gespeichert und muss ebenfalls in die Versionsverwaltung integriert werden. Dieser Iststand der provisionierten Infrastruktur könnte auch über das ```terraform_remote_state``` feature auf Amazon S3, Azure Blob Storage, Google Cloud Storage, Alibaba Cloud OSS gespeichert werden.

Nutzt man die Remote State Funktion, werden sensitive Daten automatisch verschlüsselt. Wird der Terraform State lokal verwaltet so kann es sein, dass diese in Klartext gespeichert werden. Dies ist Abhängig von der provisionierten Resource. Bei Azure Container Apps bzw. das Passwort für die private Docker Registry würde in unserem Fall nicht im Klartext gespeichert. Mehr Infromation dazu finden sie unter: https://developer.hashicorp.com/terraform/language/state/sensitive-data

#### Terraform Provider
<img src="/images/terraform.jpg" alt="drawing" width="500"/>
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
Eine Ressource Group in Azure ist eine logische Gruppe von Azure-Ressourcen, die gemeinsam verwaltet werden. In diesem Beispiel werden die Container Environment, die Log Analytics sowie die Container Apps in der "clcProjectTerraform" verwaltet.
```terraform
resource "azurerm_resource_group" "rg" {
  name      = "clcProjectTerraform"
  location  = var.location
  tags      = local.tags
}
```
#### Erstellen von Log Analytics
Azure Log Analytics ist ein Dienst in Azure, mit dem Sie system- und anwendungsbezogene Logs und Metriken sammeln, analysieren und visualisieren können. Es bietet eine einheitliche Plattform für die Überwachung von Azure-Ressourcen, wie beispielsweise die Container Apps.
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

Um die Container Apps zu provisionieren wurde über die Liste iteriert und so konnte ein generische Funktion zum Erstellen dieser implementiert werden. Da Terraform die Container Apps nicht nativ unterstützt musste hier die ```azapi_resource``` verwendet werden, welche direkt mit der Azure API kommuniziert. Ebenfalls wurde hier eine private Docker Registry verwendet, nutzt man die Azure Container Registry muss man keine Registry definieren.
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

Um einen Output, wie Beispielsweise der Fully Quallified Domain Name, nach der Erstellung eines Container nutzen zu können muss dieser bereits im Template definiert werden definiert werden.
```terraform 
response_export_values = ["properties.configuration.ingress.fqdn"]
```

Anschließend kann man den Output wie folgt nutzen.
```terraform
output "container_app_urls" {
  value = {
    for app in azapi_resource.aca : app.name =>  jsondecode(azapi_resource.aca[app.name].output).properties.configuration.ingress.fqdn
  }
}
```
#### Custom Domains und Zertifikate
Es wurde zusätzlich versucht Custom Domains für Services zu vergeben. Die Domain wird hier bei Cloudflare gehostet und dieser Dienst wird auch als Reverse Proxy benutzt. Die Custom Domains vergeben zu können muss man bei Cloudflare einen TXT Record mit der "ausid" also die Azure UserID hinterlegen sowie einen CNAME Record nach der Erstellung des Services hinzufügen (kann auch automatisiert werden mit Terraform). Auf der Azure muss ebenfalls ein Zertifikat von Cloudfare hinterlegt werden. 
```terraform
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
```

Bei Azure Container Apps kann man anschließend die Custom Domain wie folgt setzen.
```terraform
customDomains = each.value.domain == "" ? null : [
            {
              bindingType = "SniEnabled"
              certificateId = azapi_resource.certificate.id
              name = "example.com"
            }
          ] 
```
### Befehle
Normalerweise würde man ein Service Principle zu Authentifizierung nutzen jedoch ist dies im Student Account nicht möglich daher musste die Azure CLI verwendet werden.
```shell
az login
```
Der Befehl ```init``` initialisiert ein Terraform-Verzeichnis und lädt die erforderlichen Provider-Plugins herunter. Es muss in einem Terraform-Verzeichnis ausgeführt werden, bevor andere Befehle wie ```terraform plan``` oder ```terraform apply``` ausgeführt werden können. Es erstellt auch die Datei ".terraform" im aktuellen Verzeichnis, die Informationen über die verwendeten Provider enthält.

```shell
terraform init
```

Der Befehl ```terraform plan``` erstellt einen Plan für die Erstellung oder Änderung der Ressourcen, die in einer Terraform-Konfigurationsdatei definiert sind. Es zeigt an, welche Änderungen an den Ressourcen vorgenommen werden, und gibt eine Vorschau auf die Auswirkungen dieser Änderungen. Der Befehl ```terraform plan``` muss nach dem ```terraform init``` Befehl ausgeführt werden, damit er Zugriff auf die Provider-Plugins hat und die aktuellen Zustände der Ressourcen abrufen kann. Mit dem Output des Befehls kann man die Änderungen überprüfen bevor man sie mit ```terraform apply``` umsetzt.

```shell
terraform plan
```
Der Befehl ```terraform apply``` führt den zuvor erstellten Terraform-Plan aus und erstellt oder ändert die Ressourcen, die in der Konfigurationsdatei definiert sind. Es werden die von ```terraform plan``` berechneten Schritte ausgeführt, um die gewünschten Ressourcen zu erstellen oder zu ändern.

Der Befehl fordert eine Bestätigung des Benutzers an, bevor er fortfährt, und gibt eine Zusammenfassung der durchgeführten Änderungen aus. Abschließend wird der lokal gespeicherte Status der Cloud Infrastruktur aktualisiert.

```shell
terraform apply
```

Der Befehl ```terraform destroy``` zerstört die Ressourcen, die durch eine Terraform-Konfigurationsdatei verwaltet werden. Es analysiert die Konfigurationsdatei und identifiziert die Ressourcen, die erstellt wurden, und löscht diese Ressourcen von der Provider-API.

```shell
terraform destroy
```

## Vergleich der Provisionierungsmöglichkeiten

### Easy to learn?
Bicep und Terraform sind sich in der Syntax aufgrund der Tatsache, dass es sich bei beiden um deskriptive Sprachen handelt, viel ähnlicher als wir gedacht haben. Für uns waren beide Sprachen Neuland. Wir hatten aber dank zahlreichen Tutorials und guter Dokumentation einen schnelle Lernkurve und würden Biceps und Terraform als "easy to learn" einstufen.

### Azure Support
Besonders bei den Container Apps, welche es noch nicht lange gibt, hat sich gezeigt, dass diese viel besser in Biceps integriert sind als in Terraform. 

### Muli-Platform-Support
Da sich Bicep und Terraform so ähnlich sind in ihrer Syntax sehen wir den Vorteil, dass man Terraform für verschiedene Cloudanbieter verwenden kann nicht ganz so stark. Nur wenn Multi-Cloud exzessiv eingesetzt wird kann man die Infrastrukturbeschreibung einheitlich halten.

### State
Terraform speichert den State in eigenen Statefiles ab. Biceps direkt im Azure-Portal. Statefile müssen selber verwaltet werden in Cloud oder lokal.
Bei Bicep werden Ressourcen nur über Namen erkannt. Daher kann eine einfache Unbenennung einer Ressource schnell zur Herausforderung werden und es kann nötig sein die ganze Infrastruktur neu zu deployn. Dieses Problem hatten wir bei Terraform nicht.

### Pricing
Bicep ist in Azure integriert und dadurch für Azure-User gratis. Terraform ist auch gratis zu verwenden jedoch gibt es gewisse Features betreffend Governance und Teamarbeit nur für einen Preis von ab 20$ pro User und Monat.

### IDE Support
Wir waren stark begeistert von den Extensions für VS-Code. Hier konnten Bicep und Terraform voll und ganz punkten.


## Theoretische Abgrenzung von Terraform zu Ansible

Ansible verfolgt im Vergleich zu Terraform einen prozedualen Ansatz und keinen deklarativen. Das bedeutet, dass man nicht einfach den gewünschten Zustand beschreibt, sondern Schritt für Schritt in der richtigen Reihenfolgen definieren muss. Dabei geht jedoch der große Vorteil bei der Provision von Infrastruktur verloren. Der Prozeduale Ansatz eigent sich jedoch besser um beispielsweise Konfigurations- und Softare-Updates auf vielen Rechnern gleichzeitig durchzuführen. Daher bezeichnet man Ansible häufig als Konfigurations-Management-Tool. Häufig wird Terraform in Kombination mit Ansible eingesetzt um alle Infrastruktur-Phasen abzudecken.

Bekannte Softwares dich sich ebenfalls in der selben Kategorie wie Ansible wieder finden sind Puppet und Chef. Diese sind jedoch bei weitem nicht so weit verbreitet wie Ansible. Der Grund dafür ist, dass Ansible im Vergleich zu der Konkurrenz „agentless“ funktioniert. Das bedeutet, dass auf den Rechnern, auf welche man zugreift, keinerlei Software für den Zugriff mit Ansible installiert werden muss. Die erlechtert, das initiale Setup und eventuelle Updates des Konfigurations-Management-Tools.

![alt text](/images/ansible.jpg)

## Fazit
Wir haben sowohl mit Bicep als auch mit Terraform unser Provisonierungsziel ohne größere Probleme erreicht. Zu den Azure Container Apps sind die Quellen die man Online  bezüglich der Provisionierung findet noch sehr dürftig, weil diese erst vor kurzem released wurden, was die Aufgabenstellung etwas erschwert hat.Terraform hat aber die größere Community. Die Berechnung des Deltas von Terraform kann einen großen Vorteil bieten, wenn man häufige Änderungen an der Infrastruktur geplant hat. Bicep speichert zwar ebenfalls den State direkt in Azure ab, unsere Erfahrung zeigt aber, dass hier häufig nur ein komplett neues Deployment zum erwünschten Ergebnis führt, wenn man Änderungen an der Infrastruktur vornimmt. Die Multi-Plattform-Fähigkeit von Terraform sehen wir nur bedingt als Vorteil, da jeder Cloud-Anbieter verschiedene Services/Resourcen anbietet und man sich ohnehin mit diesen jeweils im Detail für die Provisionierung beschäftigen muss. Höchstens beim Einsatz von Multi-Cloud könnte dies ein Vorteil sein, da man einheitlich mit einer Sprache alles beschreibt.

## Fragestellungen der Abgabe
#### Automated Infrastructue Provisioning/(Infrastructure-as-Code). Wie wurde im vorliegenden Projekt Automated Infrastructure Provisioning berücksichtigt? </br>
Es wurde ein Vergleich von Provisionierungsmöglichkeiten in Azure ausgearbeitet.</br>

#### Skalierbarkeit. Wie wurde im vorliegenden Projekt Skalierbarkeit berücksichtigt?</br>
Azure Container Apps sind hoch skalierbar. In diesem Projekt wurden der Autoscale von Azure verwendet, man kann die Anzahl der Instanzen dabei in den jeweiligen Templates mit "minReplicas" und "maxReplicas" definieren. Die Mindestanzahl sollte dabei auf 0 gesetzt werden damit die Container auf 0 herunterskalieren, wenn diese nicht verwendet werden, dies spart Kosten. Die Maximale Anzahl kann nach Belieben adaptiert werden.</br>

#### Ausfallssicherheit.  Wie wurde im vorliegenden Projekt Ausfallssicherheit berücksichtigt?</br>
Die verwendete MongoDB wird als Cluster mit 3 Replicas betrieben, dies sollte eine gute Basis für die Ausfallsicherheit eine Datenbank bilden. In einem reellen Betrieb müssten natürliche Backups gemacht werden um diese im Worst Case wiederherstellen zu können, jedoch wurde in diesem Studienprojekt auf Grund der Kosten darauf verzichtet.</br>

Für die Azure Container Apps ist in den SLAs eine Ausfallsicherheit von 99.95% definiert. Für Projekte wie dieses, die keine kritischen Daten verarbeiten und bei dem eine kurze Downtime zu keinen tragischen Verlust führen würde, ist das vollkommen ausreichend.</br>
Weitere Informationen: https://azure.microsoft.com/en-us/support/legal/sla/container-apps/v1_0/ </br>

#### NoSql. Welchen Beitrag leistet NoSql in der vorliegenden Problemstellung?</br>
In diesem Projekt wurde die NoSql Datenbank MongoDB verwendet, da unstrukturierte Daten gespeichert werden und die meisten Abfragen Bulk Request von 10000+ Einträgen sind. Zuvor wurde eine MySQL Datenbank verwendet, bei dieser führten diese Bulk Request zu Ladezeiten von mehreren Minuten.

#### Replikation. Wo nutzen Sie im gegenständlichen Projekt Daten-Replikation?</br>
Im MongoDB Cluster werden Daten zwischen den einzelnen Replicas repliziert. Die Azure Container Apps werden über den Autoscale sowie das setzen der max und min Replica anzahl repliziert. Es wird jedoch keine Georeplikation benutzt.

#### Kosten. Welche Kosten verursacht Ihre Lösung? Welchen monetären Vorteil hat diese Lösung gegenüber einer Nicht-Cloud-Lösung?</br>
Die Azure Container Apps sind bis zu einer Anzahl von 2 Mio. Request im Monat kostenlos. Diese Anzahl überschreiten wir in diesem Projekt nicht, daher gibt es auch keine Kosten zu verbuchen. </br>
https://azure.microsoft.com/en-us/pricing/details/container-apps/ </br>

Das MongoDB Cluster fällt bei der derzeitigen Verwendung ebenfalls noch in den free Tier. </br>
https://www.mongodb.com/pricing
