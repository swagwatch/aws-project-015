resource "kubernetes_config_map" "custom_error_pages" {

  count = local.addon_flag_networking

  metadata {
    name      = "custom-error-pages"
    namespace = "kube-system"
  }

  data = {
    "404" = <<-EOT
      <!DOCTYPE html>
      <html lang='en'> 
        <head> <title>Not Found</title> </head>
        <body> 
          <header> 
            <div> 
            </div> 
          </header> 
          <h1><b>404</b></h1> 
          <p>This page does not exist.</p> 
          <footer> 
            <ul style="list-style: none;"> 
            </ul> 
          </footer> 
        </body>
      </html>
    EOT

    "503" = <<-EOT
      <!DOCTYPE html>
      <html lang='en'> 
        <head> <title>Under Maintenance</title> </head>
        <body> 
          <header> 
            <div> 
            </div> 
          </header> 
          <h1><b>We&rsquo;ll be back soon!</b></h1> 
          <p>We&rsquo;re performing some maintenance at the moment. If you need to you can always follow us on our social media platforms for updates, otherwise we&rsquo;ll be back up shortly!</p> 
          <footer> 
            <ul style="list-style: none;"> 
            </ul> 
          </footer> 
        </body>
      </html>
    EOT
  }
  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}
