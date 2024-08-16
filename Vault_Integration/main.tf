provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://54.209.249.104:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "66134aab-56ae-a979-e5b3-d96b60422cf9"
      secret_id = "0a8fcd47-5da5-247b-3f29-113e5ec41ea8"
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "learn"
  name  = "devops"
}

resource "aws_instance" "example" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"

tags= {
    secret = data.vault_kv_secret_v2.example.data["username"]
}
}