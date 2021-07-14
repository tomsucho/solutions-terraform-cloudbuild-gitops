# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


locals {
  env = "dev"
}

data "google_compute_subnetwork" "shared-vpc-subnet" {
  name   = "shared-subnet-01"
  region = "us-east4"
}

data "terraform_remote_state" "shared-vpc-state" {
  backend = "gcs"
  config = {
    bucket = "prj-bu1-c-infra-pipeline-ac69-tfstate"
    prefix = "env/shared"
  }
}

resource "google_compute_network" "shared-vpc" {
  name = data.terraform_remote_state.shared-vpc-state.outputs.network
}

provider "google" {
  project = var.project
}

module "vpc" {
  source      = "../../modules/vpc"
  project     = var.project
  env         = local.env
  subnet_cidr = "10.10.0.0/16"
}

module "http_server" {
  source  = "../../modules/http_server"
  project = var.project
  subnet  = module.vpc.subnet
}

module "firewall" {
  source  = "../../modules/firewall"
  project = var.project
  subnet  = module.vpc.subnet
}
