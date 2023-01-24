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
    domain = "ml-prioritizer-tobias-master-thesis.anyidea.ai"
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
        value = "https://ml-prioritizer-tobias-master-thesis.anyidea.ai"
      }
    ]
  }] 
}