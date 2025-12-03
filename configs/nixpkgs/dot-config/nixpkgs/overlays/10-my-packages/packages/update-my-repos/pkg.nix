{ pythonPackages }:

pythonPackages.buildPythonPackage {
  pname = "update-my-repos";
  version = "0.1.0";

  pyproject = true;
  src = ./src;

  build-system = [ pythonPackages.hatchling ];

  dependencies = [ ];
}
