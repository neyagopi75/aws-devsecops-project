path "secret/data/devsecops/*" {
  capabilities = ["read"]
}

path "secret/metadata/devsecops/*" {
  capabilities = ["read", "list"]
}