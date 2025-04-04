variable "version" {
  default = "v0.16.1"
}

variable "git_commit" {
  default = "21e4ff4"
}

target "default" {
  tags = ["ghcr.io/kiurchv/external-dns:${version}"]
  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    VERSION = version
    GIT_COMMIT = git_commit
  }
}
