# Unpack benchmark

Measures how long it takes to make a prebuilt SDK usable on a fresh runner by
**streaming** the release parts straight from `curl` into `tar -xz` — the bytes
are decompressed as they arrive, so nothing intermediate is written to disk
(no download-then-extract double I/O).

Compare the result against your already-captured `dotnet workload install` times.

## Run it

Trigger the **Benchmark prebuilt unpack** workflow (Actions tab → *Run workflow*)
with the SDK `dotnet_version` (must have a published release). Optionally pass the
known `dotnet workload install` baseline (seconds) per RID to render the speedup
in the job summary.

## Run it locally

```bash
# REPO defaults to AvaloniaUI/prebuilt-dotnet-sdks; needs `gh` authenticated.
./benchmark/stream-unpack.sh linux-x64 10.0.101 ~/dotnet
```

The script prints `elapsed_seconds`, `bytes`, and `throughput_mib_s`.
