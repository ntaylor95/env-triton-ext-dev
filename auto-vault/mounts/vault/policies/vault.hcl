path "*" {
  policy = "deny"
}

path "auth/token/revoke" {
  policy = "write"
}

path "auth/token/revoke-accessor" {
  policy = "write"
}

path "auth/token/revoke-self" {
  policy = "write"
}