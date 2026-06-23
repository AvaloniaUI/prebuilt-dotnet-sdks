# Unpack benchmark

Measures how long it takes to make a prebuilt SDK usable on a fresh runner by
**streaming** the release parts straight from `curl` into `tar -xz` — the bytes
are decompressed as they arrive, so nothing intermediate is written to disk
(no download-then-extract double I/O).

Compare the result against your already-captured `dotnet workload install` times.

## Run it

The **Benchmark prebuilt unpack** workflow auto-runs on every commit to the
`benchmark-unpack` branch (push-triggered, so it doesn't need to live on the
default branch). To benchmark a different SDK version, edit `DOTNET_VERSION` at
the top of `.github/workflows/benchmark.yml`; to render the speedup, fill in the
per-RID `baseline` values with your captured `dotnet workload install` times.
Results land in the run's job summary.

## Run it locally

```bash
# REPO defaults to AvaloniaUI/prebuilt-dotnet-sdks; needs `gh` authenticated.
./benchmark/stream-unpack.sh linux-x64 10.0.101 ~/dotnet
```

The script prints `elapsed_seconds`, `bytes`, and `throughput_mib_s`.
