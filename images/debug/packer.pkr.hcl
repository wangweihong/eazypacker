
locals {
  var1 = var.var1 == null ? (
    var.is_ubuntu ? "apt install docker" : "yum install docker"
  ) : var.var1
}

source "file" "debug" {
  content = local.var1
  target  = "dummy_artifact"
}

build {
  sources = ["sources.file.debug"]
}
