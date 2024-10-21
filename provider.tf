terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 4.0"
       }
       google = {
         source  = "hashicorp/google"
         version = "~> 4.0"
       }
     }
   }

   provider "aws" {
     region = "us-east-1"  # Replace with your preferred AWS region
   }

   provider "google" {
     credentials = file("C:/VS Code Projects/CrossCloud/vernal-tempo-415903-9f97f69b9aa6.json")
     project     = "vernal-tempo-415903"
     region      = var.gcp_region
   }