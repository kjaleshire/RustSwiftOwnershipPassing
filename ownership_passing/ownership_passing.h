#pragma once

#include <stdint.h>

struct RustByteSlice {
    const uint8_t *bytes;
    size_t len;
};

struct named_data;

struct named_data *named_data_new(void);
void named_data_destroy(struct named_data *data);
struct RustByteSlice named_data_get_name(const struct named_data *data);
size_t named_data_count(const struct named_data *data);

struct swift_object {
  void *user;
  void (*destroy)(void *user);
  void (*callback_with_int_arg)(void *user, int32_t arg);
};

void give_object_to_rust(struct swift_object object);
