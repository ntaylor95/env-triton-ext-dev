path "*" {
  policy = "deny"
}

path "cubbyhole/*" {
  policy = "write"
}