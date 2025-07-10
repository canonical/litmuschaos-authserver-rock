set export # Just variables are exported to environment variables

rock_name := `echo ${PWD##*/} | sed 's/-rock//'`
latest_version := `find . -maxdepth 1 -type d | sort -V | tail -n1 | sed 's@./@@'`

[private]
default:
  just --list

# Push an OCI image to a local registry
[private]
push-to-registry version:
  echo "Pushing $rock_name $version to local registry"
  rockcraft.skopeo --insecure-policy copy --dest-tls-verify=false \
    "oci-archive:${version}/${rock_name}_${version}_amd64.rock" \
    "docker://localhost:32000/${rock_name}-dev:${version}"

# Pack a rock of a specific version
pack version=latest_version:
  cd "$version" && rockcraft pack

# `rockcraft clean` for a specific version
clean version=latest_version:
  cd "$version" && rockcraft clean

# Run a rock and open a shell into it with `kgoss`
run version=latest_version: (push-to-registry version)
  kgoss edit -i localhost:32000/${rock_name}-dev:${version}

# FIXME: add integration tests cfr. https://github.com/canonical/litmuschaos-authserver-rock/issues/1
# test version=latest_version: (push-to-registry version)
  # kgoss run -i localhost:32000/${rock_name}-dev:${version}
