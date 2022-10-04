#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void write_frame_to_file(uint8_t *data,
                         uintptr_t dlen,
                         const uint8_t *sps,
                         uintptr_t sps_len,
                         const uint8_t *pps,
                         uintptr_t pps_len,
                         uint16_t width,
                         uint16_t height,
                         const char *fpath);
