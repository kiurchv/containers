variable "version" {
  default = "13.0.1"
}

target "default" {
  tags = ["ghcr.io/kiurchv/citus:${version}"]
  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    VERSION = version
  }
}
