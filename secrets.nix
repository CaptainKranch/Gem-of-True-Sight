let
  # SSH public keys for different users/hosts
  danielgm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKeMSnEvoZrlPC7LMnlIEeLTQ3QLpdeM6njeXhtqFYrM dgm";
  
  # Host keys from actual machines
  medellin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3bW3n8MxKRIYchN3cpRZyYoRLPYoX8wfrLGLIzs+Ky";
  yonaguni = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBt6DVjM7FOLiyIYa1y1ZYuYK/H3GOKGY4HADPB5AdMM";
  
  # Groups of keys
  allUsers = [ danielgm ];
  allHosts = [ medellin yonaguni ];
  
in
{
  # Hoarder OpenAI API key
  "hoarder-openai-key.age".publicKeys = allUsers ++ [ medellin ];
  
  # MinIO credentials
  "minio-root-user.age".publicKeys = allUsers ++ [ medellin ];
  "minio-root-password.age".publicKeys = allUsers ++ [ medellin ];
  
  # Database credentials
  "postgres-password.age".publicKeys = allUsers ++ [ medellin ];
  "mysql-password.age".publicKeys = allUsers ++ [ medellin ];
  "mysql-root-password.age".publicKeys = allUsers ++ [ medellin ];
  
  # Plex claim token
  "plex-claim.age".publicKeys = allUsers ++ [ medellin ];
}