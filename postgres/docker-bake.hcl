variable "version" {
  default = "17.2"
}

variable "citus_version" {
  default = "13.0.1"
}

target "default" {
  tags = ["ghcr.io/kiurchv/postgres:${version}"]
  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    CITUS_VERSION = citus_version
  }
}
