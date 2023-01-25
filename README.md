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


## Vergleich der Provisionierungsmöglichkeiten

## Abgrenzung zu Ansible
