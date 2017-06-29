path "*" {
  policy = "deny"
}

path "pki/cert/ca" {
  policy = "read"
}

path "pki/issue/apps" {
  policy = "write"
}

path "pki/revoke" {
  policy = "write"
}

path "auth/approle/role/*" {
  policy = "read"
}