#pragma once

#include <ATen/ATen.h>
#include <ATen/cuda/detail/TensorInfo.cuh>
#include <limits>

namespace at {
namespace cuda {
namespace detail {

TORCH_CUDA_API bool maybeOverlappingIndices(const at::Tensor& t);
TORCH_CUDA_API bool canUse32BitIndexMath(const at::Tensor &t, int64_t max_elem=std::numeric_limits<int32_t>::max());

// Argument `positiveDim` turns on the legacy behavior of THC's getTensorInfo:
// if `t` is a scalar, it's interpreted as a single-element vector.
// (See the legacy implementation in aten/src/THC/THCTensorTypeUtils.cuh)
template <typename scalar, typename IndexType>
TensorInfo<scalar, IndexType>
getTensorInfo(const at::Tensor& t, bool positiveDim = false) {
  IndexType sz[MAX_TENSORINFO_DIMS];
  IndexType st[MAX_TENSORINFO_DIMS];

  int dims = t.dim();
  for (int i = 0; i < dims; ++i) {
    sz[i] = t.size(i);
    st[i] = t.stride(i);
  }
  if (positiveDim && dims == 0) {
    dims = 1;
    sz[0] = 1;
    st[0] = 1;
  }

  return TensorInfo<scalar, IndexType>(
    t.data_ptr<scalar>(), dims, sz, st);
}

} // detail
} // cuda
} // at
