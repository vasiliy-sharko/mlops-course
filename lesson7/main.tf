resource "kubernetes_namespace" "argo" {
  metadata {
    name = var.argocd_namespace
  }
}

resource "helm_release" "argo" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argo.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  recreate_pods = true
  replace       = true
  
  values = [file("${path.module}/values/argocd-values.yaml")]
}

resource "kubernetes_manifest" "namespaces_appset" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "ApplicationSet"

    metadata = {
      name      = "namespaces-appset"
      namespace = var.argocd_namespace
    }

    spec = {

      generators = [
        {
          git = {
            repoURL     = var.app_repo_url
            revision    = var.app_repo_branch
            directories = [
              { path = "namespace/*" }
            ]
          }
        }
      ]

      template = {
        metadata = {
          name      = "ns-{{path.basename}}"
          namespace = var.argocd_namespace
        }

        spec = {
          project = "default"

          source = {
            repoURL        = var.app_repo_url
            targetRevision = var.app_repo_branch

            path           = "{{path}}"
            directory = {
              recurse = true
            }
          }

          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "{{path.basename}}"
          }

          syncPolicy = {
            automated = {
              prune    = true
              selfHeal = true
            }
            syncOptions = []
          }

          revisionHistoryLimit = 2
        }
      }
    }
  }

  depends_on = [helm_release.argo]
}

resource "kubernetes_manifest" "prometheus_operator_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name = "prometheus-operator"
      namespace = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "monitoring"
      }
      source = {
        repoURL        = "https://prometheus-community.github.io/helm-charts"
        targetRevision = "75.16.1"
        chart          = "kube-prometheus-stack"
        helm = {
          valuesObject = {
            nameOverride   = "prometheus-operator"
            defaultRules = {
              create = true
              rules = {
                cpu    = true
                memory = true
              }
            }
            prometheus = {
              ingress = { enabled = false }
              thanosService = { enabled = false }
              thanosIngress = { enabled = false }
              prometheusSpec = {
                serviceMonitorSelector = {}
                serviceMonitorSelectorNilUsesHelmValues = false
                retention = "2d"
              }
            }
            kubelet = {
              enabled = true
              serviceMonitor = { enabled = true }
            }
            alertmanager = {
              enabled = true
              ingress = { enabled = false }
              alertmanagerSpec = {
                forceEnableClusterMode = true
                configSecret = "alertmanager-secret"
              }
            }
            grafana = {
              sidecar = {
                datasources = {
                  enabled                = true
                  defaultDatasourceEnabled = false
                }
              }
              ingress = { enabled = false }
              adminPassword = "prom-operator"
              additionalDataSources = [
                {
                  name      = "Prometheus"
                  type      = "prometheus"
                  uid       = "prometheus"
                  url       = "http://prometheus-operator-prometheus.monitoring:9090"
                  access    = "proxy"
                  isDefault = true
                },
                {
                  name      = "Loki"
                  type      = "loki"
                  uid       = "loki"
                  url       = "http://loki.monitoring:3100"
                  access    = "proxy"
                  isDefault = false
                }
              ]
            }
            prometheusOperator = {
              admissionWebhooks = {
                enabled = false
                patch = { enabled = false }
                certManager = { enabled = false }
                autoGenerateCert = false
              }
              tls = { enabled = false }
            }
            kube-state-metrics = {
              prometheus = { monitor = { enabled = true } }
            }
            prometheus-node-exporter = {
              service = { port = 9200 }
            }
          }
        }
      }
      syncPolicy = {
        automated = {
          prune = true
          selfHeal = true
        }
        syncOptions = ["Replace=true", "ServerSideApply=true"]
      }
    }
  }

  depends_on = [helm_release.argo]
}

resource "kubernetes_manifest" "loki_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "loki"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "monitoring"
      }
      source = {
        repoURL        = "https://grafana.github.io/helm-charts"
        chart          = "loki-stack"
        targetRevision = "2.9.10"
        helm = {
          valuesObject = {
            grafana = {
              enabled = false
              sidecar = {
                datasources = { enabled = false }
              }
            }
            prometheus = {
              enabled = false
            }
            loki = {
              persistence = { enabled = false }
            }
            promtail = {
              enabled = true
              tolerations = [
                {
                  key      = "usage"
                  operator = "Equal"
                  value    = "infrastructure"
                  effect   = "NoSchedule"
                }
              ]
            }
            test = {
              enabled = false
            }
          }
        }
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [helm_release.argo]
}

