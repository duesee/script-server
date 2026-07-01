let
  json = builtins.fromJSON (builtins.readFile ../web-src/package.json);
in
{
  buildNpmPackage,
}:
buildNpmPackage {
  pname = "script-server-web";
  version = json.version;

  src = ../web-src;

  npmDepsHash = "sha256-aBZDh2NcDU4OpsdTS8JqwGMa8WeIoyW9I6bUwTXfllU=";

  makeCacheWritable = true;

  # See <https://stackoverflow.com/questions/75959563/node-js-err-ossl-evp-unsupported-error-when-running-npm-run-start>
  NODE_OPTIONS = "--openssl-legacy-provider";

  installPhase = ''
    runHook preInstall
    mv ../web "$out"
    runHook postInstall
  '';
}
