* avx.patch: for some reason when USE_AVX2 is set, and `gold` linker is used,
  the build fails with undefined symbol `__cpu_model`.  For now this is resolved
  by just not using AVX2 at all.
