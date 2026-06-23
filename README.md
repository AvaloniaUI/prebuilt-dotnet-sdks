# prebuilt-dotnet-sdks

Prebuilt .NET SDK archives with all Avalonia-relevant workloads preinstalled, so CI
machines can skip the 5–10 minute `dotnet workload install` step. A workflow run
downloads the SDK via `dotnet-install`, installs every workload, and publishes one
`.tar.gz` per RID as a GitHub release asset.

## What gets built

For a given SDK version (e.g. `10.0.101`) the workflow produces:

| RID         | Runner            | Workloads |
|-------------|-------------------|-----------|
| `win-x64`     | `windows-latest`  | ios, android, macos, wasm-tools, wasm-experimental, maui-android |
| `osx-arm64`   | `macos-latest`    | ios, android, macos, wasm-tools, wasm-experimental, maui-android |
| `linux-x64`   | `ubuntu-latest`   | android, wasm-tools, wasm-experimental |

Full solution builds (including mobile and browser) run on Windows and macOS, so
those archives carry every workload; Linux only needs android + wasm.

Each archive is named `dotnet-<rid>-<version>.tar.gz` and contains a complete
`dotnet` install directory.

The GitHub release is tagged with the .NET version (e.g. `10.0.101`).

## Building a new SDK archive

Trigger the **Build prebuilt .NET SDK** workflow (Actions tab → *Run workflow*) and
provide:

- **dotnet_version** – the exact SDK version, e.g. `10.0.101`
- **prerelease** – (optional) mark the GitHub release as a prerelease

Workloads are fixed per RID (see the table above). Re-running for a version that
already has a release updates that release and overwrites the matching `.tar.gz`
assets.

## Using an archive on CI

```bash
VERSION=10.0.101
RID=linux-x64
mkdir -p "$HOME/dotnet"
curl -fsSL "https://github.com/AvaloniaUI/prebuilt-dotnet-sdks/releases/download/${VERSION}/dotnet-${RID}-${VERSION}.tar.gz" \
  | tar -xz -C "$HOME/dotnet"
export DOTNET_ROOT="$HOME/dotnet"
export PATH="$DOTNET_ROOT:$PATH"
dotnet workload list   # workloads are already present
```
