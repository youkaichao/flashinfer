/*
 * Copyright (c) 2023 by FlashInfer team.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include "aot_default_additional_params.h"
#include "pytorch_extension_utils.h"

void CutlassSegmentGEMMSM90(at::Tensor float_workspace_buffer, at::Tensor int_workspace_buffer,
                            at::Tensor all_problems, at::Tensor x_ptr, at::Tensor w_ptr,
                            at::Tensor y_ptr, at::Tensor x_stride, at::Tensor weight_stride,
                            at::Tensor y_stride, at::Tensor empty_x_data, bool weight_column_major,
                            int64_t cuda_stream);

void single_prefill_with_kv_cache_sm90(
    at::Tensor q, at::Tensor k, at::Tensor v, at::Tensor tmp, at::Tensor o,
    std::optional<at::Tensor> maybe_lse, unsigned int mask_mode_code, unsigned int layout,
    int32_t window_left SINGLE_PREFILL_SM90_ADDITIONAL_FUNC_PARAMS, int64_t cuda_stream);

at::Tensor BatchPrefillWithKVCacheSM90Plan(
    at::Tensor float_workspace_buffer, at::Tensor int_workspace_buffer,
    at::Tensor page_locked_int_workspace_buffer, at::Tensor qo_indptr, at::Tensor kv_indptr,
    at::Tensor kv_len_arr, unsigned total_num_rows, unsigned int batch_size,
    unsigned int num_qo_heads, unsigned int num_kv_heads, unsigned int page_size,
    bool enable_cuda_graph, unsigned int head_dim, bool causal, int64_t cuda_stream);

void BatchPrefillWithRaggedKVCacheSM90Run(
    at::Tensor float_workspace_buffer, at::Tensor int_workspace_buffer,
    at::Tensor plan_info_vec, at::Tensor q, at::Tensor k, at::Tensor v,
    at::Tensor qo_indptr, at::Tensor kv_indptr, at::Tensor o, std::optional<at::Tensor> maybe_lse,
    unsigned int mask_mode_code, unsigned int layout,
    int32_t window_left BATCH_PREFILL_SM90_ADDITIONAL_FUNC_PARAMS, int64_t cuda_stream);

void BatchPrefillWithPagedKVCacheSM90Run(
    at::Tensor float_workspace_buffer, at::Tensor int_workspace_buffer,
    at::Tensor plan_info_vec, at::Tensor q, at::Tensor paged_k_cache,
    at::Tensor paged_v_cache, at::Tensor qo_indptr, at::Tensor paged_kv_indptr,
    at::Tensor paged_kv_indices, at::Tensor paged_kv_last_page_len, at::Tensor o,
    std::optional<at::Tensor> maybe_lse, unsigned int mask_mode_code, unsigned int layout,
    int32_t window_left BATCH_PREFILL_SM90_ADDITIONAL_FUNC_PARAMS, int64_t cuda_stream);

TORCH_LIBRARY(TORCH_EXTENSION_NAME, m) {
  // "Cutlass Segment GEMM operator for SM90"
  m.def("cutlass_segment_gemm_sm90", CutlassSegmentGEMMSM90);
  m.def("single_prefill_with_kv_cache_sm90", single_prefill_with_kv_cache_sm90);
  m.def("batch_prefill_with_kv_cache_sm90_plan", BatchPrefillWithKVCacheSM90Plan);
  m.def("batch_prefill_with_ragged_kv_cache_sm90_run", BatchPrefillWithRaggedKVCacheSM90Run);
  m.def("batch_prefill_with_paged_kv_cache_sm90_run", BatchPrefillWithPagedKVCacheSM90Run);
}
