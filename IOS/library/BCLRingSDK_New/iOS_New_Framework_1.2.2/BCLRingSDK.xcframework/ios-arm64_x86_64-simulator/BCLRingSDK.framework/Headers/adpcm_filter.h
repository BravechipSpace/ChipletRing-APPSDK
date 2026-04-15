#ifndef ADPCM_FILTER_H
#define ADPCM_FILTER_H

#include <stdint.h>

#define CLAMP(x, low, high) (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

long yma_encode(int16_t *buffer, uint8_t *outbuffer, long len);
void yma_decode(uint8_t *buffer, uint8_t *outbuffer, long len);
void bandpass_filter(int16_t *input, int16_t *output, int length);

// Swift callable functions
#ifdef __cplusplus
extern "C" {
#endif

// Swift可调用的ADPCM转PCM函数
// 输入: ADPCM数据指针和长度
// 输出: PCM数据指针和输出长度(通过指针返回)
// 返回值: 处理成功返回0，失败返回-1
int adpcm_to_pcm_for_swift(const uint8_t *adpcm_data, int adpcm_length, uint8_t **pcm_data, int *pcm_length);

// 释放PCM数据内存的函数
void free_pcm_data(uint8_t *pcm_data);

#ifdef __cplusplus
}
#endif

// C++ inline functions for ADPCM encoding/decoding
static inline int16_t yma_step(uint8_t step, int16_t *history, uint8_t *step_hist);
static inline uint8_t yma_encode_step(int16_t input, int16_t *history, uint8_t *step_hist);

#endif // ADPCM_FILTER_H
