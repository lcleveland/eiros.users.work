{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    services.ollama = {
      enable = true;
      acceleration = "vulkan";
    };
  };
}
